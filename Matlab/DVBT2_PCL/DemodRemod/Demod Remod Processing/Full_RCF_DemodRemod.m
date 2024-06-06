clear all, fclose all;


%% INPUT RCF FILES
filepath = '/home/mike/';
filename = 'TEST_19_bin_ETTUS_CGLS.rcf';
Fs = 64e6/7;
Fc = 0;
Bw = 64e6/7;
comment = [];
Outputfile = []; % if empty, name is auto generated

Proclength = 4*(64e6/7);

PilotSetting = 1;
GuardSetting = 1;
CustomPilot = 3; % Custom Pilot amplitude

%% 
Foffset.p1 = [];
Foffset.p2 = [];

addpath('../Demod') % Demod Folder location
addpath('../Remod') % Remod Folder location

oInputRCFHeader = cRCF;
oInputRCFHeader.readHeaderFromFile([filepath filename]);
Nsamples = oInputRCFHeader.m_NSamples;

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

if isempty(Outputfile)
    [~,name,ext] = fileparts([filepath filename]);
    ext = ext(2:end);
    Outputfile = sprintf('%s_%s_%s_%s',name,ext,Pilotlvl,Guardlvl);
    fprintf('Auto generated filename in ..\\OutputRCF: %s.rcf \n',Outputfile);
end

FileChunks = floor(Nsamples/Proclength); % Number of 4 second blocks to consider

%% PROCESS
for ChunkNum = 1:FileChunks % Use 17:20 for Test 19 to get target time
    disp(['File chunk ' num2str(ChunkNum) ' of ' num2str(FileChunks)]);
    RawData = oInputRCFHeader.readFromFile([filepath filename], 1+(ChunkNum-1)*floor(Proclength), floor(Proclength));
    RefData = RawData.m_fvReferenceData;
    RefData = double(RefData);
    SurvData =  RawData.m_fvSurveillanceData;
    SurvData = double(SurvData);
    clear oInputRCFHeader RawData
    OutputName = [Outputfile sprintf('_%uof%u',ChunkNum,FileChunks)]; 
    Demodremod(RefData,SurvData,OutputName,GuardSetting,CustomPilot,PilotSetting,Foffset);
    fprintf('Chunk %u saved in ..\\OutputRCF: %s.rcf \n',ChunkNum,Outputfile);
    oInputRCFHeader = cRCF;
    oInputRCFHeader.readHeaderFromFile([filepath filename]);
end
fclose all;