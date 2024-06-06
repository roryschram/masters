function ARDMatrix = FX_proc(refData, survData, proc)
    tic
    timeindicate = 0;
    clear1 = '';
    
    fprintf('Calculating ARD map using FX processing\n')
    fprintf('\t\t* ARD: Starting calculation:\n')
    fprintf('\t\t* Range:   %g to %g km, %g bins\n', proc.TxToRefRxDistance_m / 1000, proc.ARDMaxRange_m / 1000, proc.nRangeBins)
    fprintf('\t\t* Doppler: %g to %g Hz, %g bins\n', -proc.ARDMaxDoppler_Hz, proc.ARDMaxDoppler_Hz, proc.nDopplerBins * 2 + 1)

    %initialisation of temporary variables
    FFTInput = zeros(proc.samples, 1, 'single');
    FFTOutput = zeros(proc.samples, 1, 'single');

    ARDMatrix = zeros(proc.nRangeBins, 2 * proc.nDopplerBins + 1, 'single');

    RefFFT = fft( refData.*proc.Window );
    SurvFFT = fft( survData.*proc.Window );

    zeroDopplerBinNo = proc.nDopplerBins + 1;
    IFFTOutput = zeros(1,proc.nRangeBins, 'single');

    %Negative Doppler:
    for DopplerShift = 1:proc.nDopplerBins
        if ((DopplerShift/(proc.nDopplerBins))*100)>timeindicate
            msg = sprintf('ARD map: %2.2f%% completed',(DopplerShift/(proc.nDopplerBins))*50);
            msglength = length(msg);
            disp([clear1 msg])
            timeindicate = timeindicate+0.1;
            clear1 = (repmat(sprintf('\b'), 1, msglength+1));
        end
        IFFTInput = zeros(1,proc.nRangeBins, 'single'); %For padding
        IFFTInput(1:proc.samples - DopplerShift) = SurvFFT(1:proc.samples - DopplerShift).* conj(RefFFT(1 + DopplerShift:proc.samples));
        IFFTOutput = ifft(IFFTInput);
        ARDMatrix(:, zeroDopplerBinNo - DopplerShift) = IFFTOutput(1:proc.nRangeBins);
    end

    %Zero Doppler
    IFFTInput = SurvFFT.* conj(RefFFT);
    IFFTOutput = ifft(IFFTInput);
    ARDMatrix(:, zeroDopplerBinNo) = IFFTOutput(1:proc.nRangeBins);

    %Positive Doppler
    for DopplerShift = 1:proc.nDopplerBins 
        if ((DopplerShift/(proc.nDopplerBins))*100)>timeindicate
            msg = sprintf('ARD map: %2.2f%% completed',50+(DopplerShift/(proc.nDopplerBins))*50);
            msglength = length(msg);
            disp([clear1 msg])
            timeindicate = timeindicate+0.1;
            clear1 = (repmat(sprintf('\b'), 1, msglength+1));
        end     
        IFFTInput = zeros(1,proc.nRangeBins, 'single'); %For padding
        IFFTInput(1 + DopplerShift:proc.samples) = SurvFFT(1 + DopplerShift:proc.samples).* conj(RefFFT(1:proc.samples - DopplerShift));
        IFFTOutput = ifft(IFFTInput);
        ARDMatrix(:, zeroDopplerBinNo + DopplerShift) = IFFTOutput(1:proc.nRangeBins);
    end   
    fprintf('\n')
    toc
end