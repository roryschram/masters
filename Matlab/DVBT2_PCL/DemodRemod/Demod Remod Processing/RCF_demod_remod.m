% Demod Remod Batch Script for RCF files (Works for pilot equalization and guard unchanged)
clear all; clc;
addpath('..\Demod') % Demod Folder location
addpath('..\Remod') % Remod Folder location

%% INPUT PARAMETERS
addpath('D:\Git\FrameExtraction')
filepath = ('D:\Git\FrameExtraction');
Outputfile = []; % if empty, name is auto generated
PilotSetting = 1; %Pilot blanking 0/ equalisation 1/ unchanged 2/ custom 3
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

%% Demod RCF data
for i=1:1
    File = 'Frame_1098_1of3_ETTUS_TEST_19.rcf';
    %%
    fprintf('Read RCF file..\n')
    clear oInputRCFHeader RCF Ref Surv;
    oInputRCFHeader = cRCF;
    oInputRCFHeader.readHeaderFromFile(File);
    RCF = oInputRCFHeader.readFromFile(File, 1, oInputRCFHeader.m_NSamples);
    Ref = RCF.m_fvReferenceData;
    Surv = RCF.m_fvSurveillanceData;

    %% OUTPUT FILE NAME GENERATION
    if isempty(Outputfile)
        [~,name,ext] = fileparts([filepath File]);
        ext = ext(2:end);
        Outputfile = sprintf('%s_%s_%s_%s',name,ext,Pilotlvl,Guardlvl);
        fprintf('Auto generated filename in ..\\OutputRCF: %s.rcf \n',Outputfile);
    end
    %%
    Demodremod(Ref,Surv,Outputfile,GuardSetting,CustomPilot,PilotSetting)
end