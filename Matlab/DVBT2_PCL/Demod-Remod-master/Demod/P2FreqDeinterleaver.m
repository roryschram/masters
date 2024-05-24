function [FreqdintP2] = P2FreqDeinterleaver(Values, P2, DVBT2,ChannelEst)
%Description: Frequency deinterleaver for P2 symbols
% Inputs: Values - IQ Data
%         P2 - P2 Parameters
%         DVBT2 - FFT size and MISO/SISO
%         ChannelEst - Channel estimate on P2 symbols
% Ouputs:
% Reference:
% References: Digital Video Broadcasting (DVB); Frame structure channel coding and modulation for a second generation digital terrestrial television broadcasting system (DVB-T2)

%Inputs
NFFT = DVBT2.nfft;
NP2 = P2.N_P2;

%Start
% Permutation Matrix
[HEven, HOdd] = P2FreqDintPermutation(NFFT,P2);
HEven = HEven(1:P2.C_P2);
HOdd = HOdd(1:P2.C_P2);
% Deinterleaving
FreqdintP2 = Values;

for i = 1:NP2
    if mod(i,2)
        FreqdintP2(i,HEven) = FreqdintP2(i, 1:P2.C_P2); %all even symbols (using indexing from guidelines)
    else
        FreqdintP2(i,HOdd) = FreqdintP2(i, 1:P2.C_P2); % all odd symbols
    end
end

if(isstruct(ChannelEst))
    ChannelFreqdint.H1 = ChannelEst.H1(:,P2.D_Loc);
    ChannelFreqdint.H2 = ChannelEst.H2(:,P2.D_Loc);
    
    for i =1:NP2
        if mod(i,2)
            ChannelFreqdint.H1(i,HEven) = ChannelFreqdint.H1(i, 1:P2.C_P2);
            ChannelFreqdint.H2(i,HEven) = ChannelFreqdint.H2(i, 1:P2.C_P2);
        else
            ChannelFreqdint.H1(i,HOdd) = ChannelFreqdint.H1(i, 1:P2.C_P2);
            ChannelFreqdint.H2(i,HOdd) = ChannelFreqdint.H2(i, 1:P2.C_P2);
        end
    end
else
    ChannelFreqdint = ChannelEst(:,P2.D_Loc);
    for i =1:NP2
        if mod(i,2)
            ChannelFreqdint(i,HEven) = ChannelFreqdint(i, 1:P2.C_P2);
        else
            ChannelFreqdint(i,HOdd) = ChannelFreqdint(i, 1:P2.C_P2);
        end
    end
end
end