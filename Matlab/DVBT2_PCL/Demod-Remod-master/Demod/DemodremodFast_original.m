function [Values_remod, Values_SurvData] = DemodremodFast(RefData,SurvData,index,P1foffset,OutputFile,Guard,CustomPilot,Pilot,demodREMODwrite)
%Description: Demod-Remod Main
%References: 
%Input
% - Values - IQ Data
% - Outputfilename - output filename
% - Guard - guard interval blanking 0 or unchanged 1
% - CustomPilot - Amplitude of pilot
% - Pilot - Pilot blanking 0/equalisation 1/unchanged 2/custom 3
%%

%addpath('..\Remod') %contains all code related to remodulation

%-------------------------------------------------------------------------------%
% Include because I dont feel like rewriting more code
%-------------------------------------------------------------------------------%
JamPilotSetting.Cp = 1; % 0 for blanking, 1 for unchanged, (4/9)^2 for equalisation
JamPilotSetting.Sp = 1; % (3/7)^2 for equalisation
JamPilotSetting.P2 = 1; % (3/7)^2 for equalisation
JamPilotSetting.Guard = 1; % Set to 0 to blank, 1 to leave unchanged

%Remodulation Settings
Remod.PilotValue = Pilot; % Pilot amplitude adjustment: 0= Blanking,1=Normalise, 2=Unchanged 3=Custom
Remod.CustomPilot = CustomPilot; % Custom pilot amplitude
Remod.Guard = Guard; % Guard interval presence: 0 = Blanking, 1 = Unchanged

Fc = 0; % Carrier Frequency
Bw = 64e6/7; % Bandwidth
Fs = Bw; % Sampling Frequency

%%
% Remodulation Console Display Output
switch Pilot
    case 0
        fprintf('Signal Reconstruction settings - All Pilots are blanked \r\n')
        outPilot = 'BLANKED_pilots';
    case 1
        fprintf('Signal Reconstruction settings - All Pilots are equalized \r\n')
        outPilot = 'EQUALISED_pilots';
    case 2
        fprintf('Signal Reconstruction settings - All Pilots are unchanged \r\n')
        outPilot = 'UNCHANGED_pilots';
    case 3
        fprintf('Signal Reconstruction settings - All Pilots are a User-specified value. Pilots = %d \r\n',CustomPilot)
        outPilot = 'CUSTOM_pilots';
    otherwise
        fprintf('Signal Reconstruction settings - Invalid Pilot setting. Pilots are unchanged \r\n')
        outPilot = 'UNCHANGED_pilots';
        Remod.PilotValue = 2;
end


switch Guard
    case 0
        fprintf('Signal Reconstruction settings - Guard intervals are blanked \r\n')
        outGuard = 'BLANKED_guard';
    case 1
        fprintf('Signal Reconstruction settings - Guard intervals are unchanged \r\n')
        outGuard = 'UNCHANGED_guard';
    otherwise
        fprintf('Signal Reconstruction settings - Invalid Guard setting. Guard intervals are unchanged \r\n')
        outGuard = 'UNCHANGED_guard';
        Remod.Guard = 1;
end
%%
%1. P1 Detection - Detect all P1 symbols in data
%[index, P1foffset]= P1Detection(RefData);
fprintf('Number of T2 Frame detected: %u \n',length(index)-1);
numP1 = length(index);

if numP1<=1
    fprintf('One P1 symbol: Full Frame not detected \n')
    return
end
    
n = 0:length(RefData)-1;
n = n.';
RefData = RefData.*exp((1i*2*pi*(-P1foffset(1))*n)/1024); % Data now fractional carrier freq corrected
SurvData = SurvData.*exp((1i*2*pi*(-P1foffset(1))*n)/1024);

%3. P1 Validation - Interger Carrier Frequency Offset
P1ioffset = P1Validation(RefData(index:index+1023));
Values_remod = [];
Pilots_remod = [];
RefData = RefData.*exp((1i*2*pi*(-P1ioffset)*n)/1024); % Data now integer carrier freq corrected
SurvData = SurvData.*exp((1i*2*pi*(-P1ioffset(1))*n)/1024);
i1=1; % Error check variable
for i = 1:numP1
        
    if i==numP1
        break
    end
    
    fprintf('Frame %d of %d being processed...\n',i,numP1-1)
    fprintf('Frame %d of %d demodulating...\n',i,numP1-1)
    
    %4. SNR Estimate
    % Provide quick estimate of SNR based on input signal 32K FFT.
    % Needed for coarse timing estimate in DVBT2
    [SNR,Variance] = SNRestimate(RefData(index(i):(index(i)+32768-1)));
    
    
    %5. P1 Decoding
    [Start.miso, Start.nfft, guardint, p2start, RefData,FEF] = P1Extraction(RefData,index(i)); % Add decision of which s1/s2 combination pg 163, recommended
    % indexes contains indexes for start of each frame in data set after decoding p1
    % Values is frequency is fractionally frequency corrected version of data vector
    
    if strcmp(FEF,'FEF')
%         RemainingSamples(Values((index(i)-542):(index(i+1)-543)),i,filenameParameters,filenameIQ)
        continue
    end
    
    %6. Guard interval Correlation - Determine Guard interval size
    Start.gi = GuardCorr(RefData(p2start+50:p2start+50+8*(Start.nfft*(5/4))), Start.nfft, guardint);
        
    %7. P2 Handling - Determine L1pre and L1post signalling, Extract L1pre and L1post symbol 
    try
        [dataindex, P2foffset, P2ioffset,P2_CPE, L1pre, L1post,L1presymbols,L1postsymbols,RemainingP2] = P2Handling(RefData(p2start:end), Start,SNR,Variance,p2start);
    catch
        Comment(i,OutputFile);
        fprintf('Failure to decode L1pre and L1post parameters of frame %u. Moving to next frame \n',i)
        
        if (index(i1)-542+length(Values_remod)-1)>length(SurvData)
            Survstart = length(SurvData)-length(Values_remod);
            Surv_samplerange = Survstart:(Survstart+length(Values_remod)-1);
        else
            Surv_samplerange = (index(i1)-542):(index(i1)-542+length(Values_remod)-1);
        end
        
%         comment =  sprintf('Frames %u-%u (out of %u) stored',i1,i-1,numP1-1);
        
%         FrametoRCF(Values_remod,SurvData(Surv_samplerange).*exp((1i*2*pi*(-1*(P2foffset+P2ioffset))*n(Surv_samplerange))/(Start.nfft)),Fc,Fs,Bw,[OutputFile sprintf('%u-%u',i1,i-1)],comment);
        i1=i+1;
        Values_remod = [];
       continue
    end
	% The frequency correction process is only accurate to the size of the fft. 
	% Ofdm symbols can only take a max frequency offset of about 10% of their bin size (bandwidth/symbolsize). 
	% Following the p1 freq offset correction, the frequency is corrected enough for the demodulation of the p1 symbol but a large freq offset may exist for the p2 symbol (which is a larger symbol)
	% The p1 symbol has a size of 1k and the p2 symbols are 32k so the frequency offset correction in the p2 is needed.
    n = [0:length(RefData)-1].';
    Values1 = RefData.*exp((1i*2*pi*(-P2foffset)*n)/(Start.nfft)); %Fractional frequency offset correction
    Values1 = RefData.*exp((1i*2*pi*(-P2ioffset)*n)/(Start.nfft)); %Integer frequency offset correction
    
    %8. Data Handling
    [PLPValues,FCValues,RemainingP2,Data_CPE,FC_CPE,DVBT2] = DataHandling(Values1(dataindex:end),Start,SNR,Variance,L1pre,L1post,dataindex,RemainingP2);
	
    %9. Remodulation
    fprintf('Frame %d of %d remodulating...\n',i,numP1-1)
	Frame_remodulated = Remodulation(PLPValues,FCValues,RemainingP2,L1presymbols,L1postsymbols,P2_CPE,Data_CPE,FC_CPE,P1foffset,P1ioffset,P2foffset,P2ioffset,L1pre,L1post,Start,Remod);
    Values_remod = [Values_remod; Frame_remodulated.'];
	
	Pilots_remodulated = PilotRemodulation(PLPValues,FCValues,RemainingP2,L1presymbols,L1postsymbols,P2_CPE,Data_CPE,FC_CPE,P1foffset,P1ioffset,P2foffset,P2ioffset,L1pre,L1post,Start,JamPilotSetting);
    Pilots_remod = [Pilots_remod; Pilots_remodulated.'];
	
    %10. Write to file
    P2 = P2Parameters(L1pre.S2,L1pre.S1);
    [~] =  Comment(L1pre,L1post,P2,numP1,i,Remod,OutputFile);
    
    fprintf('Frame %d of %d completed...\r\n',i,numP1-1)
	DVBT2.symbol = DVBT2.NFFT;
	DVBT2.guard = DVBT2.NFFT*Start.gi;
	DVBT2.PilotMap = Pilots_remod;
end
%%
if (i==1)&&(~exist('L1pre','var')) % Error handlinf for first frame failure
    return
end

comment =  Comment(L1pre,L1post,P2,numP1,i,Remod);

if (index(i1)-542+length(Values_remod)-1)>length(SurvData)
    Survstart = length(SurvData)-length(Values_remod);
    Surv_samplerange = Survstart:(Survstart+length(Values_remod)-1);
else
    Surv_samplerange = (index(i1)-542):(index(i1)-542+length(Values_remod)-1);
end

SurvData = SurvData.*exp((1i*2*pi*(-P2foffset)*n)/(Start.nfft));
SurvData = SurvData.*exp((1i*2*pi*(-P2ioffset)*n)/(Start.nfft));

Values_SurvData = SurvData(Surv_samplerange);

if demodREMODwrite == 1;
	clear oInputRCFHeader;
%     fprintf('writing %d Frames to file...\n',numP1-1)
    FrametoRCF(Values_remod,Values_SurvData,Fc,Fs,Bw,[OutputFile '_' outPilot '_' outGuard '.rcf'],comment);
end
fprintf('Demod-Remod completed \r\n')
fclose all;
end