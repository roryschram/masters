function [ ] = saveARD( ARDMatrix, Filename, oRCF, proc, colourMap, DR, look )
    C = 299792458; %speed of the light (m/s)
    
    ARDMatrix = abs(ARDMatrix).^2;

    %% Write ARD to File
    Filename = [Filename '.ard'];

    % Put ARD into correct folder
    if (exist('.\OutputARD'))
        Filename = ['.\OutputARD\' Filename];
    else
        mkdir '.\OutputARD'
        Filename = ['.\OutputARD\' Filename];
    end

    oARD = cARD;
    oARD.setDataMatrix(transpose(ARDMatrix));
    oARD.setRangeResolution_m(C / proc.Fs);
    oARD.setDopplerResolution_Hz(proc.Fs / proc.samples);
    oARD.setTimeStamp_us(oRCF.getTimeStamp_us());
    oARD.setFc_Hz(oRCF.getFc_Hz());
    oARD.setFs_Hz(proc.Fs);
    oARD.setBw_Hz(oRCF.getBw_Hz());
    oARD.setTxRxDistance_m(proc.TxToRefRxDistance_m);
    oARD.setFilename(oARD.timeStampToString());
    fprintf('\n')
    oARD.writeToFile(Filename);
    fprintf('ARD write complete\n\n');

    %% Colormap key
    % 1 = jet
    % 3 = winter
    % 3 = hsv
    % 4 = hot
    % 5 = parula
    % 6 = autum
    % 7 = summer
    % 8 = spring
    % 9 = gray

    % Plot 2D function
    figure();
    % Can use (km or m) (m/s or Hz)
    oARD.plot2D('m','Hz',0,-DR,colourMap);

    % Plot 3D function
    figure();
    % x units, y units, z units, colormap
    oARD.plot3D('km','Hz',0,-DR,colourMap,look);
end

