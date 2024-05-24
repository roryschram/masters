function [LLRChannel,N_post_FEC_block] = L1post_blockcount(LLRChannel,L1pre)
%Description: Determine number of blocks for L1post signalling
% Inputs: LLRChannel - LLR of L1 post
%         L1pre - L1 pre parameters
% Ouputs: LLRChannel - reshaped LLR such that each row is a block
%         N_post_FEC_block - Number of L1post blocks
K_bch = 7032;
L1postinfosize = L1pre.L1postinfosize;
K_post_ex_pad = L1postinfosize + 32;
N_post_FEC_block = ceil(K_post_ex_pad / K_bch);

LLRChannel =LLRChannel.';
LLRChannel = reshape(LLRChannel,[],N_post_FEC_block);
LLRChannel = LLRChannel.';
%each row is a different block


end