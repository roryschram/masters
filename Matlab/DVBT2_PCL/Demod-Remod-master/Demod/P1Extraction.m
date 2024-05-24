function [MISO, NFFT, guardint, p2start,DVBT2_corrected,FEF] = P1Extraction(DVBT2,index)
%Description: Decoding of P1 Symbol

%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2)

%Inputs:  DVBT2 - IQ data
%         index - index of Part A of P1 symbol
%Outputs: MISO  - MISO/SISO
%         NFFT  - FFT Size
%		  guardint - possible guard intervals. Used in Guardcorr
%		  p2start - Start of P2 symbol guard interval
%         DVBT2_corrected - IQ Data

P1symbol = fftshift(fft(DVBT2(index:index+1023)));
%Decode P1
[MISO, NFFT, FEF,guardint] = P1Decoding(P1symbol); % Get whether MISO enabled, FFT size and possible guard intervals

if strcmp(FEF,'FEF')
    disp('P1 Extraction: FEF Frame - Cannot demodulate. Move to next P1 \n')
end
p2start = index+1024+482-50; % Start of guard interval of P2 symbol. 50 (arbritary) sample offset for fine timing
DVBT2_corrected = DVBT2;
end