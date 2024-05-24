function  appendRCF(strFilename,m_fvReferenceData,m_fvSurveillanceData,m_NSamples)

switch nargin
    case 3
        outFile = fopen(strFilename, 'ab');

        total = length(m_fvSurveillanceData);
        timeindicate = 0;
        clear1 = '';
        for ii = 1:length(m_fvReferenceData)
            if ((ii/total)*100)>timeindicate
                msg = sprintf('RCF Write: %2.2f%% completed',(ii/total)*100);
                msglength = length(msg);
                disp([clear1 msg])
                timeindicate = timeindicate+0.1;
                clear1 = (repmat(sprintf('\b'), 1, msglength+1));
            end
            fwrite(outFile, real(m_fvReferenceData(ii)), 'float32');
            fwrite(outFile, imag(m_fvReferenceData(ii)), 'float32');
            fwrite(outFile, real(m_fvSurveillanceData(ii)), 'float32');
            fwrite(outFile, imag(m_fvSurveillanceData(ii)), 'float32');
        end
        fclose(outFile);
    case 4 
        outFile = fopen(strFilename, 'rb+');
        fseek(outFile, 52 + m_NSamples * 16, 'bof');
        
        total = length(m_fvSurveillanceData);
        timeindicate = 0;
        clear1 = '';
        for ii = 1:length(m_fvReferenceData)
            if ((ii/total)*100)>timeindicate
                msg = sprintf('RCF Write: %2.2f%% completed',(ii/total)*100);
                msglength = length(msg);
                disp([clear1 msg])
                timeindicate = timeindicate+0.1;
                clear1 = (repmat(sprintf('\b'), 1, msglength+1));
            end
            fwrite(outFile, real(m_fvReferenceData(ii)), 'float32');
            fwrite(outFile, imag(m_fvReferenceData(ii)), 'float32');
            fwrite(outFile, real(m_fvSurveillanceData(ii)), 'float32');
            fwrite(outFile, imag(m_fvSurveillanceData(ii)), 'float32');
        end
        fclose(outFile);
end