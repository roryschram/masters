function DataSyms = DataFFT(Values,L1pre,DVBT2)
%Description: Get Data Cells in
% Inputs  Symbol - L1 pre parameters
%         Values - Iq Data 
%         DVBT2 - Data Symbol Parameters
% Ouputs: DataSyms - QAM symbol in Data symbols. Array
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2), p161

% Inputs: 
L = L1pre.GI*L1pre.S2;
NFFT = L1pre.S2;
GI = L1pre.GI;
C_PS = DVBT2.C_PS; % Active Carriers per  data symbol

DataSyms = Values(1:L1pre.numdatasymbols*(NFFT*(1+GI)));
DataSyms = DataSyms.';
DataSyms = reshape(DataSyms,[],L1pre.numdatasymbols);
DataSyms = DataSyms(L+1:end,:);

DataSyms = (sqrt(27*C_PS)/(5*NFFT))*fft(DataSyms,NFFT,1);
DataSyms = fftshift(DataSyms,1);
DataSyms = DataSyms(DVBT2.C_LOC,:); % Only active carriers considered
end