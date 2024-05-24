function Demodremod_FrameUpdate(RefData,SurvData,OutputFile,Guard,CustomPilot,Pilot,Foffset)
%Description: Demod-Remod with Surv channel frequency channel being updated every frame
%References: 
%Input
% - Values - IQ Data
% - Outputfilename - output filename
% - Guard - guard interval blanking 0 or unchanged 1
% - CustomPilot - Amplitude of pilot
% - Pilot - Pilot blanking 0/equalisation 1/unchanged 2/custom 3
%%

addpath('..\Remod') %contains all code related to remodulation

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
    case 1
        fprintf('Signal Reconstruction settings - All Pilots are equalized \r\n')
    case 2
        fprintf('Signal Reconstruction settings - All Pilots are unchanged \r\n')
    case 3
        fprintf('Signal Reconstruction settings - All Pilots are a User-specified value. Pilots = %d \r\n',CustomPilot)
    otherwise
        fprintf('Signal Reconstruction settings - Invalid Pilot setting. Pilots are unchanged \r\n')
        Remod.PilotValue = 2;
end


switch Guard
    case 0
        fprintf('Signal Reconstruction settings - Guard intervals are blanked \r\n')
    case 1
        fprintf('Signal Reconstruction settings - Guard intervals are unchanged \r\n')
    otherwise
        fprintf('Signal Reconstruction settings - Invalid Guard setting. Guard intervals are unchanged \r\n')
        Remod.Guard = 1;
end
%%
%1. P1 Detection - Detect all P1 symbols in data
[index, P1foffset]= P1Detection(RefData);
fprintf('Number of T2 Frame detected: %u \n',length(index));
numP1 = length(index);

if numP1<=1
    fprintf('One P1 symbol: Full Frame not detected \n')
    return
end
    
n = 0:length(RefData)-1;
n = n.';
RefData = RefData.*exp((1i*2*pi*(-P1foffset(1))*n)/1024); % Data now fractional carrier freq corrected
% SurvData = SurvData.*exp((1i*2*pi*(-P1foffset(1))*n)/1024);

%3. P1 Validation - Interger Carrier Frequency Offset
P1ioffset = P1Validation(RefData(index:index+1023));
Values_remod = [];

if isempty(Foffset.p1)
    Foffset.p1 = P1ioffset+P1foffset;
end

RefData = RefData.*exp((1i*2*pi*(-P1ioffset)*n)/1024); % Data now fractional carrier freq corrected
% SurvData = SurvData.*exp((1i*2*pi*(-P1ioffset(1))*n)/1024);
SurvData = SurvData.*exp((1i*2*pi*(-Foffset.p1)*n)/1024);
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
        Comment(i,OutputFile)
        fprintf('Failure to decode L1pre and L1post parameters of frame %u. Moving to next frame \n',i)
        
        if i1==i % Check for all
            i1 = i+1;
            Values_remod = [];
            continue
        end
        
        disp('Writing successful frames to file')
        
        if (index(i1)-542+length(Values_remod)-1)>length(SurvData)
            Survstart = length(SurvData)-length(Values_remod);
            Surv_samplerange = Survstart:(Survstart+length(Values_remod)-1);
        else
            Surv_samplerange = (index(i1)-542):(index(i1)-542+length(Values_remod)-1);
        end
        
        comment =  sprintf('Frames %u-%u (out of %u) stored',i1,i-1,numP1-1);
        
        if isempty(Foffset.p2)
            Foffset.p2 = P2ioffset+P2foffset;
        else
            Foffset.p2 = Foffset.p2-(P2ioffset+P2foffset) ;
        end
        
%         FrametoRCF(Values_remod,SurvData(Surv_samplerange).*exp((1i*2*pi*(-1*(P2foffset+P2ioffset))*n(Surv_samplerange))/(Start.nfft)),Fc,Fs,Bw,[OutputFile sprintf('%u-%u',i1,i-1)],comment);
%         FrametoRCF(Values_remod,SurvData(Surv_samplerange).*exp((1i*2*pi*(-1*(Foffset.p2))*n(Surv_samplerange))/(Start.nfft)),Fc,Fs,Bw,[OutputFile sprintf('%u-%u',i1,i-1)],comment);
        FrametoRCF(Values_remod,SurvData(Surv_samplerange),Fc,Fs,Bw,[OutputFile sprintf('%u-%u',i1,i-1)],comment);
        i1=i+1;
        Values_remod = [];
        continue
    end
    n = [0:length(RefData)-1].';
    
    
    Values1 = RefData.*exp((1i*2*pi*(-P2foffset)*n)/(Start.nfft)); %Fractional frequency offset correction
    Values1 = RefData.*exp((1i*2*pi*(-P2ioffset)*n)/(Start.nfft)); %Integer frequency offset correction
    
    %8. Data Handling
    [PLPValues,FCValues,RemainingP2,Data_CPE,FC_CPE] = DataHandling(Values1(dataindex:end),Start,SNR,Variance,L1pre,L1post,dataindex,RemainingP2);
    fprintf('Frame %d of %d remodulating...\n',i,numP1-1)
    %9. Remodulation
    Frame_remodulated = Remodulation(PLPValues,FCValues,RemainingP2,L1presymbols,L1postsymbols,P2_CPE,Data_CPE,FC_CPE,P1foffset,P1ioffset,P2foffset,P2ioffset,L1pre,L1post,Start,Remod);
        
    Values_remod = [Values_remod;Frame_remodulated.'];
        
    if isempty(Foffset.p2)
        Foffset.p2 = P2ioffset+P2foffset;
    else
        Foffset.p2 = Foffset.p2-(P2ioffset+P2foffset);
    end
    
    SurvData(index(i)-542:end) = SurvData(index(i)-542:end).*exp((1i*2*pi*(-Foffset.p2)*n(index(i)-542:end))/(Start.nfft));
    
    %10. Write to file
    P2 = P2Parameters(L1pre.S2,L1pre.S1);
    [~] =  Comment(L1pre,L1post,P2,numP1,i,Remod,OutputFile);
    
    fprintf('Frame %d of %d completed...\r\n',i,numP1-1)
end
%%
if (i==1)&&(~exist('L1pre','var')) % Error handlinf for first frame failure
    return
end

fprintf('writing %d Frames to file...\n',numP1-1)
comment =  Comment(L1pre,L1post,P2,numP1,i,Remod);

% if (index(i1)-542+length(Values_remod)-1)>length(SurvData)
%     Survstart = length(SurvData)-length(Values_remod);
%     Surv_samplerange = Survstart:(Survstart+length(Values_remod)-1);
% else
%     Surv_samplerange = (index(i1)-542):(index(i1)-542+length(Values_remod)-1);
% end

if (index(i1)-542+length(Values_remod)-1)>length(SurvData)
    Survstart = length(SurvData)-length(Values_remod);
    Surv_samplerange = Survstart:(Survstart+length(Values_remod)-1);
else
    Surv_samplerange = (index(i1)-542):(index(i1)-542+length(Values_remod)-1);
end

if isempty(Foffset.p2)
    Foffset.p2 = P2ioffset+P2foffset;
end

SurvData = SurvData.*exp((1i*2*pi*(-P2foffset)*n)/(Start.nfft));
SurvData = SurvData.*exp((1i*2*pi*(-P2ioffset)*n)/(Start.nfft));
SurvData = SurvData.*exp((1i*2*pi*(-Foffset.p2)*n)/(Start.nfft));

FrametoRCF(Values_remod,SurvData(Surv_samplerange),Fc,Fs,Bw,[OutputFile sprintf('%u-%u',i1,i-1)],comment);
fprintf('Demod Remod completed \r\n')
fclose all;
end