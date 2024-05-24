addpath('.\OutputRCF')
clear all;
ReferenceFile = 'Batch_82_Frame_15of40_ETTUS_TEST_19.rcf';
% SurveillanceFile = 'DemodRemod_newBatch_110_Frame_1of1_ETTUS_TEST_19_UNCHANGED_pilots_UNCHANGED_guard.rcf';

fprintf('Read first RCF file..\n')
clear oInputRCFHeader;
oInputRCFHeader = cRCF;
oInputRCFHeader.readHeaderFromFile(ReferenceFile);
% RCF_Reference = oInputRCFHeader.readFromFile(ReferenceFile, 1, oInputRCFHeader.m_NSamples);
RCF = oInputRCFHeader.readFromFile(ReferenceFile, 1, oInputRCFHeader.m_NSamples);
% Clear the RCF variable since it causes issues when you try and pull
% multiple files
% fprintf('Read second RCF file..\n')
% clear oInputRCFHeader;
% oInputRCFHeader = cRCF;
% oInputRCFHeader.readHeaderFromFile(SurveillanceFile);
% RCF_Surveillance = oInputRCFHeader.readFromFile(SurveillanceFile, 1, oInputRCFHeader.m_NSamples);

% DemodRemod = RCF_Reference.m_fvReferenceData;
% DemodRemod_new = RCF_Surveillance.m_fvReferenceData;
%%
% figure()
% result = DemodRemod-DemodRemod_new;
% plot(abs(result))
% 
% Surv = RCF_Reference.m_fvSurveillanceData;
% Surv_new = RCF_Surveillance.m_fvSurveillanceData;
% 
% figure()
% resultSurv = Surv-Surv_new;
% plot(abs(resultSurv))

fprintf('Plot Results\n')
RCF_Reference = RCF.m_fvReferenceData;
RCF_Surveillance = RCF.m_fvSurveillanceData;

figure()
subplot(211)
plot(10*log10(abs(fftshift(fft(RCF_Reference)))))
subplot(212)
plot(10*log10(abs(fftshift(fft(RCF_Surveillance)))))   
fprintf('Complete\n')