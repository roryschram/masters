function DVBT2= DVBT2Parameters(L1pre,L1post)
%Description: Get Data Cells basic parameters
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2), p161

%Inputs: 
NFFT = L1pre.S2; 

%% 
%A. General OFDM Symbols
switch L1pre.S2 
    case 1024
    C_PS   = 853;        % Number of carriers per symbol
    K_EXT  = 0;          % extra carriers on each side in ext carrier mode
    N_P2   = 16;         % Number of P2 symbols
  case 2048
    C_PS   = 1705;       % Number of carriers per symbol
    K_EXT  = 0;          % extra carriers on each side in ext carrier mode
    N_P2   = 8;
  case 4096
    C_PS   = 3409;       % Number of carriers per symbol
    K_EXT  = 0;          % extra carriers on each side in ext carrier mode
    N_P2   = 4;
  case 8192 
    C_PS   = 6817;       % Number of carriers per symbol    
    K_EXT  = 48;         % extra carriers on each side in ext carrier mode
    N_P2   = 2;
  case 16384 
    C_PS   = 13633;      % Number of carriers per symbol 
    K_EXT  = 144;        % extra carriers on each side in ext carrier mode
    N_P2   = 1;
  case 32768 
    C_PS   = 27265;      % Number of carriers per symbol     
    K_EXT  = 288;        % extra carriers on each side in ext carrier mode
    N_P2   = 1;
end

CPS_EXT = C_PS + 2*K_EXT; % Number of active subcarriers in extended mode

if L1pre.BW_EXT
    C_PS = C_PS + 2*K_EXT;
end

C_LOC = NFFT/2-(C_PS-1)/2+1:NFFT/2+(C_PS-1)/2+1; %Active carrier locations

DVBT2.C_PS = C_PS; %Number of active carriers in symbol
DVBT2.C_LOC = C_LOC;%Active carrier locations
DVBT2.NFFT = NFFT; %FFT Size
DVBT2.K_EXT = K_EXT; %Number of extended carriers in extended carrier mode
DVBT2.N_P2 = N_P2;
%% 

%% 
%B. Presence of Frame Closing Symbol
% Dependent on Scattered pilot map, guard interval and NFFT

FCSUseTable = {...
    {}  {'PP6'} {'PP4'} {'PP4'} {'PP2'} {'PP2'} {}; ...
    {} {'PP7' 'PP6'} {'PP4' 'PP5'} {'PP4' 'PP5'} {'PP2' 'PP3'} {'PP2' 'PP3'} {'PP1'}; ...
    {} {'PP7'} {'PP4' 'PP5'} {'PP4' 'PP5'} {'PP2' 'PP3'} {'PP2' 'PP3'} {'PP1'}; ...
    {} {'PP7'} {'PP4' 'PP5'} {} {'PP2' 'PP3'} {} {'PP1'}; ...
    {} {} {'PP4' 'PP5'} {} {'PP2' 'PP3'} {} {'PP1'} ...
    }; % Table 634 of DVBT2 standard

c = find([1/128,1/32,1/16,19/256,1/8,19/128,1/4]==L1pre.GI);

switch NFFT
    case 32768
        r=1;
    case 16384
        r=2;
    case 8192
        r=3;
    case {4096,2048}
        r=4;
    case 1024
        r=5;
end

if isempty(find(ismember(FCSUseTable{r,c},L1pre.pilotpattern), 1))
    L_FC = 0; % FCS not used in this combo
else
    L_FC = 1;
end

DVBT2.L_FC = L_FC; %Indicates presence
%%
%C. Scattered Pilot Location (set of indices)
switch L1pre.pilotpattern
  case 'PP1'
    x = 3;
    y = 4;
	fprintf('Using pilot pattern 1\n')
  case 'PP2'
    x = 6;
    y = 2;
	fprintf('Using pilot pattern 2\n')
  case 'PP3'
    x = 6;
    y = 4; 
	fprintf('Using pilot pattern 3\n')
  case 'PP4'
    x = 12;
    y = 2;
	fprintf('Using pilot pattern 4\n')
  case 'PP5'
    x = 12;
    y = 4;
	fprintf('Using pilot pattern 5\n')
  case 'PP6'
    x = 24;
    y = 2;
	fprintf('Using pilot pattern 6\n')
  case 'PP7'
    x = 24;
    y = 4;
	fprintf('Using pilot pattern 7\n')
  case 'PP8'
    x = 6;
    y = 16;
	fprintf('Using pilot pattern 8\n')
  otherwise, error('Unknown Pilot Pattern in Use');
end

L_F = N_P2+L1pre.numdatasymbols;

if L_FC %Checks for presence
    limit = L_F-2;
    numdatasymbols = L1pre.numdatasymbols-1;
else
    limit = L_F-1;
    numdatasymbols = L1pre.numdatasymbols;
end

DVBT2.SPLoc = zeros(numdatasymbols, ceil(C_PS/(x*y))); %Scattered Pilot indices over all data symbols 
DVBT2.Scatteredpilotmap = zeros(numdatasymbols,C_PS);

%figure()
%plot(DVBT2.Scatteredpilotmap)

for l=N_P2:limit
    if L1pre.BW_EXT
        loc = (mod((0:C_PS-1)-K_EXT, x*y) == x*(mod(l,y))); % indices of scattered pilots in data symbols
        loc = single(loc);
    else
        loc = (mod(0:C_PS-1, x*y) == x*(mod(l,y)));
        loc = single(loc);
    end
    DVBT2.Scatteredpilotmap((l-N_P2+1),:)= loc;
    loc = find(loc);
    DVBT2.SPLoc((l-N_P2+1),1:length(loc)) = loc;  
end

DVBT2.Scatteredpilotmap(:,[1 end]) = 1; %Edge Pilots

DVBT2.DY = y;
DVBT2.DX = x;
%%
%D. Continual Pilot Locations (sets of indices)
switch L1pre.pilotpattern
    case 'PP1'
        CP1=[116 255 285 430 518 546 601 646 744 1662 1893 1995 2322 3309 3351 3567 3813 4032 5568 5706];
        CP2=[1022 1224 1302 1371 1495 2261 2551 2583 2649 2833 2925 3192 4266 5395 5710 5881 8164 10568 11069 11560 12631 12946 13954 16745 21494];
        CP3=[];
        CP4=[];
        CP5=[1369 7013 7215 7284 7649 7818 8025 8382 8733 8880 9249 9432 9771 10107 10110 10398 10659 10709 10785 10872 11115 11373 11515 11649 11652 12594 12627 12822 12984 15760 16612 17500 18358 19078 19930 20261 20422 22124 22867 23239 24934 25879 26308 26674];
        CP6=[];
    case 'PP2'
        CP1=[116 318 390 430 474 518 601 646 708 726 1752 1758 1944 2100 2208 2466 3792 5322 5454 5640];
        CP2=[1022 1092 1369 1416 1446 1495 2598 2833 2928 3144 4410 4800 5710 5881 6018 6126 10568 11515 12946 13954 15559 16681];
        CP3=[2261 8164];
        CP4=[10709 19930];
        CP5=[6744 7013 7020 7122 7308 7649 7674 7752 7764 8154 8190 8856 8922 9504 9702 9882 9924 10032 10092 10266 10302 10494 10530 10716 11016 11076 11160 11286 11436 11586 12582 13002 17500 18358 19078 22124 23239 24073 24934 25879 26308];
        CP6=[13164 13206 13476 13530 13536 13764 13848 13938 13968 14028 14190 14316 14526 14556 14562 14658 14910 14946 15048 15186 15252 15468 15540 15576 15630 15738 15840 16350 16572 16806 17028 17064 17250 17472 17784 17838 18180 18246 18480 18900 18960 19254 19482 19638 19680 20082 20310 20422 20454 20682 20874 21240 21284 21444 21450 21522 21594 21648 21696 21738 22416 22824 23016 23124 23196 23238 23316 23418 23922 23940 24090 24168 24222 24324 24342 24378 24384 24540 24744 24894 24990 25002 25194 25218 25260 25566 26674 26944];
        
    case 'PP3'
        CP1=[116 318 342 426 430 518 582 601 646 816 1758 1764 2400 3450 3504 3888 4020 4932 5154 5250 5292 5334];
        CP2=[1022 1495 2261 2551 2802 2820 2833 2922 4422 4752 4884 5710 8164 10568 11069 11560 12631 12946 16745 21494];
        CP3=[13954];
        CP4=[];
        CP5=[1369 5395 5881 6564 6684 7013 7649 8376 8544 8718 8856 9024 9132 9498 9774 9840 10302 10512 10566 10770 10914 11340 11418 11730 11742 12180 12276 12474 12486 15760 16612 17500 18358 19078 19930 20261 20422 22124 22867 23239 24934 25879 26308 26674];
        CP6=[13320 13350 13524 13566 13980 14148 14340 14964 14982 14994 15462 15546 15984 16152 16314 16344 16488 16614 16650 16854 17028 17130 17160 17178 17634 17844 17892 17958 18240 18270 18288 18744 18900 18930 18990 19014 19170 19344 19662 19698 20022 20166 20268 20376 20466 20550 20562 20904 21468];
    case 'PP4'
        CP1=[108 116 144 264 288 430 518 564 636 646 828 2184 3360 3396 3912 4032 4932 5220 5676 5688];
        CP2=[601 1022 1092 1164 1369 1392 1452 1495 2261 2580 2833 3072 4320 4452 5710 5881 6048 10568 11515 12946 13954 15559 16681];
        CP3=[8164];
        CP4=[10709 19930];
        CP5=[6612 6708 7013 7068 7164 7224 7308 7464 7649 7656 7716 7752 7812 7860 8568 8808 8880 9072 9228 9516 9696 9996 10560 10608 10728 11148 11232 11244 11496 11520 11664 11676 11724 11916 17500 18358 19078 21284 22124 23239 24073 24934 25879 26308];
        CP6=[13080 13152 13260 13380 13428 13572 13884 13956 14004 14016 14088 14232 14304 14532 14568 14760 14940 15168 15288 15612 15684 15888 16236 16320 16428 16680 16812 16908 17184 17472 17508 17580 17892 17988 18000 18336 18480 18516 19020 19176 19188 19320 19776 19848 20112 20124 20184 20388 20532 20556 20676 20772 21156 21240 21276 21336 21384 21816 21888 22068 22092 22512 22680 22740 22800 22836 22884 23304 23496 23568 23640 24120 24168 24420 24444 24456 24492 24708 24864 25332 25536 25764 25992 26004 26674 26944];
    case 'PP5'
        CP1=[108 116 228 430 518 601 646 804 1644 1680 1752 1800 1836 3288 3660 4080 4932 4968 5472];
        CP2=[852 1022 1495 2508 2551 2604 2664 2736 2833 3120 4248 4512 4836 5710 5940 6108 8164 10568 11069 11560 12946 13954 21494];
        CP3=[648 4644 16745];
        CP4=[12631];
        CP5=[1369 2261 5395 5881 6552 6636 6744 6900 7032 7296 7344 7464 7644 7649 7668 7956 8124 8244 8904 8940 8976 9216 9672 9780 10224 10332 10709 10776 10944 11100 11292 11364 11496 11532 11904 12228 12372 12816 15760 16612 17500 19078 22867 25879];
        CP6=[];
    case 'PP6'
        CP1=[];
        CP2=[];
        CP3=[];
        CP4=[];
        CP5=[116 384 408 518 601 646 672 960 1022 1272 1344 1369 1495 1800 2040 2261 2833 3192 3240 3768 3864 3984 4104 4632 4728 4752 4944 5184 5232 5256 5376 5592 5616 5710 5808 5881 6360 6792 6960 7013 7272 7344 7392 7536 7649 7680 7800 8064 8160 8164 8184 8400 8808 8832 9144 9648 9696 9912 10008 10200 10488 10568 10656 10709 11088 11160 11515 11592 12048 12264 12288 12312 12552 12672 12946 13954 15559 16681 17500 19078 20422 21284 22124 23239 24934 25879 26308 26674];
        CP6=[13080 13368 13464 13536 13656 13728 13824 14112 14232 14448 14472 14712 14808 14952 15000 15336 15360 15408 15600 15624 15648 16128 16296 16320 16416 16536 16632 16824 16848 17184 17208 17280 17352 17520 17664 17736 17784 18048 18768 18816 18840 19296 19392 19584 19728 19752 19776 20136 20184 20208 20256 21096 21216 21360 21408 21744 21768 22200 22224 22320 22344 22416 22848 22968 23016 23040 23496 23688 23904 24048 24168 24360 24408 24984 25152 25176 25224 25272 25344 25416 25488 25512 25536 25656 25680 25752 25992 26016];
    case 'PP7'
        CP1=[264 360 1848 2088 2112 2160 2256 2280 3936 3960 3984 5016 5136 5208 5664];
        CP2=[116 430 518 601 646 1022 1296 1368 1369 1495 2833 3024 4416 4608 4776 5710 5881 6168 7013 8164 10568 10709 11515 12946 15559 23239 24934 25879 26308 26674];
        CP3=[456 480 2261 6072 17500];
        CP4=[1008 6120 13954];
        CP5=[6984 7032 7056 7080 7152 7320 7392 7536 7649 7704 7728 7752 8088 8952 9240 9288 9312 9480 9504 9840 9960 10320 10368 10728 10752 11448 11640 11688 11808 12192 12240 12480 12816 16681 22124];
        CP6=[13416 13440 13536 13608 13704 13752 14016 14040 14112 14208 14304 14376 14448 14616 14712 14760 14832 14976 15096 15312 15336 15552 15816 15984 16224 16464 16560 17088 17136 17256 17352 17400 17448 17544 17928 18048 18336 18456 18576 18864 19032 19078 19104 19320 19344 19416 19488 19920 19930 19992 20424 20664 20808 21168 21284 21360 21456 21816 22128 22200 22584 22608 22824 22848 22944 22992 23016 23064 23424 23448 23472 23592 24192 24312 24360 24504 24552 24624 24648 24672 24768 24792 25080 25176 25224 25320 25344 25584 25680 25824 26064 26944];
    case 'PP8'
        CP1=[];
        CP2=[];
        CP3=[];
        CP4=[116 132 180 430 518 601 646 1022 1266 1369 1495 2261 2490 2551 2712 2833 3372 3438 4086 4098 4368 4572 4614 4746 4830 4968 5395 5710 5881 7649 8164 10568 11069 11560 12631 12946 13954 15760 16612 16745 17500 19078 19930 21494 22867 25879 26308];
        CP5=[6720 6954 7013 7026 7092 7512 7536 7596 7746 7758 7818 7986 8160 8628 9054 9096 9852 9924 10146 10254 10428 10704 11418 11436 11496 11550 11766 11862 12006 12132 12216 12486 12762 18358 20261 20422 22124 23239 24934];
        CP6=[10709 11515 13254 13440 13614 13818 14166 14274 14304 14364 14586 14664 15030 15300 15468 15474 15559 15732 15774 16272 16302 16428 16500 16662 16681 16872 17112 17208 17862 18036 18282 18342 18396 18420 18426 18732 19050 19296 19434 19602 19668 19686 19728 19938 20034 21042 21120 21168 21258 21284 21528 21594 21678 21930 21936 21990 22290 22632 22788 23052 23358 23448 23454 23706 23772 24048 24072 24073 24222 24384 24402 24444 24462 24600 24738 24804 24840 24918 24996 25038 25164 25314 25380 25470 25974 26076 26674 26753 26944];
end

switch NFFT
    case 1024
        cpList = mod(CP1, 1632);
    case 2048
        cpList = mod([CP1 CP2], 1632);
    case 4096
        cpList = mod([CP1 CP2 CP3], 3264);
    case 8192
        cpList = mod([CP1 CP2 CP3 CP4], 6528);
    case 16384
        cpList = mod([CP1 CP2 CP3 CP4 CP5], 13056);
    case 32768
        cpList = [CP1 CP2 CP3 CP4 CP5 CP6];
end

switch NFFT
    case {1024,2048,4096}
        ExtCPs = [];
    case 8192
        switch L1pre.pilotpattern
            case 'PP1'
                ExtCPs = [];
            case 'PP2'
                ExtCPs = [6820 6847 6869 6898];
            case 'PP3' %SP5
                ExtCPs = [6820 6869];
            case 'PP4' %SP8
                ExtCPs = [6820 6869];
            case 'PP5' %SP9
                ExtCPs = [];
            case 'PP6' %SP10
                ExtCPs = [];
            case 'PP7' %SP6
                ExtCPs = [6820 6833 6869 6887 6898];
            case 'PP8' %SP7
                ExtCPs = [6820 6833 6869 6887 6898];
        end
    case 16384
        switch L1pre.pilotpattern
            case 'PP1'
                ExtCPs = [13636 13724 13790 13879];
            case 'PP2'
                ExtCPs = [13636 13790];
            case 'PP3' %SP5
                ExtCPs = [13636 13790];
            case 'PP4' %SP8
                ExtCPs = [13636 13790];
            case 'PP5' %SP9
                ExtCPs = [13636 13790];
            case 'PP6' %SP10
                ExtCPs = [13636 13790];
            case 'PP7' %SP6
                ExtCPs = [13636 13724 13879];
            case 'PP8' %SP7
                ExtCPs = [13636 13724 13879];
        end
    case 32768
        switch L1pre.pilotpattern
            case 'PP1'
                ExtCPs = [];
            case 'PP2'
                ExtCPs = [27268 27688];
            case 'PP3' %SP5
                ExtCPs = [27268 27448 27688 27758];
            case 'PP4' %SP8
                ExtCPs = [27268 27688];
            case 'PP5' %SP9
                ExtCPs = [];
            case 'PP6' %SP10
                ExtCPs = [27268 27448 27688 27758];
            case 'PP7' %SP6
                ExtCPs = [27268 27688];
            case 'PP8' %SP7
                ExtCPs = [27268 27368 27448 27580 27688 27758];
        end
end

if L1pre.BW_EXT
    cpList = [cpList ExtCPs];
end

DVBT2.CPLoc = cpList + 1;
DVBT2.Continualpilotmap = zeros(numdatasymbols,C_PS);
DVBT2.Continualpilotmap(:,DVBT2.CPLoc) = 1;
%%
%E. Scattered,Continal and Edge Pilot Maps (Exact values of for each pilot type)
% PN Sequence (Hex to Binary)
PN_SEQ_HEX = [ ...
'4DC2AF7BD8C3C9A1E76C9A090AF1C3114F07FCA2808E9462E9AD7B712D6F4AC8A59BB069CC50BF1', ...
'149927E6BB1C9FC8C18BB949B30CD09DDD749E704F57B41DEC7E7B176E12C5657432B51B0B812DF', ...
'0E14887E24D80C97F09374AD76270E58FE1774B2781D8D3821E393F2EA0FFD4D24DE20C05D0BA170', ...
'3D10E52D61E013D837AA62D007CC2FD76D23A3E125BDE8A9A7C02A98B70251C556F6341EBDECB80', ...
'1AAD5D9FB8CBEA80BB619096527A8C475B3D8DB28AF8543A00EC3480DFF1E2CDA9F985B523B8790', ...
'07AA5D0CE58D21B18631006617F6F769EB947F924EA5161EC2C0488B63ED7993BA8EF4E552FA32FC', ...
'3F1BDB19923902BCBBE5DDABB824126E08459CA6CFA0267E5294A98C632569791E60EF659AEE9518', ...
'CDF08D87833690C1B79183ED127E53360CD86514859A28B5494F51AA4882419A25A2D01A5F47AA273', ...
'01E79A5370CCB3E197F'];

PN_SEQ = [];

for hexIndex = 1:length(PN_SEQ_HEX)
    
    binString = dec2bin(hex2dec(PN_SEQ_HEX(hexIndex)), 4);
    
    for binIndex = 1:4
        PN_SEQ = [PN_SEQ, str2num(binString(binIndex))];
    end
    
end

srBin = ones(1,11); % Shift register content
prbsBin = zeros(1,CPS_EXT); % Initialize output

% PRBS Sequence
for n=1:CPS_EXT;
  prbsBin(n) = srBin(11); % Output
  
  tran = xor(srBin(11), srBin(9)); % XOR bits 11 and 9
  srBin = [tran srBin(1:10)];
end

Prbs = prbsBin(1:CPS_EXT);

if L1pre.BW_EXT
    Prbs = Prbs;
else
    Prbs = Prbs(1+K_EXT:end-K_EXT);
end

RefSeqMap = zeros(numdatasymbols,C_PS); %Reference sequence pilot map
SPRefSeqMap = zeros(numdatasymbols,C_PS);% SP Reference sequence pilot map
CPRefSeqMap = zeros(numdatasymbols,C_PS);% CP Reference sequence pilot map

switch L1pre.pilotpattern
    case {'PP1','PP2'}
        Asp = 4/3;
    case {'PP3','PP4'}
        Asp = 7/4;
    case {'PP5','PP6','PP7','PP8'}
        Asp = 7/3;
end

switch NFFT
    case {1024,2048}
        Acp = 4/3;
    case 4096
        Acp = (4*sqrt(2))/3;
    case {8192,16384,32768}
        Acp = 8/3;
end
DVBT2.A_CP2 = Acp;
One_ScatPattern=DVBT2.SPLoc(1:y,:); % Symbol indices for one scattered pilot sequence Table 57
One_ScatPattern(One_ScatPattern==0)=[];

if ~isempty(intersect(DVBT2.CPLoc, One_ScatPattern)) %Checks for one of the continual pilot indices coincide with the scattered pilot indices
    Acp = Asp;
end
for n= 1:numdatasymbols
    RefSeqMap(n,:) = xor(PN_SEQ(n+N_P2),Prbs);
    SPRefSeqMap(n,:) = 2*Asp*(0.5-RefSeqMap(n,:));
    CPRefSeqMap(n,:) = 2*Acp*(0.5-RefSeqMap(n,:));
end

DVBT2.Scatteredpilotmap = SPRefSeqMap.*(DVBT2.Scatteredpilotmap);
DVBT2.Continualpilotmap = CPRefSeqMap.*(DVBT2.Continualpilotmap);

%figure()
%surf(DVBT2.Continualpilotmap(1:end,1:end))
%title('Continual Pilot Map')
%figure()
%surf(DVBT2.Scatteredpilotmap(1:end,1:end))
%title('Scattered Pilot Map')

DVBT2.A_CP = Acp;
DVBT2.A_SP = Asp;
%%
%F. Tone Reserved indices and Map
if strcmp(L1pre.PAPR, 'Both TR and ACE used') || strcmp(L1pre.PAPR, 'TR PAPR')
    switch MODE
        case 1024
            FCTRLoc = [116  130  134  157  182  256  346  478  479  532];
        case 2048
            FCTRLoc = [113  124  262  467  479  727  803  862  910  946  980  1201  1322  1342  1396  1397  1562  1565];
        case 4096
            FCTRLoc = [104  116  119  163  170  173  664  886  1064  1151  1196  1264  1531  1736  1951  1960  2069  2098  2311  2366  2473  2552  2584  2585  2645  2774  2846  2882  3004  3034  3107  3127  3148  3191  3283  3289];
        case 8192
            FCTRLoc = [106  109  110  112  115  118  133  142  163  184  206  247  445  461  503  565  602  656  766  800  922  1094  1108  1199  1258  1726  1793  1939  2128  2714  3185  3365  3541  3655  3770  3863  4066  4190  4282  4565  4628  4727  4882  4885  5143  5192  5210  5257  5261  5459  5651  5809  5830  5986  6020  6076  6253  6269  6410  6436  6467  6475  6509  6556  6611  6674  6685  6689  6691  6695  6698  6701];
        case 16384
            FCTRLoc = [104  106  107  109  110  112  113  115  116  118  119  121  122  125  128  131  134  137  140  143  161  223  230  398  482  497  733  809  850  922  962  1196  1256  1262  1559  1691  1801  1819  1937  2005  2095  2308  2383  2408  2425  2428  2479  2579  2893  2902  3086  3554  4085  4127  4139  4151  4163  4373  4400  4576  4609  4952  4961  5444  5756  5800  6094  6208  6658  6673  6799  7208  7682  8101  8135  8230  8692  8788  8933  9323  9449  9478  9868  10192  10261  10430  10630  10685  10828  10915  10930  10942  11053  11185  11324  11369  11468  11507  11542  11561  11794  11912  11974  11978  12085  12179  12193  12269  12311  12758  12767  12866  12938  12962  12971  13099  13102  13105  13120  13150  13280  13282  13309  13312  13321  13381  13402  13448  13456  13462  13463  13466  13478  13492  13495  13498  13501  13502  13504  13507  13510  13513  13514  13516];
        case 32768
            FCTRLoc = [104  106  107  109  110  112  113  115  118  121  124  127  130  133  136  139  142  145  148  151  154  157  160  163  166  169  172  175  178  181  184  187  190  193  196  199  202  205  208  211  404  452  455  467  509  539  568  650  749  1001  1087  1286  1637  1823  1835  1841  1889  1898  1901  2111  2225  2252  2279  2309  2315  2428  2452  2497  2519  3109  3154  3160  3170  3193  3214  3298  3331  3346  3388  3397  3404  3416  3466  3491  3500  3572  4181  4411  4594  4970  5042  5069  5081  5086  5095  5104  5320  5465  5491  6193  6541  6778  6853  6928  6934  7030  7198  7351  7712  7826  7922  8194  8347  8350  8435  8518  8671  8861  8887  9199  9980  10031  10240  10519  10537  10573  10589  11078  11278  11324  11489  11642  12034  12107  12184  12295  12635  12643  12941  12995  13001  13133  13172  13246  13514  13522  13939  14362  14720  14926  15338  15524  15565  15662  15775  16358  16613  16688  16760  17003  17267  17596  17705  18157  18272  18715  18994  19249  19348  20221  20855  21400  21412  21418  21430  21478  21559  21983  21986  22331  22367  22370  22402  22447  22535  22567  22571  22660  22780  22802  22844  22888  22907  23021  23057  23086  23213  23240  23263  23333  23369  23453  23594  24143  24176  24319  24325  24565  24587  24641  24965  25067  25094  25142  25331  25379  25465  25553  25589  25594  25655  25664  25807  25823  25873  25925  25948  26002  26008  26102  26138  26141  26377  26468  26498  26510  26512  26578  26579  26588  26594  26597  26608  26627  26642  26767  26776  26800  26876  26882  26900  26917  26927  26951  26957  26960  26974  26986  27010  27013  27038  27044  27053  27059  27061  27074  27076  27083  27086  27092  27094  27098  27103  27110  27115  27118  27119  27125  27128  27130  27133  27134  27140  27143  27145  27146  27148  27149];
    end
    DVBT2.FCTRLoc = FCTRLoc + 1; % Location of TR indices in FC symbol,Index from 1

    switch NFFT
        case 1024
            normalTRLoc = [109  117  122  129  139  321  350  403  459  465 ];
        case 2048
            normalTRLoc = [250  404  638  677  700  712  755  952  1125  1145  1190  1276  1325  1335  1406  1431  1472  1481 ];
        case 4096
            normalTRLoc = [170  219  405  501  597  654  661  745  995  1025  1319  1361  1394  1623  1658  1913  1961  1971  2106  2117  2222  2228  2246  2254  2361  2468  2469  2482  2637  2679  2708  2825  2915  2996  3033  3119 ];
        case 8192
            normalTRLoc = [111  115  123  215  229  392  613  658  831  842  997  1503  1626  1916  1924  1961  2233  2246  2302  2331  2778  2822  2913  2927  2963  2994  3087  3162  3226  3270  3503  3585  3711  3738  3874  3902  4013  4017  4186  4253  4292  4339  4412  4453  4669  4910  5015  5030  5061  5170  5263  5313  5360  5384  5394  5493  5550  5847  5901  5999  6020  6165  6174  6227  6245  6314  6316  6327  6503  6507  6545  6565 ];
        case 16384
            normalTRLoc = [109  122  139  171  213  214  251  585  763  1012  1021  1077  1148  1472  1792  1883  1889  1895  1900  2013  2311  2582  2860  2980  3011  3099  3143  3171  3197  3243  3257  3270  3315  3436  3470  3582  3681  3712  3767  3802  3979  4045  4112  4197  4409  4462  4756  5003  5007  5036  5246  5483  5535  5584  5787  5789  6047  6349  6392  6498  6526  6542  6591  6680  6688  6785  6860  7134  7286  7387  7415  7417  7505  7526  7541  7551  7556  7747  7814  7861  7880  8045  8179  8374  8451  8514  8684  8698  8804  8924  9027  9113  9211  9330  9479  9482  9487  9619  9829  10326  10394  10407  10450  10528  10671  10746  10774  10799  10801  10912  11113  11128  11205  11379  11459  11468  11658  11776  11791  11953  11959  12021  12028  12135  12233  12407  12441  12448  12470  12501  12548  12642  12679  12770  12788  12899  12923  12939  13050  13103  13147  13256  13339  13409 ];
        case 32768
            normalTRLoc = [164  320  350  521  527  578  590  619  635  651  662  664  676  691  723  940  1280  1326  1509  1520  1638  1682  1805  1833  1861  1891  1900  1902  1949  1967  1978  1998  2006  2087  2134  2165  2212  2427  2475  2555  2874  3067  3091  3101  3146  3188  3322  3353  3383  3503  3523  3654  3856  4150  4158  4159  4174  4206  4318  4417  4629  4631  4875  5104  5106  5111  5131  5145  5146  5177  5181  5246  5269  5458  5474  5500  5509  5579  5810  5823  6058  6066  6098  6411  6741  6775  6932  7103  7258  7303  7413  7586  7591  7634  7636  7655  7671  7675  7756  7760  7826  7931  7937  7951  8017  8061  8071  8117  8317  8321  8353  8806  9010  9237  9427  9453  9469  9525  9558  9574  9584  9820  9973  10011  10043  10064  10066  10081  10136  10193  10249  10511  10537  11083  11350  11369  11428  11622  11720  11924  11974  11979  12944  12945  13009  13070  13110  13257  13364  13370  13449  13503  13514  13520  13583  13593  13708  13925  14192  14228  14235  14279  14284  14370  14393  14407  14422  14471  14494  14536  14617  14829  14915  15094  15138  15155  15170  15260  15283  15435  15594  15634  15810  16178  16192  16196  16297  16366  16498  16501  16861  16966  17039  17057  17240  17523  17767  18094  18130  18218  18344  18374  18657  18679  18746  18772  18779  18786  18874  18884  18955  19143  19497  19534  19679  19729  19738  19751  19910  19913  20144  20188  20194  20359  20490  20500  20555  20594  20633  20656  21099  21115  21597  22139  22208  22244  22530  22547  22562  22567  22696  22757  22798  22854  22877  23068  23102  23141  23154  23170  23202  23368  23864  24057  24215  24219  24257  24271  24325  24447  25137  25590  25702  25706  25744  25763  25811  25842  25853  25954  26079  26158  26285  26346  26488  26598  26812  26845  26852  26869  26898  26909  26927  26931  26946  26975  26991  27039 ]; 
    end
    normalTRLoc = normalTRLoc + 1; % Location of TR indices in normal data symbol,Index from 1
    DVBT2.normalTRLoc = normalTRLoc;
    DVBT2.ToneReservedMap = zeros(numdatasymbols,C_PS);
    
    for l=N_P2:(N_P2+numdatasymbols-1)
        if L1pre.BW_EXT
            loc = normalTRLoc + (x*(mod(l+(K_EXT/x),y)));
        else
            loc = normalTRLoc + (x*(mod(l,y)));
        end
        DVBT2.ToneReservedMap((l-N_P2+1),loc) = 1;
    end
    
else
    DVBT2.normalTRLoc = [];
    DVBT2.FCTRLoc = [];
    DVBT2.ToneReservedMap = zeros(numdatasymbols,C_PS);
end
%%
%G. Frame Closing Pilots Location
if L_FC
    DVBT2.FCPilotMap = mod((0:(C_PS-1)),x)==0;
    DVBT2.FCPilotMap([1 end])=1; % Edge pilots in pilot symbol
    if ((NFFT==1024) && any(strcmp(L1pre.pilotpattern,{'PP4','PP5'}))) || ((NFFT==2048) && strcmp(L1pre.pilotpattern,'PP7'))
        DVBT2.FCPilotMap(C_PS-1)= 1; %Additional pilot in these cases
    end
    DVBT2.FCPLoc = find(DVBT2.FCPilotMap); % Matlab indexed
    FCRefSeqMap = xor(PN_SEQ(N_P2+numdatasymbols+1),Prbs);
    DVBT2.FCPilotMap = DVBT2.FCPilotMap.*(2*Asp*(0.5-FCRefSeqMap));
else
    DVBT2.FCPilotMap = [];
    DVBT2.FCPLoc = [];
end
%%
%H. Data Carrier Distribution
symbols = zeros(L1pre.numdatasymbols,C_PS);
if L_FC
    symbols(end,:) = DVBT2.FCPilotMap;
end
symbols(1:numdatasymbols,:) = DVBT2.Scatteredpilotmap;
symbols(1:numdatasymbols,:) = DVBT2.Continualpilotmap+symbols(1:numdatasymbols,:);
if ~isempty(DVBT2.ToneReservedMap)
    symbols(1:numdatasymbols,:) = DVBT2.ToneReservedMap+symbols(1:numdatasymbols,:);
end
DVBT2.DataMap = (~symbols); % Map indicating (with 1)  location of data carriers over whole frame
DVBT2.DataLoc = find(DVBT2.DataMap.'); %Linear indeces for data carriers (NOTE: map has been transposed)
%%
%B1. Number of Active Cell in FC symbol
CFCTable = [ ...
402	654	490	707	544	0 0 0; ...
804	1309 980 1415 1088 0 1396 0; ...
1609 2619 1961 2831 2177 0 2792 0; ...
3218	5238	3922	5662	4354 0 5585 0; ...
3264	5312	3978	5742	4416 0 5664 0 ;...
6437	10476	7845	11324	8709	11801	11170 0; ...
6573	10697	8011	11563	8893	12051	11406 0; ...
0 20952 0 22649 0 23603 0 0; ...
0 21395 0 23127 0 24102 0 0; ...
];


% Scattered pilots location
switch L1pre.pilotpattern
  case 'PP1'
    c = 1;
  case 'PP2'
    c = 2;
  case 'PP3'
    c = 3;
  case 'PP4'
    c = 4;
  case 'PP5'
    c = 5;
  case 'PP6'
    c = 6;
  case 'PP7'
    c = 7;
  case 'PP8'
    c = 8;
end

switch NFFT
    case 1024
        r=1;
    case 2048
        r=2;
    case 4096
        r=3;
    case 8192
        r=4;
    case 16384
        r=6;
    case 32768
        r=8;
end
if (L1pre.BW_EXT), r=r+1; end

DVBT2.C_FC = CFCTable(r,c) - length(DVBT2.FCTRLoc);

end
