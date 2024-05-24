function [PLPValues,FCValues,RemainingP2,Data_CPE,FC_CPE,DVBT2] = DataHandling(Values,Start,SNR,Variance,L1pre,L1post,dataindex,RemainingP2)
%Description: Get Data Cells in
%Inputs:  Values - IQ Data
%         Start - Parameters extracted from P1 (NFFT, miso/siso)
%         SNR - SNR ratio estimate
%         Variance - noise variance estimate
%         p2start - start of main part of P2 symbol
%         L1pre - L1 Pre parameters
%         L1post - L1 Post parameters
%         dataindex - start of main part of data symbols 
%         RemainingP2 - Remaining P2 QAM Symbols after L1 pre and L1post QAM symbols
%Outputs: 
%         PLPValues - QAM symbols related to PLP
%         FCValues - QAM symbols related to Frame Closing (FC) Symbol 
%         P2_CPE  - estimated common phase error
%         RemainingP2 - Remaining P2 QAM Symbols after L1 pre and L1post QAM symbols
%         Data_CPE - Data Symbols Common Phase Error Estimate
%         FC_CPE - Frame Closing Symbol CPE
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2), p161

%Inputs: DVBT2 - 1024 FFT of P1 symbol

%Background Parameters for Data Symbols
DVBT2 = DVBT2Parameters(L1pre,L1post);

NFFT = Start.nfft;
L = Start.gi*NFFT;
MISO = Start.miso;

%1. Coarse Time and Frequency
[Datastart, foffset] = DataSynchronization(Values(1:(5*NFFT+L)),L1pre,DVBT2,SNR,dataindex);
Datastart1 = Datastart-20; % 20 is arbritary value
if Datastart1<=0 % Fine timing will place give correct timing. Need to be in cyclic prefix
    Datastart1=1;
end
n = [0:length(Values)-1].';
Values = Values.*exp((1i*2*pi*(-foffset)*n)/NFFT);
%2. Integer Frequency
ioffset = DataIntegerOffset(Values(Datastart:(Datastart+DVBT2.NFFT-1)),DVBT2);
Values = Values.*exp((1i*2*pi*(-ioffset)*n)/NFFT);
%3. Fine time 
FineDatastart = DataFineTiming(Values(Datastart1:(Datastart1+DVBT2.NFFT-1)),DVBT2,Datastart1,dataindex);
%4. FFT
Values = DataFFT(Values(FineDatastart-L:end),L1pre,DVBT2);
Values = Values.'; %row vector
%4. Channel Estimate
[Values,ChannelEst,Data_CPE,FC_CPE] = DataChannelEst(Values, L1pre,DVBT2);
%5. MISO Decoding
[Values,FCValues] = DataMiso(Values, MISO, L1pre,DVBT2, ChannelEst);
%6. Frequency Deinterleaver
[Values, FCValues] = DataFreqDeinterleaver(Values,FCValues,L1pre,DVBT2);
%7. QAM Demapper
[PLPValues,FCValues,RemainingP2,DVBT2] = QAMDemapper(Values,FCValues,L1pre,L1post,DVBT2,RemainingP2);

end