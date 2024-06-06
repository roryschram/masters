clear
clc

filename = '/srv/rrsg/data/projects_general/201x_CommensalRadar/FieldTests/2012-07_VariousLocationsCape/Recordings/2012-08-07/Tygerberg_1.rcf';
nSamp = 204800 * 180;

oRCF1 = cRCF;
oRCF2 = cRCF;

fprintf('oRCF1 : Reading %i samples with Mex Function...\n', nSamp);
tic
oRCF1 = readRCFFromFile(filename, 0, nSamp);
toc

fprintf('\noRCF2 : Reading %i samples with Matlab Function...\n', nSamp);
tic
oRCF2.readFromFile(filename, 1, nSamp);
toc

diff1 = oRCF1.getReferenceData - oRCF2.getReferenceData;
diff2 = oRCF1.getSurveillanceData - oRCF2.getSurveillanceData;

fprintf('\nCompare samples of read data:\n')
fprintf('(oRCF1.ReferenceData - oRCF2.ReferenceData): min = %f, max = %f\n', min(diff1), max(diff1));
fprintf('(oRCF1.SurveillanceData - oRCF2.SurveillanceData): min = %f, max = %f\n', min(diff2), max(diff2));