function FrametoRCF_Notoggle(Ref,Surv,NSamples,Fc,Fs,Bw,name)
%Ref is the IQ reference channel
%Surv is the IQ surveillance channel
%NSample is the number of samples in each channel. Should be the same
%Fc is the carrier frequency
%Fs is the sampling frequency
%Bw is the bandwidth of the signal
%name is the name the .rcf file should be stored as


%NOTE: The RCF file will be stored in the directory above the directory
%that the code was ran from in a seperate folder. 

if (exist('../OutputRCF'))
    name = ['../OutputRCF/' name];
else
    mkdir '../OutputRCF'
    name = ['../OutputRCF/' name];
end

name = sprintf('%s.rcf', name);
outFile = fopen(name, 'a');

oRCF.m_Bw_Hz = Bw;
oRCF.m_Fs_Hz = Fs;
oRCF.m_Fc_Hz = Fc;
oRCF.m_TimeStamp_us = 0;
oRCF.m_FileType = 'rcf';
oRCF.m_FileType = [oRCF.m_FileType 0];
oRCF.m_NSamples = NSamples;
HEADER_SIZE = 52;
oRCF.m_CommentOffset_B = HEADER_SIZE + oRCF.m_NSamples * 16;
oRCF.m_strComment = '';
oRCF.m_CommentLength = length(oRCF.m_strComment);
oRCF.m_FileSize_B = oRCF.m_CommentLength + oRCF.m_CommentOffset_B;

oRCF.m_fvReferenceData = Ref;
oRCF.m_fvSurveillanceData = Surv;

total = length(Ref);
timeindicate = 0;
clear1 = '';

        %Fresh write to file
        fwrite(outFile, oRCF.m_FileType, 'char*1');
        fwrite(outFile, oRCF.m_TimeStamp_us, 'int64');
        fwrite(outFile, oRCF.m_Fc_Hz, 'int32');
        fwrite(outFile, oRCF.m_Fs_Hz, 'int32');
        fwrite(outFile, oRCF.m_Bw_Hz, 'int32');
        %Nsample_location = ftell(outFile);
        fwrite(outFile, oRCF.m_NSamples, 'uint64');
        fwrite(outFile, oRCF.m_CommentOffset_B, 'uint64');
        fwrite(outFile, oRCF.m_CommentLength, 'uint32');
        fwrite(outFile, oRCF.m_FileSize_B, 'uint64');
        
        for ii = 1:length(Ref)
            
            if ((ii/total)*100)>timeindicate
                msg = sprintf('RCF Write: %2.2f%% completed',(ii/total)*100);
                msglength = length(msg);
                disp([clear1 msg])
                timeindicate = timeindicate+0.1;
                clear1 = (repmat(sprintf('\b'), 1, msglength+1));
            end
            
            fwrite(outFile, real(oRCF.m_fvReferenceData(ii)), 'float32');
            fwrite(outFile, imag(oRCF.m_fvReferenceData(ii)), 'float32');
            fwrite(outFile, real(oRCF.m_fvSurveillanceData(ii)), 'float32');
            fwrite(outFile, imag(oRCF.m_fvSurveillanceData(ii)), 'float32');
        end
        %toggle = toggle+1;
        fclose(outFile);
        
        clear all

end