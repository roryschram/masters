clear all;fclose all;
%% INPUT ETTUS FILES
filepath = 'C:\Users\Motlatsi\Desktop\DVBT2 Signal Reconstruction - Home\recording\';
filename = 'TEST_19.bin';
Fs = 64e6/7;
Fc = 0;
Bw = 64e6/7;
comment = '';
Outputfile = []; % if empty, name is auto generated
%% 

addpath('..\Demod') % Demod Folder location
[~,name,ext] = fileparts([filepath filename]);
List = dir([filepath filename]);
FileLength = List.bytes;

ProcLength = 32*1024*2*136;
% ProcLength = 32*1024*2*1362;

FileChunks = floor(FileLength/8/ProcLength) + 1;
% FileChunks = floor((FileLength/8/ProcLength)/52) + 1;
%% HARD CODED PARAMETERS
cancellationMaxRange_m = 50000;
cancellationMaxDoppler_Hz = 3;
txToRefRxDistance_m = 12600;
nSegments = 10;
nIterations = 10;
initialAlpha = 0;
nCPIs = [];

%% PROCESS
fid1 = fopen([filepath filename], 'r', 'ieee-be');

if isempty(Outputfile)
    [~,name,ext] = fileparts([filepath filename]);
    ext = ext(2:end);
    Outputfile = sprintf('%s_%s_ETTUS_CGLS',name,ext);
    fprintf('Auto generated filename in ..\\OutputRCF: %s.rcf \n',Outputfile);
end


if (exist('../OutputRCF'))
    name = ['../OutputRCF/' Outputfile];
else
    mkdir '../OutputRCF'
    name = ['../OutputRCF/' Outputfile];
end
name = sprintf('%s.rcf', name);


SurvDataVectors = cell(FileChunks,1);

for ChunkNum = 1:FileChunks
    disp(['File chunk ' num2str(ChunkNum) ' of ' num2str(FileChunks)]);
    if ChunkNum == FileChunks
        RawData = fread(fid1, (FileLength - (FileChunks - 1)*ProcLength*8)/8, 'double', 0, 'ieee-be');
%         RawData = fread(fid1, ProcLength, 'double', 0, 'ieee-be');   % The Ettus board saves data in 32k chunks x 2 channels
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
    RefData = resample(RefData, n, d); % Resampled surveillance data
    SurvData = resample(SurvData, n, d); % Resampled reference data
        
    if ChunkNum==1 % First Chunk
        oRCF = cRCF;
        oRCF.setFs_Hz(Fs);
        oRCF.setBw_Hz(Bw);
        oRCF.setFc_Hz(Fc);
        oRCF.setReferenceData(RefData);
        [initialAlpha,SurvData] = ProcLat(RefData,SurvData, cancellationMaxRange_m, cancellationMaxDoppler_Hz, txToRefRxDistance_m, nSegments, nIterations, initialAlpha);      
        SurvDataVectors(ChunkNum,1) = {SurvData};
        oRCF.setSurveillanceData(SurvData);
        oRCF.setNSamples(length(oRCF.getSurveillanceData()));
        oRCF.setComment(comment);
        oRCF.setTimeStamp_us(0);
        oRCF.writeToFile([name]);
    elseif ChunkNum==FileChunks %Last chunk
        m_Nsamples = oRCF.m_NSamples;
        [initialAlpha,SurvData] = ProcLat(RefData,SurvData, cancellationMaxRange_m, cancellationMaxDoppler_Hz, txToRefRxDistance_m, nSegments, nIterations, initialAlpha);  
        SurvDataVectors(ChunkNum,1) = {SurvData};
        oRCF.setNSamples(oRCF.m_NSamples+length(SurvData))
        oRCF.writeHeaderToFile(name,false);
        appendRCF(name,RefData(1:length(SurvData)),SurvData,m_Nsamples)
    else
        [initialAlpha,SurvData] = ProcLat(RefData,SurvData, cancellationMaxRange_m, cancellationMaxDoppler_Hz, txToRefRxDistance_m, nSegments, nIterations, initialAlpha);  
        SurvDataVectors(ChunkNum,1) = {SurvData};
        oRCF.setNSamples(oRCF.m_NSamples+length(SurvData));
        oRCF.writeHeaderToFile(name,false);
        appendRCF(name,RefData(1:length(SurvData)),SurvData)
    end
end
fclose all