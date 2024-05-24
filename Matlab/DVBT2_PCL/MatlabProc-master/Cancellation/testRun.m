addpath('/srv/rrsg/data/projects_general/201x_CommensalRadar/Software/MatlabCode/Classes')
addpath('../ARDMakers')

addpath('/srv/rrsg/data/projects_general/201x_CommensalRadar/Software/MatlabCode/ProccessingChain/Single Precision')

clear;
clc;
close all;

inputRCF = '/srv/rrsg/data/projects_general/201x_CommensalRadar/FieldTests/2012-07_VariousLocationsCape/Recordings/2012-07-26/Tygerberg3.rcf';
CPISize_nSamp = 204800 * 4;

oRCF = readRCFFromFile(inputRCF, 204800 * 40, CPISize_nSamp);

% fprintf('Doing XF range/Doppler processing\n');
% tic
% oARD_XF = XF_ARD(oRCF,300000,180,11520);
% toc

fprintf('Doing cancellation\n');
tic
%oRCF = ECA_Cancellation(oRCF, 180000, 8, 11520, 8);
%oRCF = CGLS_Cancellation(oRCF, 250000, 1, 11520, 8, 10, 0);
toc

fprintf('Doing range/Doppler processing\n');
tic
%oARD = Batches_ARD(oRCF,300000,180,11520);
oARD = XF_ARD(oRCF,300000,180,11520);
toc

fprintf('Plotting figure\n');
figure;
oARD.plot2D();
