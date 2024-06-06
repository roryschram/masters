ofdmSignalNoNoise = waveStruct2Syms.waveform;
FFTNoNoise = fftshift(fft(ofdmSignalNoNoise(2:257)));

ofdmSignalNoise = waveStruct128QAM.waveform;
FFTNoise = fftshift(fft(ofdmSignalNoise(1:256)));

INoNoise = real(FFTNoNoise);
QNoNoise = imag(FFTNoNoise);

INoise = real(FFTNoise);
QNoise = imag(FFTNoise);


figure();
subplot(2,2,1);
plot(abs(FFTNoNoise));
subtitle("FFT of OFDM Waveform with No Noise");
xlabel("Frequency Bins");
ylabel("Amplitude");

subplot(2,2,3)
scatter(INoNoise,QNoNoise,"filled","o")
subtitle("QAM Constelation Map of Data without Noise");
xlabel("In-Phase Amplitude");
ylabel("Quadrature Amplitude");


% Plot noisy data
subplot(2,2,2)
plot(abs(FFTNoise))
subtitle("FFT of OFDM Waveform with Noise");
xlabel("Frequency Bins");
ylabel("Amplitude");

subplot(2,2,4)
scatter(INoise,QNoise,"filled","o")
subtitle("QAM Constelation Map of Noisy Data");
xlabel("In-Phase Amplitude");
ylabel("Quadrature Amplitude");