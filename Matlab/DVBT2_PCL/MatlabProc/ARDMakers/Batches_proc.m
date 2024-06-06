function ARDMatrix = Batches_proc(refData, survData, proc)
%Generates an ARD plot for the reference and scattered signals using the
%frequency domain implementation. 

    proc.batchStrideNSamples = ceil(proc.samples / proc.nBatches); %The stride between the starting sample of each batch
    proc.batchNSamples = ceil(proc.batchStrideNSamples * proc.nSampBatches); %The number of samples in each batch. Note that if this is bigger than the stride then the batches overlap. (It shouldn't ever be smaller)
    proc.nRangeBins = ceil((proc.ARDMaxRange_m - proc.TxToRefRxDistance_m) * proc.Fs / proc.c);
    proc.nDopplerBins = floor(proc.ARDMaxDoppler_Hz / ((proc.Fs / proc.batchStrideNSamples) / proc.nBatches)); % Number of bins of 1 side of the Doppler spectrum without DC bin

    fprintf('Calculating ARD map using Batches processing\n')
    fprintf('\t\t* ARD: Starting calculation:\n')
    fprintf('\t\t* Range:   %g to %g km, %g bins\n', proc.TxToRefRxDistance_m / 1000, proc.ARDMaxRange_m / 1000, proc.nRangeBins)
    fprintf('\t\t* Doppler: %g to %g Hz, %g bins\n', -proc.ARDMaxDoppler_Hz, proc.ARDMaxDoppler_Hz, proc.nDopplerBins * 2 + 1)

    CorrelationMatrix = zeros(proc.nRangeBins, proc.nBatches, 'single');
    tic
    timeindicate = 0;
    clear1 = '';
    %Correlation using FFT for each Batch:
    for batchNo = 0:proc.nBatches - 1
        if ((batchNo/(proc.nBatches))*100)>timeindicate
            msg = sprintf('ARD map: %2.2f%% completed',(batchNo/(proc.nBatches))*100+0.1);
            msglength = length(msg);
            disp([clear1 msg])
            timeindicate = timeindicate+0.1;
            clear1 = (repmat(sprintf('\b'), 1, msglength+1));
        end
        %Indexes of this batch in the RCF structure
        batchStartSample = 1 + batchNo * proc.batchStrideNSamples;
        batchStopSample = batchStartSample + proc.batchNSamples;

        %Check for goinging beyond the end of the data set
        if(batchStopSample <= proc.samples)

        else
            %We can't us the full batch size here as it would extend past the
            %end of the RCF sample block so zero pad and read as many samples
            %what are available:
            batchStopSample = proc.samples;
        end

        %second argument of FFTs here creates zero padding as necessary.
        RefFFT = fft( refData(batchStartSample:batchStopSample), proc.batchNSamples);
        SurvFFT = fft( survData(batchStartSample:batchStopSample), proc.batchNSamples);

        IFFTOutput = ifft(SurvFFT .* conj(RefFFT));
        CorrelationMatrix(:,batchNo + 1) = IFFTOutput(1:proc.nRangeBins);
    end

    ARDMatrix = zeros(proc.nRangeBins, 2 * proc.nDopplerBins + 1, 'single');

    for rangeBinNo = 1:proc.nRangeBins
        RangeBin = fftshift(fft(CorrelationMatrix(rangeBinNo,:).*blackman(proc.nBatches)'));
        ARDMatrix(rangeBinNo,:) = RangeBin(proc.nBatches / 2 + 1 - proc.nDopplerBins:proc.nBatches / 2 + 1 + proc.nDopplerBins);   
    end
    fprintf('\n')
    toc
end