% Demod Remod Batch Script for ETTUS files (Works for pilot equalization and guard unchanged)
%%
% TODO: read directory of ETTUS files and process a batch of ETTUS files
clear all
addpath('..\Demod') % Demod Folder location
addpath('..\Remod') % Remod Folder location

%% INPUT PARAMETERS
filepath = 'C:\Users\Motlatsi\Desktop\USRP_IQ\';
filename = 'TEST_22.bin';
Outputfile = []; % if empty, name is auto generated
PilotSetting = 1; %Pilot blanking 0/equalisation 1/unchanged 2/custom 3
GuardSetting = 1; %guard interval blanking 0 or unchanged 1
CustomPilot = 3; % Custom Pilot amplitude
%%
switch PilotSetting
    case 0
        Pilotlvl = 'BlankPilot';
    case 1
        Pilotlvl = 'EQPilot';
    case 2
        Pilotlvl = 'UnchangedPilot';
    case 3
        Pilotlvl = 'CustomPilot';
    otherwise
        fprintf('Signal Reconstruction settings - Invalid Pilot setting. Pilots are unchanged \r\n')
        PilotSetting = 2;
        Pilotlvl = 'UnchangedPilot';
end

switch GuardSetting
    case 0
        Guardlvl = 'Guard0';
    case 1
        Guardlvl = 'Guard1';
    otherwise
        GuardSetting = 1;
        Guardlvl = 'Guard1';
end
%% LOAD DATA FROM ETTUS BIN FILES
List = dir([filepath filename]);
FileLength = List.bytes;
fid1 = fopen([', 0,filepath filename], 'r', 'ieee-be');
RawData = fread(fid1, 32*1024*2*2000, 'double 'ieee-be');   % The Ettus board saves data in 32k chunks x 2 channels
RawRefData(length(RawData)/2) = 0;
RawSurData(length(RawData)/2) = 0;

for x = 1:(length(RawData)/32/1024/2)
    RawRefData(((x - 1)*32*1024 + 1):((x - 1)*32*1024 + 32*1024)) = RawData(((x - 1)*32*1024*2 + 1):((x - 1)*32*1024*2 + 32*1024));
    RawSurData(((x - 1)*32*1024 + 1):((x - 1)*32*1024 + 32*1024)) = RawData(((x - 1)*32*1024*2 + 1 + 32*1024):(x*32*1024*2));
end

RefData = RawRefData(1:2:end) + 1i*RawRefData(2:2:end);
SurData = RawSurData(1:2:end) + 1i*RawSurData(2:2:end);
clearvars -except RefData SurData filepath filename Outputfile GuardSetting CustomPilot PilotSetting Guardlvl Pilotlvl
[n, d] = rat(279991.2/278400);
RefData = resample(RefData, n, d).';
SurData = resample(SurData, n, d).';

%% OUTPUT FILE NAME GENERATION
if isempty(Outputfile)
    [~,name,ext] = fileparts([filepath filename]);
    ext = ext(2:end);
    Outputfile = sprintf('%s_%s_ETTUS_%s_%s',name,ext,Pilotlvl,Guardlvl);
    fprintf('Auto generated filename in ..\\OutputRCF: %s.rcf \n',Outputfile);
end
Demodremod(RefData,SurData,Outputfile,GuardSetting,CustomPilot,PilotSetting)

%% Demod Remod