clear all;
clc;
close all;

% data_size = (327.68e6)/2;
% IQ_Name = 'TEST_31.bin';
% Fdir = '/home/mike/PC/'
% List = dir([Fdir IQ_Name '.bin']);
% 
% FileLength = List.bytes;
%% INPUT PARAMETERS
addpath('../Demod');

filepath = '/home/mike/PC/';
filename = 'TEST_20.bin';

fprintf('Converting\n');
Outputfile = []; % if empty, name is auto generated

%% LOAD DATA FROM ETTUS BIN FILES
List = dir([filepath filename]);
FileLength = List.bytes;
% batch = 0;
Nr_of_Batches = ceil(FileLength/(2.62144e9));

for batch=0:(Nr_of_Batches-1);
    fid1 = fopen([filepath filename], 'r', 'ieee-be');
    fseek(fid1, 2.62144e9*batch, 'bof');
    RawData = fread(fid1, 32*1024*2*5000, 'double', 0, 'ieee-be');   % The Ettus board saves data in 32k chunks x 2 channels
    RawRefData(length(RawData)/2) = 0;
    RawSurData(length(RawData)/2) = 0;

    for x = 1:(length(RawData)/32/1024/2)
    RawRefData(((x - 1)*32*1024 + 1):((x - 1)*32*1024 + 32*1024)) = RawData(((x - 1)*32*1024*2 + 1):((x - 1)*32*1024*2 + 32*1024));
    RawSurData(((x - 1)*32*1024 + 1):((x - 1)*32*1024 + 32*1024)) = RawData(((x - 1)*32*1024*2 + 1 + 32*1024):(x*32*1024*2));
    end

    RefData = RawRefData(1:2:end) + 1i*RawRefData(2:2:end);
    SurData = RawSurData(1:2:end) + 1i*RawSurData(2:2:end);
    clearvars -except RefData SurData filepath filename Outputfile GuardSetting CustomPilot PilotSetting Guardlvl Pilotlvl batch Nr_of_Batches 
    [n, d] = rat(279991.2/278400);
    RefData = resample(RefData, n, d).';
    SurData = resample(SurData, n, d).';
  
    fprintf('done\n');

    Fc = 706e6;
    NS = length(RefData);
    Fs = (64e6)/7;
    Bw = 7.768e6;
    % name = 'PXGF_21';

    comment = sprintf('This binary data batch %d of %d of TEST_21.bin',(batch+1),Nr_of_Batches);

%%
    if isempty(Outputfile)
        [~,name,ext] = fileparts([filepath filename]);
        ext = ext(2:end);
        Outputfile = sprintf('%s_%s_ETTUS_%d_%d',name,ext,(batch+1),Nr_of_Batches);
        fprintf('Auto generated filename in ..\\OutputRCF: %s.rcf \n',Outputfile);
    end

    FrametoRCF(RefData,SurData,Fc,Fs,Bw,Outputfile,comment);
    Outputfile = [];
end



