addpath('.\ARDMakers')
addpath('.\Cancellation')
addpath('.\Classes')
addpath('.\OutputRCF');

% clear;
% clc;
% close all;

% NOTE: THIS WILL ONLY WORK ON THE FIRST SURVEILLANCE CHANNEL
%       IT WILL NEED TO BE MODIFIED IN ORDER TO PROCESS THE 
%       SECOND SURVEILLANCE CHANNEL

%% Processing Parameters:

inputRCFFilename = 'test_21.rcf';
oInputRCFHeader = cRCF;
oInputRCFHeader.readHeaderFromFile(inputRCFFilename);

% CPISize_nSamp = oInputRCFHeader.getFs_Hz() * 0.2;
% Chosen to be close to 0.2 seconds at Fs and divisible by 4.
CPISize_nSamp = 1828568;

CancellationMaxRange_m = 45000;
CancallationMaxDoppler_Hz = 2; %Ranges from - to + of this value
CancellationNInterations = 20; % For CGLS
CancellationNSegments = 4; %Number segments each CPI is split into for cancellation

ARDMaxRange_m = 45000;
ARDMaxDoppler_Hz = 700; %Ranges from - to + of this value
TxToReferenceRxDistance_m = 12500;

outputARDPath = '.\ARDs';

%% Loop per CPI:
nCPIs = floor(oInputRCFHeader.getNSamples() / CPISize_nSamp);
CPIStartSampleNumber =  0;
CGLSAlpha = 0;

for CPINo = 0:nCPIs - 1

fprintf('Processing CPI %i of %i:\n', CPINo + 1, nCPIs);

%Read data
oCPIRCF = oInputRCFHeader.readFromFile(inputRCFFilename, CPIStartSampleNumber+1, CPISize_nSamp);

%Now advance starting sample by 1 CPI for next interation
CPIStartSampleNumber = CPIStartSampleNumber + CPISize_nSamp;

fprintf('Doing cancellation\n');
tic
[oCPIRCF, CGLSAlpha] = CGLS_Cancellation(oCPIRCF, CancellationMaxRange_m, CancallationMaxDoppler_Hz, TxToReferenceRxDistance_m, CancellationNSegments, CancellationNInterations, CGLSAlpha);
%oCPIRCF = ECA_Cancellation(oCPIRCF, CancellationMaxRange_m, CancallationMaxDoppler_Hz, TxToReferenceRxDistance_m, CancellationNSegments);
toc

fprintf('Doing range/Doppler processing\n');
tic
% oARD = Batches_ARD(oCPIRCF, ARDMaxRange_m, ARDMaxDoppler_Hz, TxToReferenceRxDistance_m);
oARD = FX_ARD(oCPIRCF,ARDMaxRange_m, ARDMaxDoppler_Hz,TxToReferenceRxDistance_m);
%oARD = XF_ARD(oCPIRCF, ARDMaxRange_m, ARDMaxDoppler_Hz, TxToReferenceRxDistance_m);
toc

%Write ARD to file:
ARDFilename = outputARDPath;
if(ARDFilename(length(ARDFilename)) ~= '/')
    ARDFilename = [ARDFilename '/'];
end

% ARDFilename = [ARDFilename oARD.timeStampToString(), '.ard'];
ARDFilename = [ARDFilename num2str(CPINo), '.ard'];

oARD.writeToFile(ARDFilename);

fprintf('\n\n');

end