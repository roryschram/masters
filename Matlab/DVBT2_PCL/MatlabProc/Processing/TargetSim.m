function [] = TargetSim(inputFilename, TxToRefRxDistance_m, noTargets, range, doppler, snr)
addpath('.\\Classes')
% Read from RCF file
fprintf('Read input RCF: %s..\n',inputFilename)
oInputRCFHeader = cRCF;

oInputRCFHeader.readHeaderFromFile(inputFilename);

RCF_file = oInputRCFHeader.readFromFile(inputFilename, 1, oInputRCFHeader.m_NSamples);

ReferenceValues_Ch1 = RCF_file.m_fvReferenceData;
SurveillanceValues_Ch2 = RCF_file.m_fvSurveillanceData;

fprintf('File read completed\n');

CPI = oInputRCFHeader.m_NSamples;%0.2*Fs;
ReferenceData = ReferenceValues_Ch1(1:CPI);
SurveillanceData = SurveillanceValues_Ch2(1:CPI);

Fs = RCF_file.m_Fs_Hz;
% NSamples = length(ReferenceData);

C = 299792458;  %speed of the light (m/s)
% nRangeBins = ceil((MaxRange_m - TxToRefRxDistance_m) * Fs / C);
% nDopplerBins = round(MaxDoppler_Hz / (Fs / NSamples)); % Number of bins of 1 side of the Doppler spectrum without DC bin

SimulatedTargets = zeros(RCF_file.m_NSamples,1);
target = 1;
while le(target,noTargets)
    Range = range(target);
    DopplerShiftAmount_Hz = doppler(target);
    SNR = snr(target); % Set the dB level of the target referenced to the reference signal
    fprintf('Insert Target: %s @ [%s, %s, %s]\n', num2str(target), num2str(Range), num2str(DopplerShiftAmount_Hz), num2str(SNR))

    ShiftRange = Range-TxToRefRxDistance_m;
    ShiftAmount = round((ShiftRange/C)*Fs);

    delay = zeros(ShiftAmount,1);
    SimulatedTarget = [delay; ReferenceData(1:end-ShiftAmount)];
    A = rms(ReferenceData)*10^(SNR/20); % Scaling factor
    t = [-(((length(SimulatedTarget) - 1)/Fs)/2):1/Fs:((length(SimulatedTarget) - 1)/Fs)/2].';
    SimulatedTargets = SimulatedTargets + A*SimulatedTarget.*exp(1j*2*pi*DopplerShiftAmount_Hz*t);
    target = target + 1;
end

SurvData = SurveillanceData + SimulatedTargets;

%% Write simulated target to RCF
% Set RCF parameters
outputFile = ['SimulatedTarget_' inputFilename];
fprintf('Output RCF filename: %s..\n',outputFile)

comment = char('ComRAD data with two simulated targets');

% Set oRCF parameters
oRCF = cRCF;
oRCF.setFs_Hz(RCF_file.m_Fs_Hz);
oRCF.setBw_Hz(RCF_file.m_Fs_Hz);
oRCF.setFc_Hz(RCF_file.m_Fc_Hz);
oRCF.setReferenceData(ReferenceData);
oRCF.setSurveillanceData(SurvData);
oRCF.setNSamples(length(oRCF.getSurveillanceData()));
oRCF.setComment(comment);
oRCF.setTimeStamp_us(0);
% Write to RCF
fprintf('Writing RCF object to file...\n');
oRCF.writeToFile(outputFile);
fprintf('Complete\n');

%% Process data
% 
% Window = blackmanWindow(NSamples);
% 
% fprintf('Processing Ambiguity Function\n');
% timeindicate = 0;
% clear1 = '';
% tic
% for shift = 0:nRangeBins - 1
%     % Console update
%     if ((shift/nRangeBins)*100)>timeindicate
%         msg = sprintf('%2.2f%% completed',(shift/nRangeBins)*100);
%         msglength = length(msg);
%         disp([clear1 msg])
%         timeindicate = timeindicate+0.1;
%         clear1 = (repmat(sprintf('\b'), 1, msglength+1));
%     end
%     
%     FFTInput = zeros(NSamples, 1, 'single');
%     FFTOutput = zeros(NSamples, 1, 'single');
%     
%     FFTInput(1 + shift:NSamples) = ...
%         RefDataSimulatedTarget(1 + shift:NSamples) .* conj(ReferenceData(1:NSamples - shift));
% 
%     FFTInput = FFTInput .* Window; %window the result
%     
%     FFTOutput = fftshift(fft(FFTInput)); %FFT of the above product
%     
%     %Discard frequency bins not of interest
%     ARDMatrix(shift + 1,:) = FFTOutput(floor(NSamples / 2) + 1 - nDopplerBins:floor(NSamples / 2 ) + 1 + nDopplerBins);
% end
% toc
% %%
% fprintf('Plotting Result\n');
% 
% ARDMatrix = abs(ARDMatrix);  %Square law detector
% ARDMatrixTranspose = ARDMatrix.';
% 
% dopplerTicks = -MaxDoppler_Hz:(MaxDoppler_Hz)/(nDopplerBins):MaxDoppler_Hz; 
% rangeTicks = TxToRefRxDistance_m:(MaxRange_m-TxToRefRxDistance_m)/(nRangeBins):MaxRange_m-1;
% %%
% figure()
% surf(rangeTicks,dopplerTicks,20*log10(ARDMatrixTranspose./max(max(ARDMatrixTranspose))), 'EdgeAlpha', 0)
% axis([TxToRefRxDistance_m MaxRange_m -MaxDoppler_Hz MaxDoppler_Hz -100 0])
% colorbar
% colormap hot
% xlabel('Range [m]')
% ylabel('Doppler [Hz]')
% zlabel('Normalised Power [dB]')
% title(['ARD: ' File_name])