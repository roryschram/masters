%% LOAD DATA FROM ETTUS BIN FILES
function [RefData, SurvData] = ettusReadBin( filepath, filename, Frame, FrameLength )
    
    fprintf('Reading BIN file..\n')
    fid1 = fopen([filepath filename], 'r', 'ieee-be');
    fseek(fid1, FrameLength*Frame, 'bof'); % fileID, Offset in Bytes, Start point
    RawData = fread(fid1, FrameLength, 'double', 0, 'ieee-be');   % The Ettus board saves data in 32k chunks x 2 channels

    for x = 1:(length(RawData)/32/1024/2);
        RawRefData(((x - 1)*32*1024 + 1):((x - 1)*32*1024 + 32*1024)) = RawData(((x - 1)*32*1024*2 + 1):((x - 1)*32*1024*2 + 32*1024));
        RawSurvData(((x - 1)*32*1024 + 1):((x - 1)*32*1024 + 32*1024)) = RawData(((x - 1)*32*1024*2 + 1 + 32*1024):(x*32*1024*2));
    end

    if mod(length(RawRefData),2) == 0
        RefData = RawRefData(1:2:end) + 1i*RawRefData(2:2:end);
        SurvData = RawSurvData(1:2:end) + 1i*RawSurvData(2:2:end);
    else
        RefData = RawRefData(1:2:end-1) + 1i*RawRefData(2:2:end);
        SurvData = RawSurvData(1:2:end-1) + 1i*RawSurvData(2:2:end);
    end
   
    clear RawRefData RawSurvData
end