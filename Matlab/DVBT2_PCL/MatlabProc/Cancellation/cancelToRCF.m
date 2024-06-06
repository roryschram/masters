%% cancellation parameters
function [] = cancelToRCF(inputRCFFilename, comment, CancellationMaxRange_m, CancallationMaxDoppler_Hz, CancellationNInterations, CancellationNSegments, TxToReferenceRxDistance_m)

fprintf('Input file: %s..\n', inputRCFFilename)

OutputFile = ['CANCELLED_' inputRCFFilename];

fprintf('Output file: %s..\n', OutputFile)
%% Processing Parameters:
fprintf('Reading %s ..\n', inputRCFFilename)
oInputRCFHeader = cRCF;
oInputRCFHeader.readHeaderFromFile(inputRCFFilename);

Fs = oInputRCFHeader.m_Fs_Hz;
Bw = oInputRCFHeader.m_Fs_Hz;
Fc = oInputRCFHeader.m_Fc_Hz;

CPISize_nSamp = oInputRCFHeader.getFs_Hz();
CGLSAlpha = 0;

%Read data
oCPIRCF = oInputRCFHeader.readFromFile(inputRCFFilename, 1, oInputRCFHeader.m_NSamples);

fprintf('Doing cancellation..\n');
tic
[oCPIRCF, CGLSAlpha] = CGLS_Cancellation(oCPIRCF, CancellationMaxRange_m, CancallationMaxDoppler_Hz, TxToReferenceRxDistance_m, CancellationNSegments, CancellationNInterations, CGLSAlpha);
%oCPIRCF = ECA_Cancellation(oCPIRCF, CancellationMaxRange_m, CancallationMaxDoppler_Hz, TxToReferenceRxDistance_m, CancellationNSegments);
toc
fprintf('Cancellation complete..\n')
addpath('.\\makeRCF')
FrameToRCF(oCPIRCF.m_fvReferenceData,oCPIRCF.m_fvSurveillanceData,Fc,Fs,Bw,OutputFile,comment);