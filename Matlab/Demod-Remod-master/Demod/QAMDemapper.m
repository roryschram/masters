function [PLPValues,FCValues,RemainingP2,DVBT2] = QAMDemapper(Values,FCValues,L1pre,L1post,DVBT2,RemainingP2)
%Description: Gives index for Beginning of P1 and estimate of fractional frequency offset
% Inputs: Values - QAM symbols on Data symbols
%         FCValues - FC QAM symbols
%         L1pre - L1 pre parameters
%         L1post - L1 post parameters
%         DVBT2 - Data Symbol Parameters
%         RemainingP2 - QAM symbols after L1 pre+L1post in P2 symbols
% Ouputs: PLPValues - QAM symbols in PLP
%         FCValues - FC QAM symbols
%         RemainingP2 - QAM symbols after L1 pre+L1post in P2 symbols
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2)

numplp = L1post.config.Num_plp; % number of plp

% Values = reshape(Values,1,[]); % changes to row

Values = Values.';
Values = reshape(Values,1,[]);
DataCells = [RemainingP2 Values FCValues]; % All Data cells in frame
Nsubslices = L1post.config.Sub_slices_per_frame;
subsliceinterval = L1post.dynamic.subslice_interval;
%Count used cells in frame
Num_usedcellsinframe = 0;
for i = 1:numplp
    feclength = L1post.config.plp(i).plp_fec_type; % 64800 or 16200
    if isempty(L1post.config.plp(i).plp_V)
        cellsperblock = feclength/1;
    else
        cellsperblock = feclength/L1post.config.plp(i).plp_V; % V = number of bit cell e.g. 256qam = 8 bits
    end
    Num_usedcellsinframe = Num_usedcellsinframe + ((L1post.dynamic.plp(i).plp_numblocks)*(cellsperblock)); 
end

Num_dummycells = (length(RemainingP2)+length(Values)+length(FCValues)-DVBT2.C_FC)-Num_usedcellsinframe; % Number of dummy cells in DVBT2 frame either 1 or -1
if Num_dummycells<0,Num_dummycells=1;end
%%
for i = 1:numplp
    % for each plp
    plpstart = L1post.dynamic.plp(i).plp_start+1; %index corresponding to first cell of plp
    plpblocks = L1post.dynamic.plp(i).plp_numblocks;
    plptype = L1post.config.plp(i).plp_type; % Common, type 1 or type 2
    plpmod = L1post.config.plp(i).plp_mod; % modulation order of plp (QPSK, 16QAM ,higher)
    feclength = L1post.config.plp(i).plp_fec_type; % 64800 or 16200
    time_iltype = L1post.config.plp(i).time_il_type;
    if strcmp(plpmod,'Undefined'),continue;end
    cellsperblock = feclength/L1post.config.plp(i).plp_V; % V = number of bit cell e.g. 256qam = 8 bits
    if time_iltype == 0
        PI = 1;
    else
        PI = L1post.config.plp(i).time_il_length;
    end
    
    %if time interleaving performed across multiple frames, ignore data
    %symbols
    
    if PI>1, continue;end
    
    if strcmp(plptype,'Type 2 PLP')
        % Type 2 PLP
        % Time il length == number of t2 frames to which each interleaving
        % frame is mapped
        PLP = [];
        for i1 = 0:(Nsubslices-1)
            subslice_start = plpstart+i1*subsliceinterval;
            subslice_end = subslice_start+((plpblocks*cellsperblock)/(Nsubslices*PI))-1;
            if subslice_end>length(DataCells)
                fprintf('QAM Demapping: Type 1 - Length of PLP %d in L1 post is greater than frame length. Data cells untouched \r\n',i)
            end
            PLP = [PLP DataCells(subslice_start:subslice_end)];
        end
        %Time Deinterleave
        [PLP_tdint,TI_blockindex] = Type1_Timedeinterlaver(PLP,L1post,i);
        %Cell Deinterleave, Rotation and Hard Decision and Recell_dint
        PLP_cdint = Type1_Celldeinterleaver(PLP_tdint,L1post,TI_blockindex,i);
        %Time interleave
        PLP_int = Type1_Timeinterlaver(PLP_cdint,L1post,i);
        PLP_int = PLP_int.';
        PLP_int = reshape(PLP_int,[],Nsubslices);
        PLP_int = PLP_int.';
        for i1 = 0:(Nsubslices-1)
            subslice_start = plpstart+i1*subsliceinterval;
            subslice_end = subslice_start+((plpblocks*cellsperblock)/(Nsubslices*PI))-1;
            DataCells(subslice_start:subslice_end) = PLP_int(i1+1,:);
        end
    else
        %Type 1 and Common PLP
        % Time il length == number of TI blocks
        %Extract cells
        if length(plpstart:plpstart+((plpblocks*cellsperblock)/PI)-1)>length(plpstart:length(DataCells))
            fprintf('QAM Demapping: Type 1 - Length of PLP %d in L1 post is greater than frame length. Data cells untouched \r\n',i)
            continue
        end
        
        PLP = DataCells(plpstart:plpstart+((plpblocks*cellsperblock)/PI)-1);
        %Time Deinterleave
        [PLP_tdint,TI_blockindex] = Type1_Timedeinterlaver(PLP,L1post,i);
        %Cell Deinterleave, Rotation and Hard Decision and Recell_dint
        [PLP_cdint, DVBT2] = Type1_Celldeinterleaver(PLP_tdint,L1post,TI_blockindex,i,DVBT2);
        %Time interleave
        PLP_int = Type1_Timeinterlaver(PLP_cdint,L1post,i);
        DataCells(plpstart:plpstart+((plpblocks*cellsperblock)/PI)-1) = PLP_int;
    end
    
end
%%
%Add dummy cells 
% Initialize variables
srBin = [1 0 0 1 0 1 0 1 0 0 0 0 0 0 0]; % Shift register content
bbPrbsBin = zeros(1,Num_dummycells); % Initialize output

% Generates PRBS sequence
for n=1:Num_dummycells
    fedBackBit = xor(srBin(14), srBin(15)); % XOR bits 14 and 15
    bbPrbsBin(n) = fedBackBit;  % Output
    srBin = [fedBackBit, srBin(1:14)];
end

bbPrbs = 2*(0.5-bbPrbsBin);

if Num_dummycells>0,DataCells((end-DVBT2.C_FC-Num_dummycells+1):(end-DVBT2.C_FC))=bbPrbs;end
%%    
%Unmodulated cells in Frame closing symbol
if DVBT2.L_FC
    DataCells((end-DVBT2.C_FC+1):end)= 0;
end

RemainingP2 = DataCells(1:length(RemainingP2));
PLPValues = DataCells((length(RemainingP2)+1):(length(RemainingP2)+length(Values)));
if DVBT2.L_FC
    PLPValues = reshape(PLPValues,[],L1pre.numdatasymbols-1);
    PLPValues = PLPValues.';
    FCValues = DataCells((length(RemainingP2)+length(Values)):end);
else
    PLPValues = reshape(PLPValues,[],L1pre.numdatasymbols);
    PLPValues = PLPValues.';
    FCValues = [];
end

%figure()
%plot(fft(PLPValues))

end