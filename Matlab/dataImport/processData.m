% Get the filepath of the input data from the USRP
filename = 'data.dat';

% Data recording details
Fs = 10e6;  % Sample rate of the USRP
Fc = 610e6; % Centre frequency of the USRP

% Fixed environmental variables
C = 299792458;      % Speed of the light (m/s)
Rs = (64e6)/7;      % Resample rate 
BW_OFDM = 7.768e6;  % Bandwidth of the OFDM based DVB-T2 signal that we are recording

% Check if the .dat raw data file has been imported. If not, import it.
if exist("complexData", "var")
    fprintf("complexData variable exists.\n");
else 
    fprintf("complexData variable does not exist. Ending execution\n");
end
rawData = complexData;


% Resample the data
fprintf('Resampling data..\n')
[n, d] = rat(10e6/((64e6)/7));
resampledData = transpose(resample(rawData, d, n).');
fprintf('Resampling complete..\n')

% Perform P1 detection
[P1Loc, ffreq] = P1FastDetection(resampledData,0);
fprintf('P1 Location: %s\n', P1Loc)
fprintf('Number of Valid Frames: %s\n', num2str(length(P1Loc)-1))

numP1 = length(P1Loc);


% Data now fractional carrier freq corrected
n = 0:length(resampledData)-1;
n = n.';
resampledData = resampledData.*exp((1i*2*pi*(-ffreq(1))*n)/1024);

%%% Trying to plot QAM plot here

% dataSymbol = resampledData(246102:246102+32768);
% 
% dataSymbolFFT = fft(dataSymbol);
% 
% I_dataSymbol = real(dataSymbolFFT);
% Q_dataSymbol = imag(dataSymbolFFT);
% 
% figure();
% scatter(I_dataSymbol,Q_dataSymbol);

for i=1:length(P1Loc)-1
    % Check that the frame is valid before continuing    
    if (P1Loc(i+1) - P1Loc(i)> 2e6)
        % If there are multiple frames, we can remove them and write to file,
		superFrame = resampledData(P1Loc(i)-2^(16):P1Loc(i+1)+2^(16));
    end
end


% Find interger carrier offset
P1ifreq = P1Validation(resampledData(P1Loc(1):P1Loc(1)+1023));
n = 0:(length(resampledData)-1);
n = n.';

% Data now fractional carrier freq corrected
resampledData = resampledData.*exp((1i*2*pi*(-P1ifreq)*n)/1024); 

%1a. SNR Estimate
% Provide quick estimate of SNR based on input signal 32K FFT.
% Needed for coarse timing estimate in DVBT2
[SNR,Variance] = SNRestimate(resampledData(P1Loc(1):(P1Loc(1)+32768-1)));


%3. P1 Detection, Validation, Decoding
[Start.miso, Start.nfft, guardint, p2start, resampledData,FEF] = P1Extraction(resampledData,P1Loc(1)); % Add decision of which s1/s2 combination pg 163, recommended
% indexes contains indexes for start of each frame in data set after decoding p1
% Values is frequency is fractionally frequency corrected version of data vector


%4. Guard interval Correlation
Start.gi = GuardCorr(resampledData(p2start+50:p2start+50+8*(Start.nfft*(5/4))), Start.nfft, guardint);


%5. P2 Handling
[dataindex, P2foffset, P2ioffset,P2_CPE, L1pre, L1post,L1presymbols,L1postsymbols,RemainingP2] = P2Handling(resampledData(p2start:end), Start,SNR,Variance,p2start);

n = [0:length(resampledData)-1].';
resampledData1 = resampledData.*exp((1i*2*pi*(-P2foffset)*n)/(Start.nfft)); %Fractional frequency offset correction
resampledData1 = resampledData.*exp((1i*2*pi*(-P2ioffset)*n)/(Start.nfft)); %Integer frequency offset correction

%6. Data Handling
[PLPValues,FCValues,RemainingP2,Data_CPE,FC_CPE] = DataHandling(resampledData1(dataindex:end),Start,SNR,Variance,L1pre,L1post,dataindex,RemainingP2);
% plotFFT(superFrame,Rs);
% plotFFT(resampledData1,Rs);

DVBT2 = DVBT2Parameters(L1pre,L1post);

dataSymbol = resampledData1(280928:280928+32768);

dataSymbolFFT = fft(dataSymbol);

I_dataSymbol = real(dataSymbolFFT);
Q_dataSymbol = imag(dataSymbolFFT);

scatter(I_dataSymbol,Q_dataSymbol);


