function LLRChannel_debit = L1post_debitinterleaver(LLRChannel,L1pre,P2)
%Description: Deinterleaving of L1 bits
% Inputs: Values - QAM Symbols
%         P2 - P2 Parameters
%         L1pre - L1 pre parameters
% Ouputs: LLRChannel_debit - deinterleaved L1 post LLR stream
% Reference: DVBT2 standard

%Parameters from standard
L1mod = L1pre.L1mod;
K_bch = 7032;
post_info_size = L1pre.L1postinfosize;
K_post_ex_pad = post_info_size + 32;
N_post_FEC_block = ceil(K_post_ex_pad / K_bch); % Number of FEC Blocks containing L1post info
K_L1_PADDING = ceil(K_post_ex_pad / N_post_FEC_block) * N_post_FEC_block - K_post_ex_pad; % Number of padding bits in L1 post word
K_post = K_post_ex_pad + K_L1_PADDING;
K_sig = K_post / N_post_FEC_block;
N_punc_temp = floor(6 / 5 * (K_bch - K_sig));
N_bch_parity = 168;
N_post_temp = K_sig + N_bch_parity + 9000 - N_punc_temp;

eta_mod = L1pre.L1V;
N_P2 = P2.N_P2;
switch N_P2
    case 1
        N_post = ceil(N_post_temp / (2*eta_mod)) * 2*eta_mod;
    otherwise
        N_post = ceil(N_post_temp / (eta_mod * N_P2)) * eta_mod * N_P2;
end

%Process
switch L1mod
    case '16-QAM'
        nc = 8;
        nr = N_post/nc;
        aux = 1:N_post;
        biPostW = reshape(aux,nc,nr);
        biPostR = reshape(biPostW.',1,nr*nc);
        LLRChannel_debit= LLRChannel(biPostR);
    case '64-QAM'
        nc = 12;
        nr = N_post/nc;
        aux = 1:N_post;
        biPostW = reshape(aux,nc,nr);
        biPostR = reshape(biPostW.',1,nr*nc);
        LLRChannel_debit= LLRChannel(biPostR);
    otherwise
        LLRChannel_debit= LLRChannel;
end
end