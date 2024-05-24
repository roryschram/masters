function [First_P1,LastP1_Refsamples,LastP1_Survsamples, Survdata, Values_remod] =Demodremod2(RefData,SurvData,Outputfile,Guard,CustomPilot,Pilot,ChunkNo)
%Description: Demod-Remod Main
%References: 
%Input
% - Values - IQ Data
% - Outputfilename - output filename
% - Guard - guard interval blanking 0 or unchanged 1
% - CustomPilot - Amplitude of pilot
% - Pilot - Pilot blanking 0/equalisation 1/unchanged 2/custom 3
%%

addpath('..\Remod') %contains all code related to remodulation

if ChunkNo==1
    permission='w';
else
    permission='a';
end

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
LastP1_Refsamples = RefData((index(end)-2048):end);
First_P1 = index(1)-542;
fprintf('Number of T2 Frame detected: %u \n',length(index));
numP1 = length(index);

if numP1<=1
    fprintf('One P1 symbol: Full Frame not detected \n')
    return
end
    
n = 0:length(RefData)-1;
n = n.';
RefData = RefData.*exp((1i*2*pi*(-P1foffset(1))*n)/1024); % Data now fractional carrier freq corrected

%3. P1 Validation - Interger Carrier Frequency Offset
P1ioffset = P1Validation(RefData(index:index+1023));
Values_remod = [];
RefData = RefData.*exp((1i*2*pi*(-P1ioffset)*n)/1024); % Data now fractional carrier freq corrected

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
        Comment2(i,ChunkNo,Outputfile)
        continue
    end
    
    %6. Guard interval Correlation - Determine Guard interval size
    Start.gi = GuardCorr(RefData(p2start+50:p2start+50+8*(Start.nfft*(5/4))), Start.nfft, guardint);
        
    %7. P2 Handling - Determine L1pre and L1post signalling, Extract L1pre and L1post symbol 
    try
        [dataindex, P2foffset, P2ioffset,P2_CPE, L1pre, L1post,L1presymbols,L1postsymbols,RemainingP2] = P2Handling(RefData(p2start:end), Start,SNR,Variance,p2start);
    catch
        Comment2(i,ChunkNo,Outputfile,permission)
        fprintf('Failure to decode L1pre and L1post parameters of frame %u. Moving to next frame',i)
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
    %10. Write to file
    P2 = P2Parameters(L1pre.S2,L1pre.S1);
    Comment2(L1pre,L1post,P2,i,Remod,ChunkNo,Outputfile,permission);
    permission = 'a';
    fprintf('Frame %d of %d completed...\r\n',i,numP1-1)
end
%%
fprintf('writing %d Frames to file...\n',numP1-1)

LastP1_Survsamples = SurvData((index(end)-2048):end);

SurvData = SurvData.*exp((1i*2*pi*(-P1foffset(1))*n)/1024);
SurvData = SurvData.*exp((1i*2*pi*(-P1ioffset(1))*n)/1024);
SurvData = SurvData.*exp((1i*2*pi*(-P2foffset)*n)/(Start.nfft));
SurvData = SurvData.*exp((1i*2*pi*(-P2ioffset)*n)/(Start.nfft));

if (index(1)-542+length(Values_remod)-1)>length(SurvData)
    Survstart = length(SurvData)-length(Values_remod);
    Surv_samplerange = Survstart:(Survstart+length(Values_remod)-1);
else
    Surv_samplerange = (index(1)-542):(index(1)-542+length(Values_remod)-1);
end

Survdata = SurvData(Surv_samplerange);
fprintf('Chunk %u Demod Remod completed \r\n',ChunkNo)

end