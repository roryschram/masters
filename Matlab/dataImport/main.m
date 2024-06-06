%Description: Main block dictating use 
%References: Included in all individual blocks
%Motlatsi Setsubi
%2017
%clear all
addpath('..\Remod')

%Parameters for remodulation
Remod.PilotValue = 1; % 0= Blanking,1=Normalise, 2=Unchanged 3=Custom
Remod.CustomPilot = 3; % custom pilot amplitude
Remod.Guard = 1; % 0 = Blanking, 1 = Unchanged
%Filename
filename = 'IQdata';

%%
%Data To upload
% load('Resampled_rec.mat');
Values = resampledData;

%load('DVBT2_data.mat')

% load('Multi_PLP_data.mat')
%%
%Output folder
filenameParameters = [filename '_Parameters_' datestr(datetime('now'),'yyyy-MM-dd_HH.mm.ss') '.txt' ];
filenameIQ = [filename '_IQ_' datestr(datetime('now'),'yyyy-MM-dd_HH.mm.ss') '.txt' ];

if (exist('../Output'))
    filenameIQ = ['../Output/' filenameIQ];
    filenameParameters = ['../Output/' filenameParameters];
else
    mkdir '../Output'
    filenameIQ = ['../Output/' filenameIQ];
    filenameParameters = ['../Output/' filenameParameters];
end

filenameParameters = fopen(filenameParameters,'a');
filenameIQ = fopen(filenameIQ,'a');
%%
%A. DEMODULATION


%2. P1 Detection - Detect all P1 symbols in data
[index, P1ffreq]= P1Detection(Values);
fprintf('Number of T2 Frame detected: %u \n',length(index));
numP1 = length(index);

n = 0:length(Values)-1;
n = n.';
Values = Values.*exp((1i*2*pi*(-P1ffreq(1))*n)/1024); % Data now fractional carrier freq corrected



%Extra Samples before first P1 detection
indexrange = index(1)-543;
if indexrange>0; RemainingSamples(Values(1:indexrange),0,filenameParameters,filenameIQ);end
    
%Find interger carrier offset
P1ifreq = P1Validation(Values(index:index+1023));
n = 0:(length(Values)-1);
n = n.';

Values = Values.*exp((1i*2*pi*(-P1ifreq)*n)/1024); % Data now fractional carrier freq corrected

for i = 1:numP1
    fprintf('Frame %d of %d being processed...\n',i,numP1)
    fprintf('Frame %d of %d demodulating...\n',i,numP1)
    
    %1a. SNR Estimate
    % Provide quick estimate of SNR based on input signal 32K FFT.
    % Needed for coarse timing estimate in DVBT2
    [SNR,Variance] = SNRestimate(Values(index(i):(index(i)+32768-1)));
    
    
    %3. P1 Detection, Validation, Decoding
    [Start.miso, Start.nfft, guardint, p2start, Values,FEF] = P1Extraction(Values,index(i),P1ffreq); % Add decision of which s1/s2 combination pg 163, recommended
    % indexes contains indexes for start of each frame in data set after decoding p1
    % Values is frequency is fractionally frequency corrected version of data vector
    
    if i==numP1
        break
    end
    
    if strcmp(FEF,'FEF')
        RemainingSamples(Values((index(i)-542):(index(i+1)-543)),i,filenameParameters,filenameIQ)
        continue
    end
    
    %4. Guard interval Correlation
    Start.gi = GuardCorr(Values(p2start+50:p2start+50+8*(Start.nfft*(5/4))), Start.nfft, guardint);
    
    %5. P2 Handling
    [dataindex, P2foffset, P2ioffset,P2_CPE, L1pre, L1post,L1presymbols,L1postsymbols,RemainingP2,Frameindex] = P2Handling(Values(p2start:end), Start,SNR,Variance,p2start);
    
    n = [0:length(Values)-1].';
    Values1 = Values.*exp((1i*2*pi*(-P2foffset)*n)/(Start.nfft)); %Fractional frequency offset correction
    Values1 = Values.*exp((1i*2*pi*(-P2ioffset)*n)/(Start.nfft)); %Integer frequency offset correction
    
    %6. Data Handling
    [PLPValues,FCValues,RemainingP2,Data_CPE,FC_CPE] = DataHandling(Values1(dataindex:end),Start,SNR,Variance,L1pre,L1post,dataindex,RemainingP2);
    fprintf('Frame %d of %d remodulating...',i,numP1)
    %B. REMODULATION
    % Remodulation
    Values_remodulated = Remodulation(PLPValues,FCValues,RemainingP2,L1presymbols,L1postsymbols,P2_CPE,Data_CPE,FC_CPE,P1ffreq,P1ifreq,P2foffset,P2ioffset,L1pre,L1post,Start,Remod);
    % Write to file
    
    P2 = P2Parameters(L1pre.S2,L1pre.S1);
    
    Frametofile(Values_remodulated,filenameIQ,filenameParameters,L1pre,L1post,P2,Frameindex,i);
    FrametoRCF
    
    index(i+1) = index(i)+(L1pre.numdatasymbols+P2.N_P2)*(P2.NFFT)*(1+Start.gi)+(542+482+482+542);
    fprintf('Frame %d of %d completed...\r\n',i,numP1)
end

% Remaining samples
RemainingSamples(Values((index(i)-542):end),i,filenameParameters,filenameIQ)
fprintf('Frame Remodulation completed')
fclose all