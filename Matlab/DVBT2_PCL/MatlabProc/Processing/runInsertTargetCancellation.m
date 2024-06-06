clear all; clc; close all;

% Add path to where file is
addpath('D:\Git\FrameExtraction\OutputRCF\')

addpath('.\Processing')
fprintf('Running insertTarget\n\n')
% Insert targets into the un-normalised, un-cancelled.
inputFilename = 'DemodRemod_Batch_110_Frame_1of1_ETTUS_TEST_19_UNCHANGED_pilots_UNCHANGED_guard.rcf';

MaxRange_m = 300000;
MaxDoppler_Hz = 600; % +- this range
TxToRefRxDistance_m = 12600; % Distance to constantia
noTargets = 2; % Number of targets
% The range, Doppler and SNR needs to be a vector with each one
% corresponding to a target
range = [100000 50000]; 
doppler = [-100 125];
snr = [-50 -65];
fprintf('Finished setting variables..\n')

TargetSim(inputFilename, TxToRefRxDistance_m, noTargets, range, doppler, snr)

%% Do CGLS cancellation and then put output into an RCF file - uses
% un-cancelled reference and surveillance with simulated targets.
addpath('.\Cancellation')
fprintf('Running cancelToRCF\n')
inputRCFFilename = ['SimulatedTarget_' inputFilename];
comment = 'Recorded DVB-T2 data with SIMULATED target in CANCELLED surveillance';
CancellationMaxRange_m = 12680; % approximately 2 range bins
CancellationMaxDoppler_Hz = 5; % approximately 1 Doppler bin either side of 0
CancellationNInterations = 50; 
CancellationNSegments = 4;
fprintf('Finished setting variables..\n')

cancelToRCF(inputRCFFilename, comment, CancellationMaxRange_m, CancellationMaxDoppler_Hz, CancellationNInterations, CancellationNSegments, TxToRefRxDistance_m)

%% Once we have the cancelled RCF, we need to put the normalised reference
% together with the cancelled surveillance.
addpath('.\makeRCF')
fprintf('Running combineRCF\n')
ReferenceFile = inputFilename;
SurveillanceFile = ['CANCELLED_' inputRCFFilename];
outputFile = [SurveillanceFile(1:end-4) 'refNormalised_survTarget.rcf'];
fprintf('Finished setting variables..\n')

combineRCF(ReferenceFile, SurveillanceFile, outputFile)