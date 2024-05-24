function [ RefData_resample, SurvData_resample ] = ettusResample( RefData, SurvData )
%ETTUSRESAMPLE resamples the ettus data.
% This only needs to be done once!

    fprintf('Resampling data..\n')
    [n, d] = rat(279991.2/278400);
    RefData_resample = resample(RefData, n, d).';
    SurvData_resample = resample(SurvData, n, d).';
    clear RefData SurvData
    fprintf('Resampling complete..\n')
        
end

