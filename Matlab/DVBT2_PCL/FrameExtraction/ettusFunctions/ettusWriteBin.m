%% WRITE REFERENCE AND SURVEILLANCE DATA TO BIN FILE
function ettusWriteBin( filename, RefData, SurvData )
% Takes in filename, reference data, surveillance data and outputs a bin 
% file.

    % Write file to OutputBIN folder
    if (exist('./OutputBIN'))
        filename = ['./OutputBIN/' filename];
    else
        mkdir './OutputBIN'
        filename = ['./OutputBIN/' filename];
    end
    
    fprintf('Writing BIN file..\n')
    fileID = fopen(filename,'w');
    
    % combine reference and surveillance channels to write
    % The Ettus board saves data in 32k chunks x 2 channels 16k I 16k Q
    % interleaved
    RawData = zeros(length(RefData)*2+length(SurvData)*2,1);
    for x = 1:floor(length(RefData)/16/1024)
        % First 64k samples is ref data place I and Q data after each other
        % Need to split I and Q values
        RawData((2*x-2)*32*1024+1:2:(2*x-2)*32*1024+32*1024) = real(RefData(((x-1)*16*1024+1):((x-1)*16*1024+16*1024)));
        RawData((2*x-2)*32*1024+2:2:(2*x-2)*32*1024+32*1024) = imag(RefData(((x-1)*16*1024+1):((x-1)*16*1024+16*1024)));
        % Next 64k samples is surv data place I and Q data after each other
        RawData((2*x-1)*32*1024+1:2:(2*x-1)*32*1024+32*1024) = real(SurvData(((x-1)*16*1024+1):((x-1)*16*1024+16*1024)));
        RawData((2*x-1)*32*1024+2:2:(2*x-1)*32*1024+32*1024) = imag(SurvData(((x-1)*16*1024+1):((x-1)*16*1024+16*1024)));
    end
    
    if floor(length(RefData)/16/1024) ~= length(RefData)/16/1024 
        x = x+1;
        RawData((2*x-2)*32*1024+1:2:(2*x-2)*32*1024+length(RefData(((x-1)*16*1024+1):end))*2) = real(RefData(((x-1)*16*1024+1):end));
        RawData((2*x-2)*32*1024+2:2:(2*x-2)*32*1024+length(RefData(((x-1)*16*1024+1):end))*2) = imag(RefData(((x-1)*16*1024+1):end));
        
        RawData((2*x-2)*32*1024+length(RefData(((x-1)*16*1024+1):end))*2+1:2:end) = real(SurvData(((x-1)*16*1024+1):end));
        RawData((2*x-2)*32*1024+length(RefData(((x-1)*16*1024+1):end))*2+2:2:end) = imag(SurvData(((x-1)*16*1024+1):end));
    end
    
    % Note: 'ieee-be' indicates big endian
    fwrite( fileID, RawData, 'double', 0, 'ieee-be');
    fclose(fileID);
    
    fprintf('File write complete..\n')
end