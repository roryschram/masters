%% Create new RCF file from two old RCF datasets (for CAF processing)
function [] = combineRCF(ReferenceFile, SurveillanceFile, outputFile)
addpath('.\Classes')
clear oInputRCFHeader

% Import RCF data
fprintf('Reading reference: %s..\n', ReferenceFile)
oInputRCFHeader = cRCF;
oInputRCFHeader.readHeaderFromFile(ReferenceFile);
RCF_Reference = oInputRCFHeader.readFromFile(ReferenceFile, 1, oInputRCFHeader.m_NSamples);
% Clear the RCF variable since it causes issues when you try and pull
% multiple files
fprintf('Reading surveillance: %s..\n', SurveillanceFile)
clear oInputRCFHeader;
oInputRCFHeader = cRCF;
oInputRCFHeader.readHeaderFromFile(SurveillanceFile);
RCF_Surveillance = oInputRCFHeader.readFromFile(SurveillanceFile, 1, oInputRCFHeader.m_NSamples);

%% Set oRCF parameters
fprintf('Setting new RCF parameters..\n')
oRCF = cRCF;
oRCF.setFs_Hz(oInputRCFHeader.m_Fs_Hz);
oRCF.setBw_Hz(oInputRCFHeader.m_Bw_Hz);
oRCF.setFc_Hz(RCF_Reference.m_Fc_Hz);
oRCF.setReferenceData(RCF_Reference.m_fvReferenceData);
oRCF.setSurveillanceData(RCF_Surveillance.m_fvSurveillanceData);
oRCF.setNSamples(oInputRCFHeader.m_NSamples);
oRCF.setComment(oInputRCFHeader.m_strComment);
oRCF.setTimeStamp_us(0);

% Write to RCF
fprintf('Writing RCF object to file...\n');
oRCF.writeToFile(outputFile);
fprintf('Complete\n');

%% Read RCF to check that its correct
% oInputRCFHeader = cRCF;
% inputRCFFilename = outputFile;
% oInputRCFHeader.readHeaderFromFile(inputRCFFilename);
% NewRCF = oInputRCFHeader.readFromFile(inputRCFFilename, 1, 1000);

clear all;