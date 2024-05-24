function [FreqdintData, Freqdint_FC] = DataFreqDeinterleaver(Values,FCValues,L1pre,DVBT2)
%Description: Frequency deinterleaver for Data symbols
% Inputs: Values - QAM data symbols
%         FCValues - Frame Closing Symbol QAM symbols 
%         DVBT2 - Data Symbol Parameters
%         L1pre - L1 pre parameters
% Ouputs: FreqdintData - Freq deinterleaved data symbols
%         Freqdint_FC - Freq deinterleaved FC symbol

% References: Digital Video Broadcasting (DVB); Frame structure channel coding and modulation for a second generation digital terrestrial television broadcasting system (DVB-T2)

%Inputs
NFFT = DVBT2.NFFT;
NData =L1pre.numdatasymbols;
Cdata = length(find(DVBT2.DataMap(1,:)));

CPS= DVBT2.C_PS;
FCDataMap = zeros(1,CPS);
FCDataMap(DVBT2.FCTRLoc)=1;
FCDataMap(DVBT2.FCPLoc)=1;
FCDataMap = ~FCDataMap;
NFC = length(find(FCDataMap)); %Number of data carriers in FC symbol


%Start
% Permutation Matrix
[HEven, HOdd,FC_HEven,FC_HOdd] = DataFreqDintPermutation(NFFT,DVBT2);
HEven = HEven(1:Cdata);
HOdd = HOdd(1:Cdata);


% Deinterleaving
FreqdintData = Values;
if DVBT2.L_FC
    FC_HEven = FC_HEven(1:NFC);
    FC_HOdd = FC_HOdd(1:NFC);
    for i = DVBT2.N_P2+1:NData+DVBT2.N_P2-1
        if mod(i,2)
            FreqdintData(i-DVBT2.N_P2,HEven) = Values(i-DVBT2.N_P2, 1:Cdata); %all even symbols (using indexing from guidelines)
        else
            FreqdintData(i-DVBT2.N_P2,HOdd) = Values(i-DVBT2.N_P2, 1:Cdata); % all odd symbols
        end
    end
    Freqdint_FC = FCValues;
    if mod(NData+DVBT2.N_P2,2)
        Freqdint_FC(FC_HEven) = FCValues(1:NFC); % Eve
    else
        Freqdint_FC(FC_HOdd) = FCValues(1:NFC);
    end
else
    for i = DVBT2.N_P2+1:NData+DVBT2.N_P2
        if mod(i,2)
            FreqdintData(i-DVBT2.N_P2,HEven) = Values(i-DVBT2.N_P2, 1:Cdata); %all even symbols (using indexing from guidelines)
        else
            FreqdintData(i-DVBT2.N_P2,HOdd) = Values(i-DVBT2.N_P2, 1:Cdata); % all odd symbols
        end
    end
    Freqdint_FC = [];

end
end