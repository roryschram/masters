function LLRChannel_demultiplexed = L1post_demultiplexing(LLRChannel, L1pre)
%Description: Demultiplexing of L1 post bit
% Inputs: LLRChannel - LLR of L1 post symbols
%         P2 - P2 Parameters
%         L1pre - L1 pre parameters
% Ouputs: LLRChannel_demultiplexed - demultiplexed LLR Channel 
% Reference: DVBT2 standard

L1mod = L1pre.L1mod;
eta_mod = L1pre.L1V;

switch L1mod
    case 'BPSK'
        demux    = 0;
    case 'QPSK'
        demux    = [0 1];
    case '16-QAM'
        demux    = [7 1 4 2 5 3 6 0];
    case '64-QAM'
        demux    = [11 7 3 10 6 2 9 5 1 8 4 0];
end
%Process
LLRChannel = LLRChannel.';% LLR is row vector and changed into colum vector for ease of implementing reshape function
if L1pre.L1V==4 || L1pre.L1V==6
    LLRChannel = reshape(LLRChannel,2*eta_mod,[]); %matrix with 2*etamod rows
    LLRChannel(1:2*eta_mod,:) = LLRChannel(demux+1,:); 
    LLRChannel = reshape(LLRChannel,1,[]);
end
    LLRChannel_demultiplexed = LLRChannel;
end