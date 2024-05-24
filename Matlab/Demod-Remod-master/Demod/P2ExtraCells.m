function RemainingP2 = P2ExtraCells(Values,L1pre,P2)
%Description: Extracts remaining P2 Cells
% Inputs: Values - QAM Symbols
%         P2 - P2 Parameters
%         L1pre - L1 pre parameters
% Ouputs: RemainingP2 - 
% Reference:
L1postsize = L1pre.L1postsize;
Remaining = Values(1841+L1postsize:end);
RemainingP2 = [];
for i = 1:P2.N_P2
    if i==1
        RemainingP2 = Remaining(i:P2.N_P2:end);
    else
        RemainingP2 = [RemainingP2, Remaining(i:P2.N_P2:end)];
    end
end
end