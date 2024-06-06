clear all, fclose all;
%% INPUT ETTUS FILES
filepath = 'C:\Users\Motlatsi\Desktop\USRP_IQ\';
filename = 'TEST_21.bin';
Fs = 64e6/7;
Fc = 0;
Bw = 64e6/7;
comment = '';
Outputfile = []; % if empty, name is auto generated

ProcLength = 32*1024*2*2000;

PilotSetting = 1;
GuardSetting = 1;
CustomPilot = 3; % Custom Pilot amplitude

%% 
addpath('..\Demod') % Demod Folder location
addpath('..\Remod') % Demod Folder location

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
    Outputfile = sprintf('%s_%s_ETTUS_%s_%s',name,ext,Pilotlvl,Guardlvl);
    fprintf('Auto generated filename in ..\\OutputRCF: %s.rcf \n',Outputfile);
end

[~,name,ext] = fileparts([filepath filename]);
List = dir([filepath filename]);
FileLength = List.bytes;
FileChunks = floor(FileLength/8/ProcLength) + 1;

LastP1_Refsamples = [];
LastP1_Survsamples = [];
%% PROCESS
fid1 = fopen([filepath filename], 'r', 'ieee-be');
if (exist('../OutputRCF'))
    name = ['../OutputRCF/' Outputfile];
else
    mkdir '../OutputRCF'
    name = ['../OutputRCF/' Outputfile];
end

name = sprintf('%s.rcf', name);

% RefDataVectors = cell(FileChunks,1);

for ChunkNum = 1:FileChunks
    disp(['File chunk ' num2str(ChunkNum) ' of ' num2str(FileChunks)]);
    if ChunkNum == FileChunks
        RawData = fread(fid1, (FileLength - (FileChunks - 1)*ProcLength*8)/8, 'double', 0, 'ieee-be');
%         RawData = fread(fid1, ProcLength, 'double', 0, 'ieee-be');
    else
        RawData = fread(fid1, ProcLength, 'double', 0, 'ieee-be');   % The Ettus board saves data in 32k chunks x 2 channels
    end
    
    RawRefData =zeros(length(RawData)/2,1);
    RawSurData = RawRefData;

    for x = 1:(length(RawData)/32/1024/2)
        RawRefData(((x - 1)*32*1024 + 1):((x - 1)*32*1024 + 32*1024)) = RawData(((x - 1)*32*1024*2 + 1):((x - 1)*32*1024*2 + 32*1024));
        RawSurData(((x - 1)*32*1024 + 1):((x - 1)*32*1024 + 32*1024)) = RawData(((x - 1)*32*1024*2 + 1 + 32*1024):(x*32*1024*2));
    end

    RefData = RawRefData(1:2:end) + 1i*RawRefData(2:2:end);
    SurvData = RawSurData(1:2:end) + 1i*RawSurData(2:2:end);
    
    clear RawRefData RawSurData RawData
    [n, d] = rat(279991.2/278400);
    RefData = resample(RefData, n, d).'; % Resampled surveillance data
    SurvData = resample(SurvData, n, d).'; % Resampled reference data
    
    RefData = [LastP1_Refsamples.' RefData].';
    SurvData = [LastP1_Survsamples.' SurvData].';
    if ChunkNum==1 % First Chunk
        oRCF = cRCF;
        oRCF.setFs_Hz(Fs);
        oRCF.setBw_Hz(Bw);
        oRCF.setFc_Hz(Fc);
        [First_P1,LastP1_Refsamples,LastP1_Survsamples, SurvData, RefData] = Demodremod2(RefData,SurvData,Outputfile,GuardSetting,CustomPilot,PilotSetting,ChunkNum);
%         RefDataVectors(ChunkNum,1) = {RefData};
        oRCF.setReferenceData(RefData);
        oRCF.setSurveillanceData(SurvData);
        oRCF.setNSamples(length(oRCF.getSurveillanceData()));
        oRCF.setComment(comment);
        oRCF.setTimeStamp_us(0);
        oRCF.writeToFile(name);
    elseif ChunkNum==FileChunks %Last chunk
        m_Nsamples = oRCF.m_NSamples;
        [~,LastP1_Refsamples,LastP1_Survsamples, SurvData, RefData] = Demodremod2(RefData,SurvData,Outputfile,GuardSetting,CustomPilot,PilotSetting,ChunkNum);
%         RefDataVectors(ChunkNum,1) = {RefData};
        oRCF.setNSamples(oRCF.m_NSamples+length(SurvData));
        oRCF.writeHeaderToFile(name,false);
        appendRCF(name,RefData,SurvData,m_Nsamples)
    else
        [~,LastP1_Refsamples,LastP1_Survsamples, SurvData, RefData] = Demodremod2(RefData,SurvData,Outputfile,GuardSetting,CustomPilot,PilotSetting,ChunkNum);
%         RefDataVectors(ChunkNum,1) = {RefData};
        oRCF.setNSamples(oRCF.m_NSamples+length(SurvData));
        oRCF.writeHeaderToFile(name,false);
        appendRCF(name,RefData,SurvData)
    end
end
fclose all;