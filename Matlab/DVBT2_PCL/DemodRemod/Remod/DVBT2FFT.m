function TimeFrame = DVBT2FFT(Frame,L1pre,DVBT2,P2)
%Description: FFT of data and P2 symbols
% Inputs: Frame - Frame in frequency domain
%         L1pre - L1 pre parameters
%         DVBT2 - Data symbol parameters
%         P2 - P2 symbol parameters
% Outputs: TimeFrame - Frame in sample domain
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2)

TimeFrame = zeros(DVBT2.NFFT,P2.N_P2+L1pre.numdatasymbols);

for i = 1:(P2.N_P2+L1pre.numdatasymbols)
    TimeFrame(DVBT2.C_LOC,i) = Frame(i,:).';
end

TimeFrame = ifftshift(TimeFrame,1);

TimeFrame = 5/sqrt(27*DVBT2.C_PS)*DVBT2.NFFT*ifft(TimeFrame,DVBT2.NFFT,1);
%Time Frame columns are different symbols, rows are frequency bins


end