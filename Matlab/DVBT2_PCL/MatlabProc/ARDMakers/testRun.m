addpath('/srv/rrsg/data/projects_general/201x_CommensalRadar/Software/MatlabCode/Classes')

clear;
clc;
close all;

inputRCF = '/srv/rrsg/data/projects_general/201x_CommensalRadar/FieldTests/2012-07_VariousLocationsCape/Recordings/2012-07-26/Tygerberg3_cancelled.rcf';
CPISize_nSamp = 204800 * 4;

oRCF = readRCFFromFile(inputRCF, 204800 * 40, CPISize_nSamp);

fprintf('Doing XF range/Doppler processing\n');
tic
oARD_XF = XF_ARD(oRCF,300000,180,11520);
toc

fprintf('Plotting figure\n');
figure;
oARD_XF.plot2D();
oARD_XF.writeToFile('/home/craigt/ARD_XFAlgorithm.ard');

% 
% fprintf('\n\n');
% 
% fprintf('Doing FX range/Doppler processing\n');
% tic
% oARD_FX = FX_ARD(oRCF,300000,180,11520);
% toc
% 
% fprintf('Plotting figure\n');
% figure;
% oARD_FX.plot2D();

fprintf('\n\n');

fprintf('Doing Batches range/Doppler processing\n');
tic
oARD_Batches = Batches_ARD(oRCF,300000,180,11520);
toc

fprintf('Plotting figure\n');
figure;
oARD_Batches.plot2D();
oARD_Batches.writeToFile('/home/craigt/ARD_BatchesAlgorithm.ard');

%figure;
%oARD2 = cARD;
%oARD2.readFromFile('/srv/rrsg/data/projects_general/201x_CommensalRadar/FieldTests/2012-07_VariousLocationsCape/ARDs/2012-07-26_Tygerberg/MRD7050/Tygerberg3/2012-07-26T15.37.58.920203.ard');
%oARD2.plot2D();