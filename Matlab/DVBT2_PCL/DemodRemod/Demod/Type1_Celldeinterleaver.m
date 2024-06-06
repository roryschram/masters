function [PLP_cdint, DVBT2] = Type1_Celldeinterleaver(PLP_tdint,L1post,TI_blockindex,PLP_number, DVBT2)
%Description: Gives index for Beginning of P1 and estimate of fractional frequency offset
% Inputs: PLP_tdint - Time deinterleaved PLP
%         L1post - L1 post parameters
%         TI_blockindex - TI Block index
%         PLP_number - PLP number
% Ouputs: PLP_cdint - cell deinterleaved PLP
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2)

plpblocks = L1post.dynamic.plp(PLP_number).plp_numblocks;
feclength = L1post.config.plp(PLP_number).plp_fec_type; % 64800 or 16200
time_iltype = L1post.config.plp(PLP_number).time_il_type;
cellsperblock = feclength/L1post.config.plp(PLP_number).plp_V; % V = number of bit cell e.g. 256qam = 8 bits

degree = ceil(log2(cellsperblock));
totalstates = 2.^(degree);

if time_iltype == 0
    NTI = L1post.config.plp(PLP_number).time_il_length;
else
    NTI = 1;
end

NFEC_TI = ones(1,NTI); %Number of FEC blocks per TI block

for s = 0:(NTI-1)
    if s<(NTI-(mod(plpblocks,NTI))),NFEC_TI(s+1) = floor(plpblocks/NTI);
    else
        NFEC_TI(s+1) = ceil(plpblocks/NTI);
    end
end
%% Generate permutation function for Cell interleaver
switch degree
      case 11
        logic = [ 1 4 ];
      case 12
        logic = [ 1 3 ];
      case 13
        logic = [ 1 2 5 7 ];
      case 14
        logic = [ 1 2 5 6 10 12 ];
      case 15
        logic = [ 1 2 3 13 ];
end

%calculate LFSR permutations
lfsr = [];
L0q = zeros(1, cellsperblock);    % pre-allocate memory

p = 1;
for i = 0:totalstates-1
    toggle = mod(i,2);
    
    if (i == 0 || i == 1)
        lfsr = zeros(1, degree-1);
    elseif i == 2
        lfsr = [ 1 zeros(1, degree-2) ];
    else
        for i1 = 1:length(logic)-1
            if i1==1
                alfa = lfsr(logic(i1));
            else
                alfa = logic_result;
            end
            beta = lfsr(logic(i1+1));
            logic_result = xor(alfa,beta);
        end
        lfsr = [lfsr(2:degree-1) logic_result ]; % shift calculated bit into MSB
    end
    
addressVector = [ lfsr toggle ];
addressDecimal = bi2de(addressVector);

if (addressDecimal < cellsperblock)
    L0q(p) = addressDecimal;
    p = p + 1;
end
end

%% Extract TI block, cell deinterleave, rotate and hard decision
for s = 1:NTI % index for TI block
    %A. Extract TI block
    k = 0;
    CellsinTIblock = cellsperblock*NFEC_TI(s);
    linearindex = (TI_blockindex(s)-1)*cellsperblock+1;
    
    
    TIBlock = PLP_tdint(linearindex:(linearindex+CellsinTIblock-1));
    
    %B. Reshape into columns of FEC blocks and cell deinterleave
    TIBlock = reshape(TIBlock,cellsperblock,NFEC_TI(s));
    
    for r = 0:NFEC_TI(s)-1
        shift = cellsperblock;  % do this to force the 'while' to fire once
        % value will get overwritten anyway
        while shift >= cellsperblock,
            N_binary = de2bi(k, degree);
            shift = bi2de(N_binary, 'left-msb');
            k = k + 1;
        end
        
        Lrq = mod(L0q+shift,cellsperblock);
        
        TIBlock(:,r+1) = TIBlock(Lrq+1,r+1);
    end
    
    %C. Remove rotation and Cyclic q delay
    if L1post.config.plp(PLP_number).plp_rotation
        TIBlockreal = real(TIBlock);
        TIBlockimag = imag(TIBlock);
        TIBlockimag = TIBlockimag([2:(end) 1],:);
        TIBlock = TIBlockreal+1i*TIBlockimag;
%         TIBlock = TIBlock*exp(1i*2*pi*(-1)*(L1post.config.plp(PLP_number).rot_angle));
        TIBlock = TIBlock*exp(1i*(-1)*(L1post.config.plp(PLP_number).rot_angle));
		DVBT2.rawQAM(s).TIBlock = TIBlock;
    end
    
    %D. Hard decision
    for i = 1:NFEC_TI(s)
        Fecblock = TIBlock(:,i)*L1post.config.plp(PLP_number).plp_C;
        for i1 = 1:cellsperblock
            qamsymbol = Fecblock(i1);
            qamsymbol = sqrt((real(qamsymbol)-real(L1post.config.plp(PLP_number).plp_Cpoints)).^2+...
                             (imag(qamsymbol)-imag(L1post.config.plp(PLP_number).plp_Cpoints)).^2);
            [~,qamsymbol] = min(qamsymbol);
%			  Fecblock(i1)= L1post.config.plp(PLP_number).plp_Cpoints(qamsymbol)/L1post.config.plp(PLP_number).plp_C;																							 
            Fecblock(i1)= L1post.config.plp(PLP_number).plp_Cpoints(qamsymbol);
        end
        TIBlock(:,i)= Fecblock/L1post.config.plp(PLP_number).plp_C;
		DVBT2.demodQAM(s).TIBlock = TIBlock;
    end
    
	% START OF REMOD PROCESS - SHIFTS THINGS BACK TO THE WAY THEY ARE WHEN TRANSMITTED
    %E. Rotation and Cyclic Q delay
    if L1post.config.plp(PLP_number).plp_rotation
		TIBlock = TIBlock*exp(1i*(L1post.config.plp(PLP_number).rot_angle));																	
        TIBlockreal = real(TIBlock);
        TIBlockimag = imag(TIBlock);
        TIBlockimag = TIBlockimag([end 1:(end-1)],:);
        TIBlock = TIBlockreal+1i*TIBlockimag;
%        TIBlock = TIBlock*exp(1i*2*pi*(L1post.config.plp(PLP_number).rot_angle));
    end
    
    %F. Reshape into columns of FEC blocks and cell interleave
    k=0;
    for r = 0:NFEC_TI(s)-1
        shift = cellsperblock;  % do this to force the 'while' to fire once
        % value will get overwritten anyway
        while shift >= cellsperblock,
            N_binary = de2bi(k, degree);
            shift = bi2de(N_binary, 'left-msb');
            k = k + 1;
        end
        
        Lrq = mod(L0q+shift,cellsperblock);
        TIBlock(Lrq+1,r+1) = TIBlock(:,r+1);
    end
    TIBlock = reshape(TIBlock,[],1);
    %G. Add Corrected terms back to symbols
    PLP_tdint(linearindex:(linearindex+CellsinTIblock-1)) = TIBlock;
    
end
PLP_cdint=PLP_tdint;
end