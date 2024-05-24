function [L1, L1prebitstream] = L1PreParameters(Values,Variance)
%Description: Gets L1 pre parameters for decoding of L1 post signalling
%Reference: Implementation guidelines of DVB-T2
% Inputs: Values - IQ Data
%         P2 - P2 Parameters
%         ChannelEst - Channel estimate
%         Variance - estimated noise variance
% Outputs: L1 - L1pre parameters
%          L1prebitstream - L1 pre QAM symbols
L1presymbols = Values(1:1840);

%BPSK Demapping
[L1prebitstream, LLRChannel] = L1predemapping(L1presymbols,Variance);
L1prebitstream(L1prebitstream==1)=-1;
L1prebitstream(L1prebitstream==0)=1; % Symbols of L1pre

%Depuncture and deshorten
L1pre16200 = L1predepuncture(LLRChannel); %6200 bits long

%LDPC decoding
L1_NBch_3240 = L1preLDPCdecoding(L1pre16200); %3240 bits long

%BCH decoding
L1_NBch_3072 = L1preBCHdecoding(L1_NBch_3240); %3072 bits long
L1pre_ksig = L1_NBch_3072(1:200); %first 200 bits correspond to signal bits

%L1 pre parameters (200 bit stream)
L1 = L1predecoding(L1pre_ksig);

disp('L1 Pre Paramters Acquired')
disp('Obtaining L1 Post Parameters...')
end