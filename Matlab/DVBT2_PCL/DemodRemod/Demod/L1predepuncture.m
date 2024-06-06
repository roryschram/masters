function L1preLLR16200 = L1predepuncture(LLR)
%Description: L1 pre depuncturing (adding in bits that were removed)
% Inputs: LLR - Log Proability QAM symbols for L1 pre
%References: Implementation guidelines

% determine zeros are padded and punctured bits

Npunc = 11488;
Kldpc = 3240;
Npuncgroups = floor(Npunc/360);

%1. Determine which bits were zero added bits and which were punctures
%1.1 Determine zero bits in Kbch

L1pre_zeroindecies = 201:3072;

Puncturebitindices = zeros(1,12960);
Permutationsequence = [27 13 29 32 5 0 11 21 33 20 25 28 18 35 8 3 9 31 22 24 7 14 17 4 2 26 16 34 19 10 12 23 1 6 30 15]+1; %matlab indexing

for i = 0:359
Puncturebitindices(Permutationsequence(1:Npuncgroups)+(i*36))=1;
end

Puncturebitindices(Permutationsequence(Npuncgroups+1)+(0:327)*36)=1;

L1pre_puncturebitindices = find(Puncturebitindices==1)+3240;

L1preLLR16200 = ones(1,16200);
L1preLLR16200(L1pre_zeroindecies) = 10; %very confident that these are zeros
L1preLLR16200(L1pre_puncturebitindices)=0.1; %modelled as erasures in LLR (should be zero, small number represents low confidence)
L1preLLR16200(L1preLLR16200==1) = LLR; % all remaining bits are filled by transmitted LLR in order to reform orginal 16200 bit FEC block

end