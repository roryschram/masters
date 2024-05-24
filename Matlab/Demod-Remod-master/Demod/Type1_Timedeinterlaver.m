function [TimeDint_Values,Tiblockstart] = Type1_Timedeinterlaver(PLP,L1post,PLP_number)
%Description: Gives index for Beginning of P1 and estimate of fractional frequency offset
% Inputs: PLP - QAM symbols in PLP
%         L1post - L1 post parameters
%         PLP_number - PLP number
% Ouputs: TimeDint_Values - Time deinterleaved PLP
%         Tiblockstart - start of TI block
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2)

plpstart = L1post.dynamic.plp(PLP_number).plp_start+1; %index corresponding to first cell of plp
plpblocks = L1post.dynamic.plp(PLP_number).plp_numblocks;
plptype = L1post.config.plp(PLP_number).plp_type; % Common, type 1 or type 2
plpmod = L1post.config.plp(PLP_number).plp_mod; % modulation order of plp (QPSK, 16QAM ,higher)
feclength = L1post.config.plp(PLP_number).plp_fec_type; % 64800 or 16200
time_iltype = L1post.config.plp(PLP_number).time_il_type;
cellsperblock = feclength/L1post.config.plp(PLP_number).plp_V; % V = number of bit cell e.g. 256qam = 8 bits
if time_iltype == 0
    PI = 1;
    NTI = L1post.config.plp(PLP_number).time_il_length;
else
    PI = L1post.config.plp(PLP_number).time_il_length;
    NTI = 1;
end

NFEC_TI = ones(1,NTI); %Number of FEC blocks per TI block

for s = 0:(NTI-1)
    if s<(NTI-(mod(plpblocks,NTI))),NFEC_TI(s+1) = floor(plpblocks/NTI);
    else
        NFEC_TI(s+1) = ceil(plpblocks/NTI);
    end
end
Tiblockstart = ones(1,NTI); % 1st cell in current Ti block of plp

for s = 1:NTI % index for TI block
    CellsinTIblock = cellsperblock*NFEC_TI(s);
    numCols = cellsperblock/5;
    numRows = 5*NFEC_TI(s);
    
    linearindex = (Tiblockstart(s)-1)*cellsperblock+1;
    
    TIBlock = PLP(linearindex:(linearindex+CellsinTIblock-1));
    Tiblockstart(s+1) = Tiblockstart(s)+NFEC_TI(s);
    
    interleavingTable = reshape(TIBlock, numRows, numCols);
    interleavingTable = interleavingTable.';
%     PLP(Tiblockstart(s):Tiblockstart(s)+CellsinTIblock-1) = interleavingTable(:); 
    PLP(linearindex:linearindex+CellsinTIblock-1) = interleavingTable(:);
end
Tiblockstart = Tiblockstart(1:length(NFEC_TI));
TimeDint_Values = PLP;
end