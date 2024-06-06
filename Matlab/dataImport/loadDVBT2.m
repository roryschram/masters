load('DVBT2_1K.mat')

figure()
plot(abs(fftshift(fft(Values))))

NFFT = 1024;
P1 = 2048;
P2 = NFFT;
G = NFFT*(1/8);

SingleSymbol = Values(P1+G+P2+G+1:P1+G+P2+G+NFFT);

figure()
plot(abs(fftshift(fft(SingleSymbol))))
