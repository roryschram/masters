function ARDMatrix = InvFilter(refData,survData,proc,DVBT2)
    %% We can exclude the P1 and P2 symbols as well as the Aux symbol at the end of each frame
    tic
    RefSymbolData(DVBT2.EndCarrier - DVBT2.StartCarrier + 1, DVBT2.nSymbols-1) = 0;
    SurvSymbolData(DVBT2.EndCarrier - DVBT2.StartCarrier + 1, DVBT2.nSymbols-1) = 0;

    for i = 1:DVBT2.nSymbols-1
        % Fetch symbol
        temp1= fftshift(fft(refData((DVBT2.P1Length+DVBT2.guard+DVBT2.symbol+DVBT2.guard+(i-1)*(DVBT2.symbol)+(i-1)*(DVBT2.guard)) : (DVBT2.P1Length+DVBT2.guard+DVBT2.symbol+DVBT2.guard+(i-1)*(DVBT2.symbol)+(i-1)*(DVBT2.guard)+DVBT2.symbol-1))));    
        % Cut out dead carriers
        RefSymbolData(:,i) = temp1(DVBT2.StartCarrier:DVBT2.EndCarrier); 
        temp2= fftshift(fft(survData((DVBT2.P1Length+DVBT2.guard+DVBT2.symbol+DVBT2.guard+(i-1)*(DVBT2.symbol)+(i-1)*(DVBT2.guard)) : (DVBT2.P1Length+DVBT2.guard+DVBT2.symbol+DVBT2.guard+(i-1)*(DVBT2.symbol)+(i-1)*(DVBT2.guard)+DVBT2.symbol-1))));   
        SurvSymbolData(:,i) = temp2(DVBT2.StartCarrier:DVBT2.EndCarrier);
    end 
    clear temp1 temp2

    % Transpose such that each row corresponds to a unique carrier
    RefSymbolData = RefSymbolData.';
    SurvSymbolData = SurvSymbolData.';
    
    if proc.cancel == 2
        SurvSymbolData = ECA_CD(RefSymbolData, SurvSymbolData, proc, DVBT2);
    end
    
    switch proc.WindowType
        case 1
            tempRow = blackman(DVBT2.nSymbols-1).';
            tempCol = blackman(DVBT2.EndCarrier - DVBT2.StartCarrier + 1);
        case 2
            tempRow = hamming(DVBT2.nSymbols-1).';
            tempCol = hamming(DVBT2.EndCarrier - DVBT2.StartCarrier + 1);
        case 3
            tempRow = hann(DVBT2.nSymbols-1).';
            tempCol = hann(DVBT2.EndCarrier - DVBT2.StartCarrier + 1);
        otherwise
            tempRow = ones(DVBT2.nSymbols-1, 1).';
            tempCol = ones(DVBT2.EndCarrier - DVBT2.StartCarrier + 1, 1);
    end
    Window = tempCol*tempRow;

    % Calculate ARD by inverse filtering
    H = SurvSymbolData./RefSymbolData.*(Window.');
    ARDMatrix = fftshift(fft2(H)).';
    % Format correctly
    RangeShift = -1; % This is used to align things up properly in range (Its not quite correct)
    DopplerShift = mod(size(ARDMatrix,2)+1,2)+1; % Cuts off one Doppler line if even to center plot around 0
    ARDMatrix = flipud(ARDMatrix(floor(length(ARDMatrix)/2)-proc.nRangeBins-RangeShift:(floor(length(ARDMatrix)/2)-RangeShift),DopplerShift:end));
    clear H RefSymbolData SurvSymbolData
    toc
end