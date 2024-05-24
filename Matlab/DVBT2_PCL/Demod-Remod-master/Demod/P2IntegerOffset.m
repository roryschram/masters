function ioffset = P2IntegerOffset(P2_FFT,P2)
% Description: Estimate Interger frequency offset through cross correlation
%               of frequency domain P2 pilots and received symbol. Index of
%               peak corresponds
% Inputs: P2_FFT: NP2 P2 FFT symbols (column vector)
%         P2:     P2 Parameters
% Outputs: ioffset: estimate of integer frequency offset by cross
% correlation
% References:  Improved synchronization, channel estimation, and simplified LDPC decoding for the physical layer of the DVB-T2 receiver

P2_FFT = fftshift(fft(P2_FFT));
%% Split pilot sets into halves and cross correlate
minrange = -15; 
maxrange = 15;
M = zeros(1,length(minrange:1:maxrange));
ioffsetrange = minrange:1:maxrange;


for i = 1:length(ioffsetrange)
    c = P2_FFT(P2.C_LOC_EXT(1)-1+P2.Set1+ioffsetrange(i)).*conj(P2_FFT(P2.C_LOC_EXT(1)-1+P2.Set2+ioffsetrange(i)));
    M(i) = sum(c);
end

if (mean(M(10:21))<mean([M(1:9) M(22:end)])),M=M*-1;end
ioffset = ioffsetrange((M==max(M)));
disp('P2 Integer Frequency Offset Estimation Completed');
fprintf('Integer offset (in number of frequency bins): %d \n',ioffset);
end
