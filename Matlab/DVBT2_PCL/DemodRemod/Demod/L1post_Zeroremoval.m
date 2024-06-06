function LLRChannel_zero = L1post_Zeroremoval(LLRChannel_7032,L1pre)
%Description:Remove Zero Padding and Descramble
% Inputs: LLRChannel_7032 - 7032 bit length FEC block BCH unCoded
%         P2 - P2 Parameters
%         L1pre - L1 pre parameters
% Ouputs: LLRChannel_zero - descrambled and removal of zeros L1 post bit
% Reference:
K_bch = 7032;
N_bch = 7200;
post_info_size = L1pre.L1postinfosize;
K_post_ex_pad = post_info_size + 32;
N_post_FEC_block = ceil(K_post_ex_pad / K_bch); % numer of 16200 bit FEC blocks to consider
K_L1_PADDING = ceil(K_post_ex_pad / N_post_FEC_block) * N_post_FEC_block - K_post_ex_pad;
K_post = K_post_ex_pad + K_L1_PADDING;
K_sig = K_post / N_post_FEC_block;

switch L1pre.L1mod
    case {'BPSK','QPSK'}
        piSPost = [18 17 16 15 14 13 12 11 4 10 9 8 3 2 7 6 5 1 19 0];
     case '16-QAM'
        piSPost = [18 17 16 15 14 13 12 11 4 10 9 8 7 3 2 1 6 5 19 0];
    case '64-QAM'
        piSPost = [18 17 16 4 15 14 13 12 3 11 10 9 2 8 7 1 6 5 19 0];
end

%Process
%1. Descrambling
if (strcmp(L1pre.t2version,'1.3.1'))
    switch L1pre.L1postscrambled
        case 1
            srBin = [1 0 0 1 0 1 0 1 0 0 0 0 0 0 0]; % Shift register content
            bbPrbsBin = zeros(1,Kbch); % Initialize output

            % Generates PRBS sequence
            for n=1:Kbch
                fedBackBit = xor(srBin(14), srBin(15)); % XOR bits 14 and 15
                bbPrbsBin(n) = fedBackBit;  % Output
                srBin = [fedBackBit, srBin(1:14)];
            end
            bbPrbs = bbPrbsBin;
            
            LLRChannel_7032 = bitxor(LLRChannel_7032,bbPrbs); %Descrambling of L1 post block
    end
end

%2. Remove Zero Padded Bits
%Zero padded bits
Ngroup = N_bch/360;
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
        Zerobitindices(((piSPost(i))*360)+(1:(360-(N_bch-K_bch))))=1;
    else
        Zerobitindices(((piSPost(i))*360)+(1:360))=1;
    end
end

if (piSPost(Npad+1))==Ngroup-1
    Zerobitindices(((piSPost(Npad+1))*360)+((360-(N_bch-K_bch))-lastGroupPad)+(1:lastGroupPad)) = 1;
else
    Zerobitindices(((piSPost(Npad+1))*360)+(360-lastGroupPad)+(1:lastGroupPad))=1;
end

L1Post_Zerobitindices = (Zerobitindices==1); %Indices of zero padded bits in BCH

LLRChannel_7032(L1Post_Zerobitindices) = []; %Removal of the zero padded bits
LLRChannel_zero = LLRChannel_7032.';