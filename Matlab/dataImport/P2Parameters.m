function P2 = P2Parameters(NFFT,MISO)
%Desciption : Defines
%             - P2 Pilots (MISO/SISO)
%             - P2 Tone Reservation
%             - P2 Carrier Locations
%             - P2 MISO/SISO
%Inputs:      - NFFT (FFT Size)
%             - MISO (MISO enabled)

%% P2 Carrier information
switch NFFT
  case 1024
    C_PS   = 853;        % Number of carriers per symbol
    N_P2   = 16;         % Number of P2 symbols
    K_EXT  = 0;          % extra carriers on each side in ext carrier mode
    TRLoc = [116  130  134  157  182  256  346  478  479  532]; %Tone Reservation Location (Always reserved)
  case 2048
    C_PS   = 1705;       % Number of carriers per symbol
    N_P2   = 8;          % Number of P2 symbols
    K_EXT  = 0;          % extra carriers on each side in ext carrier mode
    TRLoc = [113, 124, 262, 467, 479, 727, 803, 862, 910, 946, 980, 1201, 1322, 1342, 1396, 1397, 1562, 1565]; %Tone Reservation Location (Always reserved)
  case 4096
    C_PS   = 3409;       % Number of carriers per symbol
    N_P2   = 4;          % Number of P2 symbols
    K_EXT  = 0;          % extra carriers on each side in ext carrier mode
    TRLoc = [104, 116, 119, 163, 170, 173, 664, 886, 1064, 1151, 1196, 1264, 1531, 1736, 1951, 1960, 2069, 2098,...
            2311, 2366, 2473, 2552, 2584, 2585, 2645, 2774, 2846, 2882, 3004, 3034, 3107, 3127, 3148, 3191, 3283,...
            3289]; %Tone Reservation Location (Always reserved)
  case 8192 
    C_PS   = 6817;       % Number of carriers per symbol    
    N_P2   = 2;          % Number of P2 symbols
    K_EXT  = 48;         % extra carriers on each side in ext carrier mode
    TRLoc = [106, 109, 110, 112, 115, 118, 133, 142, 163, 184, 206, 247, 445, 461, 503, 565, 602, 656, 766, 800, 922,...
            1094, 1108, 1199, 1258, 1726, 1793, 1939, 2128, 2714, 3185, 3365, 3541, 3655, 3770, 3863, 4066, 4190,...
            4282, 4565, 4628, 4727, 4882, 4885, 5143, 5192, 5210, 5257, 5261, 5459, 5651, 5809, 5830, 5986, 6020,...
            6076, 6253, 6269, 6410, 6436, 6467, 6475, 6509, 6556, 6611, 6674, 6685, 6689, 6691, 6695, 6698, 6701]; %Tone Reservation Location (Always reserved)
  case 16384 
    C_PS   = 13633;      % Number of carriers per symbol 
    N_P2   = 1;          % Number of P2 symbols
    K_EXT  = 144;        % extra carriers on each side in ext carrier mode
    TRLoc = [104, 106, 107, 109, 110, 112, 113, 115, 116, 118, 119, 121, 122, 125, 128, 131, 134, 137, 140, 143, 161,...
            223, 230, 398, 482, 497, 733, 809, 850, 922, 962, 1196, 1256, 1262, 1559, 1691, 1801, 1819, 1937, 2005,...
            2095, 2308, 2383, 2408, 2425, 2428, 2479, 2579, 2893, 2902, 3086, 3554, 4085, 4127, 4139, 4151, 4163,...
            4373, 4400, 4576, 4609, 4952, 4961, 5444, 5756, 5800, 6094, 6208, 6658, 6673, 6799, 7208, 7682, 8101,...
            8135, 8230, 8692, 8788, 8933, 9323, 9449, 9478, 9868, 10192, 10261, 10430, 10630, 10685, 10828,...
            10915, 10930, 10942, 11053, 11185, 11324, 11369, 11468, 11507, 11542, 11561, 11794, 11912, 11974,...
            11978, 12085, 12179, 12193, 12269, 12311, 12758, 12767, 12866, 12938, 12962, 12971, 13099, 13102,...
            13105, 13120, 13150, 13280, 13282, 13309, 13312, 13321, 13381, 13402, 13448, 13456, 13462, 13463,...
            13466, 13478, 13492, 13495, 13498, 13501, 13502, 13504, 13507, 13510, 13513, 13514, 13516]; %Tone Reservation Location (Always reserved)
  case 32768 
    C_PS   = 27265;      % Number of carriers per symbol     
    N_P2   = 1;          % Number of P2 symbols
    K_EXT  = 288;        % extra carriers on each side in ext carrier mode
    TRLoc = [104, 106, 107, 109, 110, 112, 113, 115, 118, 121, 124, 127, 130, 133, 136, 139, 142, 145, 148, 151, 154,...
            157, 160, 163, 166, 169, 172, 175, 178, 181, 184, 187, 190, 193, 196, 199, 202, 205, 208, 211, 404, 452,...
            455, 467, 509, 539, 568, 650, 749, 1001, 1087, 1286, 1637, 1823, 1835, 1841, 1889, 1898, 1901, 2111,...
            2225, 2252, 2279, 2309, 2315, 2428, 2452, 2497, 2519, 3109, 3154, 3160, 3170, 3193, 3214, 3298, 3331,...
            3346, 3388, 3397, 3404, 3416, 3466, 3491, 3500, 3572, 4181, 4411, 4594, 4970, 5042, 5069, 5081, 5086,...
            5095, 5104, 5320, 5465, 5491, 6193, 6541, 6778, 6853, 6928, 6934, 7030, 7198, 7351, 7712, 7826, 7922,...
            8194, 8347, 8350, 8435, 8518, 8671, 8861, 8887, 9199, 9980, 10031, 10240, 10519, 10537, 10573, 10589,...
            11078, 11278, 11324, 11489, 11642, 12034, 12107, 12184, 12295, 12635, 12643, 12941, 12995, 13001,...
            13133, 13172, 13246, 13514, 13522, 13939, 14362, 14720, 14926, 15338, 15524, 15565, 15662, 15775,...
            16358, 16613, 16688, 16760, 17003, 17267, 17596, 17705, 18157, 18272, 18715, 18994, 19249, 19348,...
            20221, 20855, 21400, 21412, 21418, 21430, 21478, 21559, 21983, 21986, 22331, 22367, 22370, 22402,...
            22447, 22535, 22567, 22571, 22660, 22780, 22802, 22844, 22888, 22907, 23021, 23057, 23086, 23213,...
            23240, 23263, 23333, 23369, 23453, 23594, 24143, 24176, 24319, 24325, 24565, 24587, 24641, 24965,...
            25067, 25094, 25142, 25331, 25379, 25465, 25553, 25589, 25594, 25655, 25664, 25807, 25823, 25873,...
            25925, 25948, 26002, 26008, 26102, 26138, 26141, 26377, 26468, 26498, 26510, 26512, 26578, 26579,...
            26588, 26594, 26597, 26608, 26627, 26642, 26767, 26776, 26800, 26876, 26882, 26900, 26917, 26927,...
            26951, 26957, 26960, 26974, 26986, 27010, 27013, 27038, 27044, 27053, 27059, 27061, 27074, 27076,...
            27083, 27086, 27092, 27094, 27098, 27103, 27110, 27115, 27118, 27119, 27125, 27128, 27130, 27133,...
            27134, 27140, 27143, 27145, 27146, 27148, 27149]; %Tone Reservation Location (Always reserved)
end

CPS_EXT = C_PS + 2*K_EXT;

P2.CPS_EXT = CPS_EXT;
CLOC_EXT = NFFT/2-(CPS_EXT-1)/2+1:NFFT/2+(CPS_EXT-1)/2+1;
P2.C_PS = C_PS;
P2.NFFT = NFFT;
P2.N_P2 = N_P2;
TRLoc = TRLoc+1; % Used for matlab indexing
C_LOC = NFFT/2-(C_PS-1)/2+1:NFFT/2+(C_PS-1)/2+1; % calculate FFT bins for used carriers
kmin = NFFT/2-(C_PS-1)/2+1;
kmax = NFFT/2+(C_PS-1)/2+1;
P2.C_LOC = C_LOC;
P2.C_LOC_EXT = CLOC_EXT;
P2.TRLoc = TRLoc;
P2.kmin = kmin;
P2.kmax = kmax;

%% P2 Pilot Location
if (NFFT==32768)&&(MISO==0)
    k = 6; %carrier separation between pilots = 6
    A_P2 = sqrt(37)/5;  %Amplitude of P2 pilots
else
    k = 3; %carrier separation between pilots = 3 
    A_P2 = sqrt(31)/5;
end
P2.DX = k;
P2Pilots = zeros(1, C_PS);
P2Pilots(1:k:C_PS) = 1; % every 3 or 6

if (MISO)
    P2Pilots(2:3) = 1;
    P2Pilots(C_PS-2: C_PS-1) = 1;
    % TR partners
    P2Pilots(TRLoc(mod(TRLoc-1,3)==1)+1) = 1;
    P2Pilots(TRLoc(mod(TRLoc-1,3)==2)-1) = 1;
    P2Pilots(TRLoc) = 0; % Expunge any that are already reserved tones
end

P2.P2PLoc = find(P2Pilots); % Indices of all P2 pilots (Referenced to matlab indexing)
P2.P2_EXT_Loc = P2.P2PLoc+K_EXT;
if K_EXT, P2.P2_EXT_Loc = [1:K_EXT P2.P2_EXT_Loc (CPS_EXT-K_EXT+1):CPS_EXT];end

%% Available Data Carriers Per Symbol
C_P2 = C_PS - length(P2.P2PLoc) - length(TRLoc);
P2.C_P2 = C_P2; % Number of Data carriers per P2 symbol

%Data Carrier Locations
D_Loc = zeros(1,C_PS);
D_Loc(P2.P2PLoc)=1;
D_Loc(TRLoc)=1;
D_Loc=find(D_Loc==0);
P2.D_Loc = D_Loc;

%% PN Sequence  (Hex to Binary) and PRBS used for Pilot mapping
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

%
srBin = ones(1,11); % Shift register content
prbsBin = zeros(1,C_PS+2*K_EXT); % Initialize output

% PRBS Sequence
CPS1 = C_PS + 2*K_EXT;
for n=1:CPS1
  prbsBin(n) = srBin(11); % Output
  
  tran = xor(srBin(11), srBin(9)); % XOR bits 11 and 9
  srBin = [tran srBin(1:10)];
end


Prbs = prbsBin(K_EXT+1:CPS1-K_EXT);


%% P2 Pilot Map
P2PilotMap = repmat(P2Pilots,N_P2,1);
for i = 1:N_P2
    
    P2PilotMap(i,:) = xor((PN_SEQ(i)),(Prbs)).*P2PilotMap(i,:);
end
P2PilotMap(:,P2.P2PLoc) = 2*A_P2*(0.5-P2PilotMap(:,P2.P2PLoc));
P2PilotMap(P2PilotMap==1) = 0;
P2.P2PilotMap = P2PilotMap;

%% Extended carrier P2 Map used for integer offset
ExtendedP2Map = zeros(1,NFFT);
ExtendedP2Map(1,C_LOC) = P2Pilots;
ExtendedP2Map = ExtendedP2Map(1,CLOC_EXT);
ExtendedP2Map(1:K_EXT) = 1;
ExtendedP2Map(end:end-K_EXT) = 1;
ExtendedP2Map = repmat(ExtendedP2Map,N_P2,1);
for i = 1:N_P2
    ExtendedP2Map(i,:) = xor((PN_SEQ(i)),(prbsBin)).*ExtendedP2Map(i,:);
end
ExtendedP2Map(:,P2.P2_EXT_Loc) = 2*A_P2*(0.5-ExtendedP2Map(:,P2.P2_EXT_Loc));
ExtendedP2Map(ExtendedP2Map==1) = 0;
P2.ExtendedP2Map = ExtendedP2Map;

%figure(100)
%subplot(211)
%plot((P2PilotMap),'.')
%title('P2PilotMap')
%subplot(212)
%plot(ExtendedP2Map,'.')
%title('ExtendedP2Map')

%% Pilot sets for interger offset estimation with P2 symbol
if NFFT>=16384
    %Split pilot map and note indices of pilots in the halves (ignore dc carrier)
    setone = P2.P2_EXT_Loc(1:floor(length(P2.P2_EXT_Loc)/2));
    settwo = P2.P2_EXT_Loc((floor(length(P2.P2_EXT_Loc)/2)+2):1:end);
    %Lookup table: find pilots which are equal in the two halves
    lookup = ExtendedP2Map(setone)==ExtendedP2Map(settwo);
    %
    P2.Set1 = setone(lookup);
    P2.Set2 = settwo(lookup);
else
%     %Split pilot map and note indices of pilots in the halves (ignore dc carrier)
%     setone = P2.ExtendedP2Map(1,P2.P2_EXT_Loc);
%     settwo = P2.ExtendedP2Map(2,:);
%     settwo = circshift(settwo,[0 3]);
%     settwo = settwo(P2.P2_EXT_Loc);
%     %Lookup table: find pilots which are equal in the two halves
%     lookup = setone==settwo;
%     P2.Set1 = P2.P2_EXT_Loc(lookup);
%     P2.Set2 = P2.P2_EXT_Loc(lookup+3);
    
    %Split pilot map and note indices of pilots in the halves (ignore dc carrier)
    setone = P2.P2_EXT_Loc(1:floor(length(P2.P2_EXT_Loc)/2));
    settwo = P2.P2_EXT_Loc((floor(length(P2.P2_EXT_Loc)/2)+2):1:end);
    %Lookup table: find pilots which are equal in the two halves
    lookup = ExtendedP2Map(setone)==ExtendedP2Map(settwo);
    %
    P2.Set1 = setone(lookup);
    P2.Set2 = settwo(lookup);

end
    


P2.A_P2 = A_P2;
end