clear all; close all; clc;
%% Read from ETTUS BIN file
addpath('..\demod-remod\Demod')
addpath('.\OutputRCF')

%% -----------------------------------------------------------------------------%
% USER INPUT
%-------------------------------------------------------------------------------%

filename = 'Batch_110_Frame_1of1_ETTUS_TEST_19.rcf';

% Plot P1 for debugging
PlotP1 = 1; % Set to 1 to plot P1 detections (Debugging)

% Demod-Remod Parameters
demodREMODwrite = 1; % Set to 1 to write Demod-Remod frame to file
OutfilePrefix = 'DemodRemod';
GuardSetting = 1; % 1: Unchanged / 0:Blanking
PilotSetting = 2; % 0: Blanking / 1: Equalisation (4/7) / 2: Unchanged / 3: Custom
CustomPilot = 0; % Pilot amplitude if custom is selected above

%-------------------------------------------------------------------------------%

%% Read RCF Data
fprintf('Read RCF File..\n')
clear oInputRCFHeader;
oInputRCFHeader = cRCF;
oInputRCFHeader.readHeaderFromFile(filename);
RCF = oInputRCFHeader.readFromFile(filename, 1, oInputRCFHeader.m_NSamples);
RefData_new = RCF.m_fvReferenceData;
SurvData_new = RCF.m_fvSurveillanceData;
fprintf('RCF Read Complete..\n')

%% Perform P1 Detection
[P1Loc, P1foffset] = P1FastDetection(RefData_new,PlotP1);
fprintf('P1 Location: %s\n', num2str(P1Loc))
fprintf('Number of Valid Frames: %s\n\n', num2str(length(P1Loc)-1))

%% Perform Demod-Remods
Outputfile = [OutfilePrefix filename(1:end-4)];
[RefDataDemodRemod_new, SurvDataDemodRemod_new] = DemodremodFast(RefData_new,SurvData_new,P1Loc,P1foffset,Outputfile,GuardSetting,CustomPilot,PilotSetting, demodREMODwrite);

figure()
plot(abs(fftshift(fft(RefDataDemodRemod))))
figure()
plot(abs(fftshift(fft(SurvDataDemodRemod))))