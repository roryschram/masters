function LLRChannel_16200 = L1post_depuncture(LLRChannel_debit,L1pre,P2)
%Description: Depuncture and add zeros
% Inputs: LLRChannel_debit - deinterleaved LLR L1post
%         P2 - P2 Parameters
%         L1pre - L1 pre parameters
% Ouputs: LLRChannel_16200 - 16200 bit length FEC Block containing L1 post
% Reference: DVBT2 standard


K_bch = 7032;
post_info_size = L1pre.L1postinfosize;
K_post_ex_pad = post_info_size + 32;
N_post_FEC_block = ceil(K_post_ex_pad / K_bch); % numer of 16200 bit FEC blocks to consider
K_L1_PADDING = ceil(K_post_ex_pad / N_post_FEC_block) * N_post_FEC_block - K_post_ex_pad;
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

N_punc = N_punc_temp - (N_post - N_post_temp);

%Process
%find all punctured bit locations
nBch = 7200;
Nldpc = 16200;
Qldpc = 25; %Found in table 8b. Specific to code rate 1/2, 
Npuncgroups = floor(N_punc/360);

Puncturebitindices = zeros(1,(Nldpc-nBch));

switch L1pre.L1mod
    case {'BPSK','QPSK'}
          piSPost = [18 17 16 15 14 13 12 11 4 10 9 8 3 2 7 6 5 1 19 0];
          piPPost = [6 4 18 9 13 8 15 20 5 17 2 24 10 22 12 3 16 23 1 14 0 ...
             21 19 7 11];
     case '16-QAM'
         piSPost = [18 17 16 15 14 13 12 11 4 10 9 8 7 3 2 1 6 5 19 0];
         piPPost = [6 4 13 9 18 8 15 20 5 17 2 22 24 7 12 1 16 23 14 0 21 ...
             10 19 11 3];
    case '64-QAM'
        piSPost = [18 17 16 4 15 14 13 12 3 11 10 9 2 8 7 1 6 5 19 0];
        piPPost = [6 15 13 10 3 17 21 8 5 19 2 23 16 24 7 18 1 12 20 0 4 ...
            14 9 11 22];
end

% piPPost = piPPost+1;% matlab indexing
% piSPost = piSPost+1;

Bitsinlastgroup = N_punc - (Npuncgroups)*360;

for i = 0:359
Puncturebitindices(piPPost(1:Npuncgroups)+(i*Qldpc)+1)=1;
end

Puncturebitindices(piPPost(Npuncgroups+1)+(0:(Bitsinlastgroup-1))*Qldpc+1)=1;

L1Post_Puncturebitindices = find(Puncturebitindices==1)+nBch; %The indices of all punctured bits

%Zero padded bits
Ngroup = nBch/360;
if K_sig<=360
    Npad = Ngroup-1;
    lastGroupPad = 360-K_sig;
else
    Npad = floor((K_bch-K_sig)/360);
    lastGroupPad = K_bch-K_sig-(360*Npad);
end
Zerobitindices = zeros(1,K_bch);

for i = 1:Npad
    if piSPost(i)== Ngroup-1
        Zerobitindices(((piSPost(i))*360)+(1:(360-(nBch-K_bch))))=1;
    else
        Zerobitindices(((piSPost(i))*360)+(1:360))=1;
    end
end

if (piSPost(Npad+1))==Ngroup-1
    Zerobitindices(((piSPost(Npad+1))*360)+((360-(nBch-K_bch))-lastGroupPad)+(1:lastGroupPad)) = 1;
else
    Zerobitindices(((piSPost(Npad+1))*360)+(360-lastGroupPad)+(1:lastGroupPad))=1;
end
L1Post_Zerobitindices = (Zerobitindices==1); %Indices of zero padded bits in BCH

LLRChannel_16200 = ones(1,16200);
LLRChannel_16200(L1Post_Zerobitindices)= 10; % High confidence of zero
LLRChannel_16200(L1Post_Puncturebitindices)=0.1; % should be zero, low confidence of 0 or 1
LLRChannel_16200(LLRChannel_16200==1)= LLRChannel_debit;


end