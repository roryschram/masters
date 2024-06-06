function [dataindex, foffset, ioffset,P2_CPE, L1pre, L1post,L1presymbols,L1postsymbols,RemainingP2] = P2Handling(Values,DVBT2,SNR,Variance,p2start)
% Description: Synchronization in frequency and time and, determine L1 pre and L1 post
%References: 
%Inputs:  Values - IQ Data
%         DVBT2 - Parameters extracted from P1 (NFFT, miso/siso)
%         SNR - SNR ratio estimate
%         Variance - noise variance estimate
%         p2start - start of main part of P2 symbol
%Outputs: dataindex - start of main part of data symbols
%         foffset - estimated fraction freq offset
%         ioffset - estiamted interger freq offset
%         P2_CPE  - estimated common phase error
%         L1pre - L1 Pre parameters
%         L1post - L1 Post parameters
%         L1presymbols - L1 Pre BPSK Symbols
%         L1postsymbols - L1 Post QAM Symbols
%         RemainingP2 - Remaining P2 QAM Symbols after L1 pre and L1post QAM symbols

NFFT = DVBT2.nfft; %FFT Size
GI = DVBT2.gi; % Guard interval fraction
MISO = DVBT2.miso; %Miso enabled 1/0
L = round(GI*NFFT); %Length of guard inerval in samples
%% P2 Handling Process
%Key Parameters for P2 symbols
P2 = P2Parameters(NFFT,MISO);

%1. Coarse Time and Frequency offset
[P2start,foffset] = P2Synchronization(Values,GI,NFFT,SNR,p2start);
P2start = P2start-20; % 20 is arbritary value
if P2start<=0 % Fine timing will place give correct timing. Need to be in cyclic prefix
    P2start=1;
end

disp('Determine L1 Pre')

n = [0:length(Values)-1].';
Values = Values.*exp((1i*2*pi*(-foffset)*n)/NFFT); % fine frequency offset correction
%2. Integer Frequency offset
ioffset = P2IntegerOffset(Values(P2start:P2start+NFFT-1),P2);
Values = Values.*exp((1i*2*pi*(-ioffset)*n)/NFFT); % integer frequency offset correction
%3. Fine Time sync
P2start = P2FineTiming(Values(P2start:P2start+NFFT-1),P2,DVBT2,P2start,p2start);
%4. FFT
Values = P2FFT(Values(P2start-round(GI*NFFT):end),P2,NFFT,GI);
Values = Values.';
%5. Channel Estimation
[Values,ChannelEst,P2_CPE] = P2ChannelEst(Values, P2, DVBT2); %
%6. MISO Decoding
Values = P2Miso(Values, MISO, P2, ChannelEst);
%7. Frequency Deinterleaver
[Values] = P2FreqDeinterleaver(Values, P2, DVBT2,ChannelEst);
%8. L1pre handling (frame demapping,constellation demapping, depuncturing,ldpc,bch)
[L1pre, L1presymbols] = L1PreParameters(Values,Variance);
%9. L1post handling
[L1post,L1postsymbols]  = L1PostParameters(Values,P2,L1pre,Variance);

RemainingP2 = P2ExtraCells(Values,L1pre,P2); % Extract Remaining QAM symbols in P2 symbols

dataindex = p2start+((P2.N_P2)*(L+NFFT));
end