function [P2start, cfreq] = P2Synchronization(Values,GI,NFFT,SNR,p2start)
%Description: Synchronization of P2 symbol in time and frequency 
%Input: Values - IQ Data
%		GI     - Guard interval
%       NFFT   - FFT Size
%       SNR    - SNR ratio estimate
%       p2start - start of p2 symbol inferred from P1 detection

%Output: P2Start - Start of use part of P2 symbol
%		 cfreq   - fractional frequency offset

% References: ML Estimation of Time and Frequency Offset in OFDM Systems - For Coarse Timing and Frequency
%           : A Channel Characterization Technique Using Frequency Domain Pilot Time Domain Correlation Method for DVB-T Systems


L = round(GI*NFFT); %Length of guard inerval in samples
snr = SNR; %SNR
Nsym = 4; % Number of symbols used to estimate timing
r = Values; 

PHI_sum = zeros(1,Nsym*(NFFT+L)-NFFT); % 
GM_sum = zeros(1,Nsym*(NFFT+L)-NFFT);

for n = 1:Nsym*(NFFT+L)-(NFFT+L)
    PHI=0;GM=0;
    for m = n:n+L-1    
        PHI = PHI+ (r(m)*conj(r(m)) + r(m+NFFT)*conj(r(m+NFFT)));
        GM = GM+ r(m)*conj(r(m+NFFT));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
    end
    PHI_sum(n) = abs(GM)- (snr/(snr+1))*PHI;
    GM_sum(n) = -angle(GM)/(2*pi);
end

[~,Coarse_time_index]=findpeaks(PHI_sum,'minpeakdistance',NFFT);
Coarse_time_index = Coarse_time_index(1);
P2start = Coarse_time_index-1+L;
cfreq = GM_sum(Coarse_time_index);

disp('Coarse timing and Fine Frequency Estimation Completed')
disp(sprintf('P2 Coarse time estimate (start of cyclic prefix): %d',Coarse_time_index-1+p2start))
disp(sprintf('P2 Fractional Frequency Offset: %d',cfreq))

end






