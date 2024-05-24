function L1 = L1predecoding(L1pre)
%Description: Extraction of Data sybmol parameters in the L1 pre signaling
% Inputs: L1pre - L1 pre bits (200 bits long)
% Ouputs: L1 - L1 pre parameters
% Reference: DVBT2 standard

%Input:
L1.type = L1pre(1:8);% 8 bits Type of stream (Transport Stream or Generic Stream or Both) %Not relevant to demod-remod
L1.BW_EXT = L1pre(9);% 1 bit Bandwidth extended or not
L1.S1 = L1pre(10:12);% 3 bitsMISO/SISO
L1.S1Value = bi2de((L1.S1).','left-msb');
L1.S2 = L1pre(13:16);% 4 bits FFT Size
L1.S2Value = bi2de((L1.S2).','left-msb');
L1.repetition_flag = L1pre(17);% 1 bit Indicate appearance of L1 dynamic signalling for next frame
L1.GI = L1pre(18:20);% 3 bits Guard interval fraction
L1.PAPR = L1pre(21:24);% 4 bits PAPR used (either ACE or TR)
L1.L1mod = L1pre(25:28);% 4 bits modulation used on L1 post signalling
L1.L1cod = L1pre(29:30);% 2 bits code rate on L1 post signalling (always 1/2)
L1.L1fectype = L1pre(31:32);% 2 bits L1 post fec type (always 16k ldpc)
L1.L1postsize = L1pre(33:50);% 18 bits number of cells taken by L1 post in P2 symbols
L1.L1postinfosize = L1pre(51:68);% 18 bits size of L1 post(config+dynamic+extension) in bits (excl. CRC) 
L1.pilotpattern = L1pre(69:72);% 4 bits Data Pilot pattern 
L1.txidavailability = L1pre(73:80);% 8 bits Tx id
L1.cellid = L1pre(81:96);% 16 bits Cell id
L1.networkid=L1pre(97:112);% 16 bits network id
L1.t2systemid = L1pre(113:128);% 16 bits system id 
L1.numt2frames = L1pre(129:136);% 8 bits number of T2 frames per superframe
L1.numdatasymbols = L1pre(137:148);% 12 bits number of data symbols within frame
L1.regenflag = L1pre(149:151);% 3 bits indicates number of times signalhas been regenerated
L1.L1postextension = L1pre(152);% 1 bit indicates presence of l1 post extension
L1.numrf = L1pre(153:155);% 3 bits number of rf frequencie in T2 system 
L1.currentRFidx = L1pre(156:158);% 3 bits index of current RF channel
L1.t2version = L1pre(159:162);% 4 bits version of T2 being used 
L1.L1postscrambled = L1pre(163);% 1 bit indicates scrambling
L1.t2baselite = L1pre(164);% 1 bit indicates compatibility with T2-lite
L1.reserved = L1pre(165:168);% 4 bits reserved for future use
L1.CRC32 = L1pre(169:200);% CRC32 error detection code 

if all(L1.type==[0 0 0 0 0 0 0 0].')
    L1.type = 'Transport Stream only';
elseif all(L1.type == [0 0 0 0 0 0 0 1].')
    L1.type = 'Generic Stream';
elseif all(L1.type == [0 0 0 0 0 0 1 0].')
    L1.type = 'TS and Generic Stream';
else
    L1.type = 'Reserved for future use';
end

if all(L1.S1== [0 0 0].')
    L1.S1 = 0;
elseif all(L1.S1== [0 0 1].')
    L1.S1 = 1;
else
    L1.S1 = 'Reserved for future use';
end

switch L1.S2(4)
    case 1
        L1.FEF = 1; % Mixed FEF, preambles of different types
    case 0
        L1.FEF = 0; % Normal
end

if all(L1.S2(1:3)==[0 0 0].')
    L1.S2 = 2048;
elseif  all(L1.S2(1:3)==[0 0 1].')
    L1.S2 = 8192;
elseif  all(L1.S2(1:3)==[0 1 0].')
    L1.S2 = 4096;
elseif  all(L1.S2(1:3)==[0 1 1].')
    L1.S2 = 1024;
elseif  all(L1.S2(1:3)==[1 0 0].')
    L1.S2 = 16384;
elseif  all(L1.S2(1:3)==[1 0 1].')
    L1.S2 = 32768;
elseif  all(L1.S2(1:3)==[1 1 0].')
    L1.S2 = 8192;
elseif  all(L1.S2(1:3)==[1 1 1].')
    L1.S2 = 32768;
else
    L1.S2 = 'Undefined input to S2';
end

if all(L1.GI == [0 0 0].')
    L1.GI = 1/32;
elseif all(L1.GI == [0 0 1].')
    L1.GI = 1/16;
elseif all(L1.GI == [0 1 0].')
    L1.GI = 1/8;
elseif all(L1.GI == [0 1 1].')
    L1.GI = 1/4;
elseif all(L1.GI == [1 0 0].')
    L1.GI = 1/128;
elseif all(L1.GI == [1 0 1].')
    L1.GI = 19/128;
elseif all(L1.GI == [1 1 0].')
    L1.GI = 19/256;
else
    L1.GI = 'Unknown: Undefined input';
end

if all(L1.PAPR == [0 0 0 0].')
    L1.PAPR = 'No PAPR';
elseif all(L1.PAPR == [0 0 0 1].')
    L1.PAPR = 'ACE PAPR';
elseif all(L1.PAPR == [0 0 1 0].')
    L1.PAPR = 'TR PAPR';
elseif all(L1.PAPR == [0 0 1 1].')
    L1.PAPR = 'Both TR and ACE used';
else
    L1.PAPR = 'TR PAPR'; % Unknown case, assumed tone reservation
end

if all(L1.L1mod == [0 0 0 0].')
    L1.L1mod = 'BPSK';
    L1.L1cpoints = [1 -1];
    L1.L1C = 1; %Normalization Factor
    L1.L1V = 1; %Bits per cell
elseif all(L1.L1mod == [0 0 0 1].')
    L1.L1mod = 'QPSK';
    L1.L1cpoints = [1+1i 1-1i -1+1i -1-1i];
    L1.L1C = sqrt(2);
    L1.L1V = 2;
elseif all(L1.L1mod == [0 0 1 0].')
    L1.L1mod = '16-QAM';
    L1.L1cpoints = [3+3i 3+1i 1+3i 1+1i 3-3i 3-1i 1-3i 1-1i -3+3i -3+1i -1+3i ...
        -1+1i -3-3i -3-1i -1-3i -1-1i];
    L1.L1C = sqrt(10);
    L1.L1V = 4;
elseif all(L1.L1mod == [0 0 1 1].')
    L1.L1mod = '64-QAM';
    L1.L1cpoints = [7+7i 7+5i 5+7i 5+5i 7+1i 7+3i 5+1i 5+3i 1+7i 1+5i 3+7i ...
        3+5i 1+1i 1+3i 3+1i 3+3i 7-7i 7-5i 5-7i 5-5i 7-1i 7-3i ...
        5-1i 5-3i 1-7i 1-5i 3-7i 3-5i 1-1i 1-3i 3-1i 3-3i -7+7i ...
        -7+5i -5+7i -5+5i -7+1i -7+3i -5+1i -5+3i -1+7i -1+5i ...
        -3+7i -3+5i -1+1i -1+3i -3+1i -3+3i -7-7i -7-5i -5-7i ...
        -5-5i -7-1i -7-3i -5-1i -5-3i -1-7i -1-5i -3-7i -3-5i ...
        -1-1i -1-3i -3-1i -3-3i];
    L1.L1C = sqrt(42);
    L1.L1V = 6;
else
    L1.L1mod = 'Unknown';
    L1.L1cpoints = 'Unknown';
    L1.L1C = 'Unknown';
    L1.L1V = 'Unknown';
end

L1.L1cod = 1/2;
L1.L1fectype = 16200; %Lenth of LDPC frame for L1 post

L1.L1postsize = num2str(L1.L1postsize); 
L1.L1postsize(L1.L1postsize==' ')='';
L1.L1postsize = bin2dec(L1.L1postsize.');

L1.L1postinfosize = num2str(L1.L1postinfosize);
L1.L1postinfosize(L1.L1postinfosize==' ')='';
L1.L1postinfosize = bin2dec(L1.L1postinfosize.');

if all(L1.pilotpattern == [0 0 0 0].')
    L1.pilotpattern = 'PP1';
elseif all(L1.pilotpattern == [0 0 0 1].')
    L1.pilotpattern = 'PP2';
elseif all(L1.pilotpattern == [0 0 1 0].')
    L1.pilotpattern = 'PP3';
elseif all(L1.pilotpattern == [0 0 1 1].')
    L1.pilotpattern = 'PP4';
elseif all(L1.pilotpattern == [0 1 0 0].')
    L1.pilotpattern = 'PP5';
elseif all(L1.pilotpattern == [0 1 0 1].')
    L1.pilotpattern = 'PP6';
elseif all(L1.pilotpattern == [0 1 1 0].')
    L1.pilotpattern = 'PP7';
elseif all(L1.pilotpattern == [0 1 1 1].')
    L1.pilotpattern = 'PP8';
else
    L1.pilotpattern = 'Unknown';
end
        
L1.numt2frames = num2str(L1.numt2frames);
L1.numt2frames(L1.numt2frames==' ')='';
L1.numt2frames = bin2dec(L1.numt2frames.');

L1.numdatasymbols = num2str(L1.numdatasymbols);
L1.numdatasymbols(L1.numdatasymbols==' ')='';
L1.numdatasymbols = bin2dec(L1.numdatasymbols.');

if all(L1.t2version == [0 0 0 0].')
    L1.t2version = '1.1.1';
elseif all(L1.t2version ==  [0 0 0 1].')
    L1.t2version = '1.2.1';
elseif all(L1.t2version == [0 0 1 0].')
    L1.t2version = '1.3.1';
else
    L1.t2version = '1.1.1';
end

end