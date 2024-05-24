clear all; clc; close all;

addpath('../ARDMakers')

%% Load file object

inputRCFFilename = 'test.rcf';

oRCF = cRCF;
oRCF.readHeaderFromFile(inputRCFFilename);

% To simply extract the data from the .rcf file use:
% ref = oRCF.m_fvReferenceData
% surv = oRCF.m_fvSurveillanceData

%% Set parameters to read from file
Samples = 512; % This defines the number of samples to pull from the RCF file at a time
nCPIs = floor(oRCF.getNSamples() / Samples);
FFTSize = Samples;

%% Set loop parameters
FFTStart = 1;
CPInumber =  0;
plot(nan)
hold on

while(CPInumber < nCPIs)
    oCPIRCF = oRCF.readFromFile(inputRCFFilename, (CPInumber+1)*Samples, Samples);

    frequencyTicks = (-FFTSize/2:(FFTSize-1)/2)*oRCF.m_Fs_Hz/1e6/FFTSize;
    frequencyTicks = frequencyTicks + oRCF.m_Fc_Hz/1e6;

    Fref=fftshift(fft(oRCF.m_fvReferenceData(FFTStart:FFTStart + FFTSize - 1)));
    Fsurv=fftshift(fft(oRCF.m_fvSurveillanceData(FFTStart:FFTStart + FFTSize - 1)));
    %% Plot Reference ONLY
%     zeroRef = max(max(abs(Fref)));
%     figure(1)
%     cla
%     plot(frequencyTicks,20*log10(abs(Fref) / zeroRef))
%     grid on
%     xlabel({'Frequency [MHz]'});
%     ylabel({'Signal Power [dB]'});
%     title(['Reference Channel Spectrum'], 'Interpreter','none');
%     drawnow

%     %% Plot Surveillance ONLY
%     zeroSurv = max(max(abs(Fsurv)));
%     figure(2)
%     cla
%     plot(frequencyTicks,20*log10(abs(Fsurv) / zeroSurv))
%     grid on
%     xlabel({'Frequency [MHz]'});
%     ylabel({'Signal Power [dBm]'});
%     title(['Surveillance Channel'], 'Interpreter','none');
%     drawnow
        
    %% Plot ALL
    zeroRef = max(max(abs(Fref)));
    zeroSurv = max(max(abs(Fsurv)));
%   figure(3)
    cla
    plot(frequencyTicks,20*log10(abs(Fref) / zeroRef))
    plot(frequencyTicks,20*log10(abs(Fsurv) / zeroSurv))
    hold on

    grid on
    xlabel({'Frequency [MHz]'});
    ylabel({'Signal Power [dBm]'});
    title(['Surveillance Channels'], 'Interpreter','none');
    drawnow
    
    CPInumber = CPInumber +1;
%     pause(0.5)
end