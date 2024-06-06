clear all; close all; clc;
addpath('../Classes')
addpath('C:\Users\Stephen\Desktop\DVBT\FM test 21')
addpath('C:\Users\Stephen\Desktop\DVBT\Test21')

% Read in the output of the PXGF to Matlab (HDF5) conversion.
% filename = 'Test21.mat';

% refName = 'FM_test_21_0.bin';
% survName = 'FM_test_21_1.bin';

refName = 'test21_0.bin';
survName = 'test21_1.bin';

% Set RCF parameters
startSample = 0;
outputFile = 'test_21_DVBT_test.rcf';
Fs_Hz = 9142857;
Fc_Hz = 702000000;
comment = char('ComRAD DVB-T2 data');

%% Read bin data
fid = fopen(refName, 'rb'); 
data = fread(fid, 1000000, 'int16'); %Gives 5000 complex samples. 
fclose(fid); 
RefData = data(1:2:end) + j*data(2:2:end);

fid = fopen(survName, 'rb'); 
data = fread(fid, 1000000, 'int16'); %Gives 5000 complex samples. 
fclose(fid); 
SurvData = data(1:2:end) + j*data(2:2:end);

%% Read .mat data
% % Use the below command to see the variables in the file.
% % whos('-file', filename)
% load(filename, 'GSNC_data2');
% %
% fprintf('File read completed\n');
% 
% RefData= double(GSNC_data2(:,1));
% SurvData = double(GSNC_data2(:,2));

%% Complex conjugate the signals to flip the spectrum
% This is due to a mistake in the ComRad software which was causing the
% spectrum to be inverted during recording.
% Any recordings made after 20/12/2017 will probably not require this step.

RefData = conj(RefData);
SurvData = conj(SurvData);

%% Set oRCF parameters
oRCF = cRCF;
oRCF.setFs_Hz(Fs_Hz);
oRCF.setBw_Hz(Fs_Hz);
oRCF.setFc_Hz(Fc_Hz);
oRCF.setReferenceData(RefData);
oRCF.setSurveillanceData(SurvData);
oRCF.setNSamples(length(oRCF.getSurveillanceData()));
oRCF.setComment(comment);
oRCF.setTimeStamp_us(0);
% Write to RCF
fprintf('Writing RCF object to file...\n');
oRCF.writeToFile(outputFile);
fprintf('Complete\n');
%% Read RCF file
% addpath('../OutputRCF')
% outputFile = 'MalmesburyRx';
% outputFile = 'test_21_DVBT';
oInputRCFHeader = cRCF;
inputRCFFilename = outputFile;
oInputRCFHeader.readHeaderFromFile(inputRCFFilename);
RCF = oInputRCFHeader.readFromFile(inputRCFFilename, 1, 1000);