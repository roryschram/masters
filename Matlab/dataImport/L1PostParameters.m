function [L1post,L1postsymbols] = L1PostParameters(Values,P2,L1pre,Variance)
%Description:
% Inputs: Values - QAM Symbols
%         P2 - P2 Parameters
%         L1pre - L1 pre parameters
%         ChannelEst - ChannelEst
%         Variance - Estimated noise variance estimate
% Ouputs: L1post - L1 post parameters
%         L1postsymbols - L1 post QAM symbols
% Reference:
L1postsize = L1pre.L1postsize;
L1postsymbols = Values(1841:1841+L1postsize-1);

%QAM Demapping
[L1postsymbols, LLRChannel] = L1post_demapping(L1postsymbols, L1pre,Variance);
L1postbits = [];
% Determine number of LDPC blocks and reshape so functions apply on each
% Reshape LLRChannel into rows for each LDPC block
[LLRChannel_blocks,N_post_FEC_block] = L1post_blockcount(LLRChannel,L1pre);
for i = 1:N_post_FEC_block
    %Demultiplexer
    LLRChannel_demultiplexed = L1post_demultiplexing(LLRChannel_blocks(i,:), L1pre);
    %De-bit interleaving
    LLRChannel_debit = L1post_debitinterleaver(LLRChannel_demultiplexed,L1pre,P2);
    %Depunture and deshorten
    LLRChannel_16200 = L1post_depuncture(LLRChannel_debit,L1pre,P2);
    %LDPC decoding
    LLRChannel_7200 = L1post_LDPCdecoding(LLRChannel_16200,L1pre);
    %BCH decoding
    LLRChannel_7032 = L1post_BCHdecoding(LLRChannel_7200);
    %Remove Zero Padding and Descramble
    LLRChannel_zero = L1post_Zeroremoval(LLRChannel_7032,L1pre);
    L1postbits = [L1postbits LLRChannel_zero];
end
%Remove Zero Padding, Descramble and Decode
L1post = L1post_decoding(L1postbits,L1pre);
end