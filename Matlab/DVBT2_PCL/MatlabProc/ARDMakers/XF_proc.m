function ARDMatrix = XF_proc(refData, survData, proc)
    tic
    timeindicate = 0;
    clear1 = '';
        
    fprintf('Calculating ARD map using XF processing\n')
    fprintf('\t\t* ARD: Starting calculation:\n')
    fprintf('\t\t* Range:   %g to %g km, %g bins\n', proc.TxToRefRxDistance_m / 1000, proc.ARDMaxRange_m / 1000, proc.nRangeBins)
    fprintf('\t\t* Doppler: %g to %g Hz, %g bins\n', -proc.ARDMaxDoppler_Hz, proc.ARDMaxDoppler_Hz, proc.nDopplerBins * 2 + 1)
    ARDMatrix = zeros(proc.nRangeBins, 2 * proc.nDopplerBins + 1, 'single');
        
    for shift = 0:proc.nRangeBins - 1
    % time to completion console display
        if ((shift/(proc.nRangeBins-1))*100)>timeindicate
            msg = sprintf('ARD map: %2.2f%% completed',(shift/(proc.nRangeBins-1))*100);
            msglength = length(msg);
            disp([clear1 msg])
            timeindicate = timeindicate+0.1;
            clear1 = (repmat(sprintf('\b'), 1, msglength+1));
        end

        FFTInput = zeros(proc.samples, 1, 'single'); % Create vector with number of sample points
        FFTOutput = zeros(proc.samples, 1, 'single');

        FFTInput(1 + shift:proc.samples) = survData(1 + shift:proc.samples).' .* conj(refData(1:proc.samples - shift)).';

        FFTInput = FFTInput.*proc.Window; %window the result

        FFTOutput = fftshift(fft(FFTInput)); %FFT of the above product

        %Discard frequency bins not of interest
        ARDMatrix(shift + 1,:) = FFTOutput(floor(proc.samples/2) + 1 - proc.nDopplerBins:floor(proc.samples/2 ) + 1 + proc.nDopplerBins);
    end
    fprintf('\n\n')
    toc
end
    
