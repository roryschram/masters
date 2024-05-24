function FrametoRCF(RefData,SurvData,Fc,Fs,Bw,name,comment)
% Description: Write Data to RCF File
% Inputs:  FrameIQ  - IQ data to be written
%          NSamples - Number of samples to be written
%          Fc       - Carrier Frequency
%          Fs       - Sampling Frequency
%          Bw       - Bandwidth
%          name     - output filename
%          toggle   - toggle to write header information or not
%          Nsample_location - Byte number where Nsamples is written in rcf file
% Outputs: toggle - toggle to write header information or not
%          Nsample_location - Byte number where Nsamples is written in rcf file

%RCF file location
if (exist('./OutputRCF'))
    name = ['./OutputRCF/' name];
else
    mkdir './OutputRCF'
    name = ['./OutputRCF/' name];
end

name = sprintf('%s.rcf', name);

oRCF =cRCF;

oRCF = cRCF;
oRCF.setFs_Hz(Fs);
oRCF.setBw_Hz(Bw);
oRCF.setFc_Hz(Fc);
oRCF.setReferenceData(RefData);
oRCF.setSurveillanceData(SurvData);
oRCF.setNSamples(length(oRCF.getSurveillanceData()));
oRCF.setComment(comment);
oRCF.setTimeStamp_us(0);

% RCF File writing time console display variables
fprintf('Writing RCF object to file...\n');
oRCF.writeToFile(name);
fprintf('Complete\n');

end

