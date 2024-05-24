%%Editable paramaters
nSamples = 819200;
strFilename1 = 'Malmesbury_1.rcf';
strFilename2 = 'Tygerberg_1.rcf';
strDataLabel1 = 'Malmesbury';
strDataLabel2 = 'Tygerberg';

oRCF1 = readRCFFromFile(strFilename1, 5000000, nSamples);
oRCF2 = readRCFFromFile(strFilename2, 5000000 , nSamples);

FFTStart = 1;
FFTSize = oRCF1.getNSamples();

frequencyTicks = (-FFTSize/2:(FFTSize-1)/2)*oRCF1.m_Fs_Hz/1e6/FFTSize;
frequencyTicks = frequencyTicks + oRCF1.m_Fc_Hz/1e6;

Fref1=fftshift(fft(oRCF1.m_fvReferenceData(FFTStart:FFTStart + FFTSize - 1)));
Fref2=fftshift(fft(oRCF2.m_fvReferenceData(FFTStart:FFTStart + FFTSize - 1)));

zeroRef = max([max(abs(Fref1)) max(abs(Fref2))]);

figure
subplot(1,2,1)
plot(frequencyTicks,20*log10(abs(Fref1) / zeroRef))
xlabel({'Frequency [MHz]'});
ylabel({'Signal Power [dB]'});
title([strDataLabel1 ' - Reference Channel'], 'Interpreter','none');

subplot(1,2,2)
plot(frequencyTicks,20*log10(abs(Fref2) / zeroRef))
xlabel({'Frequency [MHz]'});
ylabel({'Signal Power [dB]'});
title([strDataLabel2 ' - Reference Channel'], 'Interpreter','none');

Fsurv1=fftshift(fft(oRCF1.m_fvSurveillanceData(FFTStart:FFTStart + FFTSize - 1)));
Fsurv2=fftshift(fft(oRCF2.m_fvSurveillanceData(FFTStart:FFTStart + FFTSize - 1)));

zeroRef = max([max(abs(Fsurv1)) max(abs(Fsurv2))]);

figure
subplot(1,2,1)
plot(frequencyTicks,20*log10(abs(Fsurv1) / zeroRef))
xlabel({'Frequency [MHz]'});
ylabel({'Signal Power [dBm]'});
title([strDataLabel1 ' - Surveillance Channel'], 'Interpreter','none');

subplot(1,2,2)
plot(frequencyTicks,20*log10(abs(Fsurv2) / zeroRef))
xlabel({'Frequency [MHz]'});
ylabel({'Signal Power [dBm]'});
title([strDataLabel2 ' - Surveillance Channel'], 'Interpreter','none');
