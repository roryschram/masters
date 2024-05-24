function P2Syms = P2FFT(Values,P2,NFFT,GI)
%Description: Extract QAM Symbols for each P2 symbol
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2), p161

%Inputs: Values - IQ Data
%        P2 - P2 Parameters
%        NFFT  - FFT size
%        GI - Gaurd interval fraction
%Outputs: P2Syms - Array of QAM Symbols. Row - P2 Symbols; Col - QAM Symbols
	L = GI*NFFT;
% 
	P2Syms = Values(1:P2.N_P2*(NFFT*(1+GI)));
	P2Syms = P2Syms.';
	P2Syms = reshape(P2Syms,[],P2.N_P2); %Columns of P2 sample(s)
	P2Syms = P2Syms(L+1:end,:); % Remove Guard Interval
	
	P2Syms = (sqrt(27*P2.C_PS)/(5*NFFT))*fft(P2Syms,NFFT,1);
	P2Syms = fftshift(P2Syms,1);
	P2Syms = P2Syms(P2.C_LOC,:); % Only active carriers considered 
	
    disp('P2 FFT Completed');
    fprintf('Number of P2 symbols: %d \n', P2.N_P2);
	
end