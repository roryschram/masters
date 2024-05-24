function [SNRest,Variance] = SNRestimate(Values)
% Description: Quick Estimate of SNR from FFT using 32K samples
% Inputs:  Values   - IQ data 
% Outputs: SNRest   - estimate of SNR as ratio
%          Variance - estimate of noise variance

Values_32KFFT = fftshift(fft(Values(1:32768)));
Values_32KFFT = Values_32KFFT/32768;
Values_32KFFT = abs(Values_32KFFT).^2; % Power of signal 

NFFT = 32768;
C_PS = 27265+2*288;
C_LOC=NFFT/2-(C_PS-1)/2+1:NFFT/2+(C_PS-1)/2+1; %

%Comparison of assumed active carriers to noise carriers.
Noisecarriers = Values_32KFFT([1:(C_LOC(1)-50) ,(C_LOC(end)+50):end]);
Noisepower = mean(Noisecarriers);
Activecarriers = Values_32KFFT(C_LOC(1+288):C_LOC(end-288));
Activepower = mean(Activecarriers);

SNRest = Activepower/Noisepower;
Variance = Noisepower;

disp('SNR Estimation Completed');
fprintf('SNR = %2.2f dB \r\n',10*log10(SNRest));
end