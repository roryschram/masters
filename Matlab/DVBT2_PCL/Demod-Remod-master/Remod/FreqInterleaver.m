function [P2Symbols, DataSymbols,FCSymbol] = FreqInterleaver(P2Symbols,DataSymbols,FCSymbol,L1pre,P2,DVBT2)
%Description: Frequency interleaving of qam symbols
% Inputs: P2Symbols - QAM symbols related to PLP
%         DataSymbols - QAM symbols related to Frame Closing (FC) Symbol 
%         FCSymbol  - QAM symbol fc symbol
%         L1pre - L1 pre paramters
%         P2 - P2 parameters
%         DVBT2 - Data symbol parameters
% Outputs: 
%         P2Symbols - QAM symbols related to PLP
%         DataSymbols - QAM symbols related to Frame Closing (FC) Symbol 
%         FCSymbol  - QAM symbol fc symbol
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2)

[P2HEven, P2HOdd] = P2FreqIntPermutation(DVBT2.NFFT,P2);
[DataHEven, DataHOdd,FC_HEven,FC_HOdd] = DataFreqIntPermutation(DVBT2.NFFT,DVBT2);

CPS= DVBT2.C_PS;
FCDataMap = zeros(1,CPS);
FCDataMap(DVBT2.FCTRLoc)=1;
FCDataMap(DVBT2.FCPLoc)=1;
FCDataMap = ~FCDataMap;

P2HEven = P2HEven(1:P2.C_P2);
P2HOdd = P2HOdd(1:P2.C_P2);
DataHEven = DataHEven(1:length(find(DVBT2.DataMap(1,:))));
DataHOdd = DataHOdd(1:length(find(DVBT2.DataMap(1,:))));

for i = 1:P2.N_P2
    if mod(i,2)
        P2Symbols(i,1:P2.C_P2) = P2Symbols(i, P2HEven); %all even symbols (using indexing from guidelines)
    else
        P2Symbols(i,1:P2.C_P2) = P2Symbols(i, P2HOdd); % all odd symbols
    end
end

FreqdintData = DataSymbols;
if DVBT2.L_FC
    FC_HOdd = FC_HOdd(1:length(find(FCDataMap)));
    FC_Heven = FC_HEven(1:length(find(FCDataMap)));
    for i = (DVBT2.N_P2+1):(L1pre.numdatasymbols+DVBT2.N_P2-1)
        if mod(i,2)
            FreqdintData(i-DVBT2.N_P2,1:length(find(DVBT2.DataMap(1,:)))) = DataSymbols(i-DVBT2.N_P2, DataHEven); %all even symbols (using indexing from guidelines)
        else
            FreqdintData(i-DVBT2.N_P2,1:length(find(DVBT2.DataMap(1,:)))) = DataSymbols(i-DVBT2.N_P2, DataHOdd); % all odd symbols
        end
    end
    
    if mod(L1pre.numdatasymbols+DVBT2.N_P2-1,2)
        FCSymbol(1:length(find(FCDataMap))) = FCSymbol(FC_HOdd); % Odd symbol frame closing
    else
        FCSymbol(1:length(find(FCDataMap))) = FCSymbol(FC_Heven); % Even symbol frame closing
    end
else
    for i = (DVBT2.N_P2+1):(L1pre.numdatasymbols+DVBT2.N_P2)
        if mod(i,2)
            FreqdintData(i-DVBT2.N_P2,1:length(find(DVBT2.DataMap(1,:)))) = DataSymbols(i-DVBT2.N_P2, DataHEven); %all even symbols (using indexing from guidelines)
        else
            FreqdintData(i-DVBT2.N_P2,1:length(find(DVBT2.DataMap(1,:)))) = DataSymbols(i-DVBT2.N_P2, DataHOdd); % all odd symbols
        end
    end
    FCSymbol = [];

end
DataSymbols = FreqdintData;
end
