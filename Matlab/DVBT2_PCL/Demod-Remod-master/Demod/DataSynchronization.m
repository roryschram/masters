function [Datastart, foffset] = DataSynchronization(Values,L1pre,DVBT2,SNR,dataindex)
% Inputs: Values - received QAM symbols of L1 post
%         L1pre - L1 pre parameters
%         DVBT2 - Data Symbol Parameters
%         SNR - SNR ratio estimate
%         dataindex - index of main part of first data symbol (internal to function)
% Ouputs: Datastart - index of main part of first data symbol (external to function)
%         foffset - fraction freq offset estimated
% Reference:
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2), p161

%Inputs: DVBT2 - 1024 FFT of P1 symbol

%Background Parameters for Data Symbols
%Input
NFFT = DVBT2.NFFT; %FFT Size
GI = L1pre.GI; % Guard interval fraction
L = round(GI*NFFT); %Length of guard inerval in samples
snr = SNR; %SNR
Nsym = 4;
%% Coarse time start and fine frequency estimate
r = Values; 

PHI_sum = zeros(1,Nsym*(NFFT+L)-NFFT);
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
Datastart = Coarse_time_index-1+L;
foffset = GM_sum(Coarse_time_index);

disp('Data Coarse timing and Fine Frequency Estimation Completed')
fprintf('Data Coarse time estimate (start of cyclic prefix): %d \n',Coarse_time_index-1+dataindex)
fprintf('Data Fractional Frequency Offset: %d \n',foffset)



end