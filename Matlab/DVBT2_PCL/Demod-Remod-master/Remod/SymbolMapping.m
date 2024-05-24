function [P2Symbols,DataSymbols,FCSymbol] = SymbolMapping(PLPValues,FCValues,RemainingP2,L1presymbols,L1postsymbols,P2,DVBT2)
% Description: Synchronization in frequency and time and, determine L1 pre and L1 post
%Inputs:  PLPValues - PLP QAM symbols
%         FCValues - Frame Closing symbol qam symbols
%         RemainingP2 - SNR ratio estimate
%         L1presymbols - L1 pre qam symbols
%         L1postsymbols - L1 post qam symbols
%         P2 - P2 symbol parameters
%         DVBT2 - Data symbol parameters
%Outputs: 
%         P2Symbols - QAM symbols related to PLP
%         DataSymbols - QAM symbols related to Frame Closing (FC) Symbol 
%         FCSymbol  - QAM symbol fc symbol
%Reference:
%P2 Symbols
P2Data = length(P2.D_Loc);
P2Symbols = zeros(P2.N_P2,P2Data);
L1 = [L1presymbols,L1postsymbols];
P2Symbols(1:length(L1))=L1;
RemainingP2 = RemainingP2.';
RemainingP2 = reshape(RemainingP2,[],P2.N_P2);

for i=0:P2.N_P2-1 
    P2Symbols(i+1,(length(L1)+1):P2.N_P2:end)=RemainingP2(:,i+1);
end

%Data Symbols
DataSymbols = PLPValues;

%Frame Closing Symbols
if DVBT2.L_FC
    FCSymbol = FCValues;
else
    FCSymbol = [];
end

end