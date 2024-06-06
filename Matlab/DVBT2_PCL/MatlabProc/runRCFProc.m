clear all; 
close all; clc;
addpath('.\ARDMakers')
addpath('.\Cancellation')
addpath('.\Classes')
addpath('.\makeRCF')
addpath('.\Processing')
addpath('.\TestFrames')
addpath('.\..\demod-remod\Demod')
addpath('.\..\demod-remod\Remod')

%% Break the code up to exclude demod-remod and just import existing data
import = 0;

if import == 0
    % Fixed environmental variables
    C = 299792458; %speed of the light (m/s)
    
    %-----------------------------------------------------------------------------
    
    % Toggle the cancellation off (0), CGLS (1), ECA-CD (2)
    proc.cancel = 0;
    % Toggle writing cancelled RCF on (1) or off (0) - Only works with CGLS
    write.Cancel = 0;
    % Toggle inserting targets on (1) or off (0)
    proc.targets = 0;
    % Toggle jamming on (1) or off (0)
    proc.jam = 0;
    % Toggle writing RCF on (1) or off (0)
    write.Jam = 0;
    % Toggle range-Doppler processing off (0), XF (1), FX (2), InverseFilter (3), Batches (4)
    rangeDoppler = 0; 
    % Togle figure plots on (1) or off (0)
    plotFigures = 1;

    % Demod-Remod Parameters
    PlotP1 = 1;
    demodREMODwrite = 0; % Set to 1 to write Demod-Remod frame to file
    OutfilePrefix = 'DemodRemod';
    GuardSetting = 1; % 1: Unchanged / 0:Blanking
    PilotSetting = 2; % 0: Blanking / 1: Equalisation (4/7) / 2: Unchanged / 3: Custom
    CustomPilot = 10; % Pilot amplitude if custom is selected above

    % Pilot parameters for jamming each one manipulated individually
    % Can be set to any specific value
    JamPilotSetting.Cp = (3/8)^2; % 0 for blanking, 1 for unchanged, (3/8)^2 for equalisation
    JamPilotSetting.Sp = (4/7)^2; % (4/7)^2 for equalisation
    JamPilotSetting.P2 = (4/7)^2; % (4/7)^2 for equalisation
    JamPilotSetting.Guard = 1; % Set to 0 to blank, 1 to leave unchanged
    
    %-----------------------------------------------------------------------------
    
    %% Read reference data BIN FILE
    % fprintf('Reading reference data\n')
    % fid = fopen('Test1_0.bin', 'rb');
    % data = fread(fid,'int16');7
    % fclose(fid);
    % ref = conj(data(1:2:end) + j*data(2:2:end));
    % % Note we need to take the conjugate because the spectrum is flipped at the
    % % output of the comrad. This has been fixed but these tests contained the
    % % flip
    % REF = 20*log10(fftshift(fft(ref)));
    % 
    %% Read surveillance data BIN FILE
    % fprintf('Reading surveillance data\n')
    % fid = fopen('Test1_1.bin', 'rb');
    % data = fread(fid,'int16'); % Note, if you want to take a specific length of data, use fread('Test1_1.bin',10000,'rb'), giving 5000 samples
    % fclose(fid);
    % sur = conj(data(1:2:end) + j*data(2:2:end));
    % % Note we need to take the conjugate because the spectrum is flipped at the
    % % output of the comrad. This has been fixed but these tests contained the
    % % flip
    % SUR = 20*log10(fftshift(fft(sur)));
    % clear data; % Clear for memory purposes

    %% Read Reference and Surveillance data from RCF FILE
    RCFfilename = 'TestFrame_1of1_ETTUS_TEST_19.rcf';

    %Write ARD to filename:
    Filename = RCFfilename(1:end-4);

    %% Read in Data
%     fprintf('Read RCF File..\n')
%     clear oInputRCFHeader;
%     oRCF = cRCF;
%     oRCF.readHeaderFromFile(RCFfilename);
%     RCF = oRCF.readFromFile(RCFfilename, 1, oRCF.m_NSamples);
%     RefData = double(RCF.m_fvReferenceData);
%     SurvData = double(RCF.m_fvSurveillanceData);
%     fprintf('RCF Read Complete..\n')

    %% Test Data
    fprintf('Reading data..\n')
    RCFFilename = 'Single_PLP_data';
    load(RCFFilename);
    RefData = [zeros(1000,1); Values]; % Pad with zeros so indexing works on P1 detection
    SurvData = RefData; % Create a surv channel so that the demod-remod process runs without issue
    fprintf('Data read complete..\n')
    
    REF = 20*log10(fftshift(fft(RefData)));
    SUR = 20*log10(fftshift(fft(SurvData)));

    %% Perform DemodRemod to extract the pilot tones
    % Perform P1 Detection
    [P1Loc, P1foffset] = P1FastDetection(RefData,PlotP1);
    fprintf('P1 Location: %s\n', num2str(P1Loc))
    fprintf('Number of Valid Frames: %s\n\n', num2str(length(P1Loc)-1))

    % If data with more than 1 Frame is fed into the system, the data needs to
    % be spit otherwise all frames will be demodulated but only the last one
    % will be used as the other data is overwritten. The FrameExtraction code
    % deals with splitting of the frames - can be done using the code below

    RefData = RefData(P1Loc(1)-1000:P1Loc(2)+1000);
    SurvData = SurvData(P1Loc(1)-1000:P1Loc(2)+1000);
    P1Loc = [1000 (length(RefData)-2000)]; % Reset the P1 location

    % Perform Demod-Remod
    Outputfile = [OutfilePrefix Filename];
    Filename = [OutfilePrefix '_Pilot_' num2str(PilotSetting) '_Guard_' num2str(GuardSetting) '_Custom_' num2str(CustomPilot) '_' Filename];
    [RefData_demod, SurvData_demod, DVBT2] = DemodremodFast(RefData,SurvData,P1Loc,P1foffset,Outputfile,GuardSetting,CustomPilot,PilotSetting,JamPilotSetting,demodREMODwrite);
    
    DVBT2.StartCarrier = (DVBT2.NFFT-DVBT2.C_PS)/2+1;
    DVBT2.EndCarrier = DVBT2.NFFT - (DVBT2.NFFT-DVBT2.C_PS)/2;
    DVBT2.P1Length = 542 + 1024 + 482;  
    DVBT2.nSymbols = length(DVBT2.DataMap(:,1));
    DVBT2.Fs = 64/7; % Sampling frequency in MHz
    DVBT2.Fc = 706; % Centre frequency in MHz
    
    fprintf('Guard Length: %d\n', DVBT2.guard)
    fprintf('Number of Symbols: %d\n', DVBT2.nSymbols)
    
    %% Save workspace and then load it if needed - remove all the variables that arent required  
    clearvars -except DVBT2 proc C Filename RefData_demod SurvData_demod RCF oRCF write rangeDoppler plotFigures REF SUR P1Loc RefData SurvData RefData_demod_unchanged RefData_demod_normalised RefData_demod_zeroed RefData_demod_10dBboost DVBT2_allPilots DVBT2_CP DVBT2_SP DVBT2_allPilotsNormalised import
    
    fprintf('Saving workspace..\n')
    save('.\TestFrames\DVBT2_Data.mat');
    fprintf('Complete\n\n')
    
end

%% Load saved data
if import == 1
    fprintf('Loading workspace..\n')
      load('DVBT2_Data.mat');
    fprintf('Complete\n\n')
    
    % Set to overide the original one
    plotFigures = 0;
    DVBT2.DataPoints = 500;
    
    RefData_demod = RefData_demod_unchanged;
    SurvData_demod = RefData_demod_unchanged;
    DVBT2 = DVBT2_allPilots;
end

%% Plot Pilots
if plotFigures == 1
    close all;
    %% Determine the frequency bins
    samples = length(REF); % Determine the number of samples
    T = DVBT2.Fs/(samples-1); % Bin size
    bins = ((DVBT2.Fc-DVBT2.Fs/2):T:(DVBT2.Fc+DVBT2.Fs/2)).'; % Vector containing each bin in frequency steps

    % Plot spectrum
    fprintf('Plotting figures..\n\n')
    
    figure()
    subplot(2,1,1)
    plot(bins,abs(REF)-max(abs(REF)))
    xlim([(DVBT2.Fc-DVBT2.Fs/2) (DVBT2.Fc+DVBT2.Fs/2)])
    xlabel('Frequency [MHz]')
    ylabel('Normalised Power [dB]')
    title('Raw Reference Data')

    subplot(2,1,2)
    plot(bins,abs(SUR)-max(abs(SUR)))
    xlim([(DVBT2.Fc-DVBT2.Fs/2) (DVBT2.Fc+DVBT2.Fs/2)])
    xlabel('Frequency [MHz]')
    ylabel('Normalised Power [dB]')
    title('Raw Surveillance Data')

    % Demod Pilots - length(P1_c) + length(P1_a) + length(P1_b) + length(guard) + length(P2) + length(guard) + length(DATA) + length(guard) ...
    DataSymbols = DVBT2.nSymbols-1; % Select how many sumbols you want to look at (60 QAM symbols per Frame)

    for i = 1:DataSymbols
        symbols(:,i) = abs(fftshift(fft(RefData_demod((DVBT2.P1Length+DVBT2.guard+DVBT2.symbol+DVBT2.guard+(i-1)*(DVBT2.symbol)+(i-1)*(DVBT2.guard)) : (DVBT2.P1Length+DVBT2.guard+DVBT2.symbol+DVBT2.guard+(i-1)*(DVBT2.symbol)+(i-1)*(DVBT2.guard)+DVBT2.symbol-1)))));
    end
   
    DVBT2.DataPoints = 500; % Select a cut of x points in each symbol to plot

    PilotPattern(DVBT2.DataPoints, DataSymbols) = 0;
    for x = 1:DataSymbols
        PilotPattern(1:DVBT2.DataPoints, x) = symbols((15*1024 - DVBT2.DataPoints/2 + 1):(15*1024 + DVBT2.DataPoints/2), x);
    end

    % Plot Demod Pilots
    figure()
    imagesc((PilotPattern))
    title('Frequency Domain View of Part of Single DVB-T2 Frame (DEMOD)')
    xlabel('Time [OFDM Symbol]')
    ylabel('Frequency [Carrier Number]')
    colormap jet
    % colorbar 
    figure()
    surf((PilotPattern)) % Replace with symbols to plot full map
    title('Frequency Domain View of Part of Single DVB-T2 Frame (DEMOD)')
    xlabel('Time [OFDM Symbol]')
    ylabel('Frequency [Carrier Number]')
    % shading interp

    % Raw Pilots - P1Loc(1) + length(P1_a) + length(P1_b) + length(guard) + length(P2) + length(guard) + length(DATA) + length(guard) ...
    DataSymbols = DVBT2.nSymbols-1; % Select how many sumbols you want to look at (60 QAM symbols per Frame)
    for i = 1:DataSymbols
        Raw_symbols(:,i) = abs(fftshift(fft(RefData((P1Loc(1) + 1024 + 482 + DVBT2.guard + DVBT2.symbol + DVBT2.guard + (i-1)*(DVBT2.symbol) + (i-1)*(DVBT2.guard)) : (P1Loc(1) + 1024 + 482 + DVBT2.guard + DVBT2.symbol + DVBT2.guard + (i-1)*(DVBT2.symbol) + (i-1)*(DVBT2.guard) + DVBT2.symbol - 1)))));
    end 

    RawPilotPattern(DVBT2.DataPoints, DataSymbols) = 0;
    for x = 1:DataSymbols
        RawPilotPattern(1:DVBT2.DataPoints, x) = Raw_symbols((15*1024 - DVBT2.DataPoints/2 + 1):(15*1024 + DVBT2.DataPoints/2), x);
    end

    % Plot Raw Pilots
    figure()
    imagesc((RawPilotPattern))
    colormap jet
    title('Frequency Domain View of Part of Single DVB-T2 Frame (RAW)')
    xlabel('Time [OFDM Symbol]')
    ylabel('Frequency [Carrier Number]')
    % colorbar 
    figure()
    surf((RawPilotPattern)) % Replace with symbols to plot full map
    title('Frequency Domain View of Part of Single DVB-T2 Frame (RAW)')
    xlabel('Time [OFDM Symbol]')
    ylabel('Frequency [Carrier Number]')
    
    %% Plot QAM plot
    figure()
    FEC_Frame = 1; % Error correction frame selection
    plot(DVBT2.rawQAM(FEC_Frame).TIBlock,'.')
    title('Raw DVB-T2 QAM Map')
    
    figure()
    FEC_Frame = 1; % Error correction frame selection
    plot(DVBT2.demodQAM(FEC_Frame).TIBlock,'.','MarkerSize',12)
    title('Demod-Remod DVB-T2 QAM Map')

    %% Plot pilot maps
    figure() % 60x27841
    surf(abs((DVBT2.A_CP2/DVBT2.A_CP)*DVBT2.Continualpilotmap(1:30,1:500)))
    title('Reference Continual Pilot Map')
    xlabel('Time [OFDM Symbol]')
    ylabel('Frequency [Carrier Number]')
    
    figure() % 60x27841
    surf(abs(DVBT2.Scatteredpilotmap(1:end,1:200)))
    title('Reference Scattered Pilot Map')
    xlabel('Time [OFDM Symbol]')
    ylabel('Frequency [Carrier Number]')
    
    DataSymbols = DVBT2.nSymbols-1; % Select how many sumbols you want to look at (60 QAM symbols per Frame)
    for i = 1:DataSymbols
        demod_pilots(:,i) = abs(fftshift(fft(DVBT2.PilotMap((DVBT2.P1Length + DVBT2.guard + DVBT2.symbol + DVBT2.guard + (i-1)*(DVBT2.symbol) + (i-1)*(DVBT2.guard)) : (DVBT2.P1Length + DVBT2.guard + DVBT2.symbol + DVBT2.guard + (i-1)*(DVBT2.symbol) + (i-1)*(DVBT2.guard) + DVBT2.symbol-1)))));
    end 

    % Plot Complete Pilot Map
    figure()
    imagesc(demod_pilots)
    colormap jet
    title('Complete Remodulated Pilot Map')
    xlabel('Time [OFDM Symbol]')
    ylabel('Frequency [Carrier Number]')
    % colorbar 
    figure()
    surf(demod_pilots) % Replace with symbols to plot full map
    title('Complete Remodulated Pilot Map')
    xlabel('Time [OFDM Symbol]')
    ylabel('Frequency [Carrier Number]')
    
    PilotMap(DVBT2.DataPoints, DataSymbols) = 0;
    for x = 1:DataSymbols
        PilotMap(1:DVBT2.DataPoints, x) = demod_pilots((15*1024 - DVBT2.DataPoints/2 + 1):(15*1024 + DVBT2.DataPoints/2), x);
    end

    % Plot Complete Pilot Map
    figure()
    imagesc((PilotMap))
    colormap jet
    title('Part of Remodulated Pilot Map')
    xlabel('Time [OFDM Symbol]')
    ylabel('Frequency [Carrier Number]')
    % colorbar 
    figure()
    surf((PilotMap)) % Replace with symbols to plot full map
    title('Part of Remodulated Pilot Map')
    xlabel('Time [OFDM Symbol]')
    ylabel('Frequency [Carrier Number]')
         
    %% Plot Spectrum of Symbol
    figure()
    i=10;
    singleSymbol = RefData_demod((542 + 1024 + 482 + DVBT2.guard + DVBT2.symbol + DVBT2.guard + (i-1)*(DVBT2.symbol) + (i-1)*(DVBT2.guard) + 1) : (542 + 1024 + 482 + DVBT2.guard + DVBT2.symbol + DVBT2.guard + (i-1)*(DVBT2.symbol) + (i-1)*(DVBT2.guard) + DVBT2.symbol));
    plot((abs(fftshift(fft(singleSymbol)))))
    title('Single Symbol Spectrum after Demod')
    
    figure()
    pilotSymbol = DVBT2.PilotMap((542 + 1024 + 482 + DVBT2.guard + DVBT2.symbol + DVBT2.guard + (i-1)*(DVBT2.symbol) + (i-1)*(DVBT2.guard) + 1) : (542 + 1024 + 482 + DVBT2.guard + DVBT2.symbol + DVBT2.guard + (i-1)*(DVBT2.symbol) + (i-1)*(DVBT2.guard) + DVBT2.symbol));
    plot(abs(fftshift(fft(pilotSymbol))))
    title('Single Symbol Pilot Map for Jam')
    
    %% Extract the QAM symbols into an array
    ExtractedQAM = [];
    for i = 1:length(DVBT2.demodQAM)
        [rows,columns] = size(DVBT2.demodQAM(i).TIBlock);
        for n = 1:columns
            ExtractedQAM = [ExtractedQAM DVBT2.demodQAM(i).TIBlock(:,n).'];
        end
    end
    ExtractedQAM = ExtractedQAM.';
end

if rangeDoppler > 0
    %-----------------------------------------------------------------------------
    %for debugging purposes 
    proc.targets = 0;
    %-----------------------------------------------------------------------------

    % Work with only the reference data for testing purposes
    RefData = RefData_demod_unchanged;

    %% Insert a target signal
    if proc.targets == 1

        target(1).SNR = -40; % SNR of target in dB BEFORE processing
        target(1).delayRange = 40e3; % bistatic delay range in m
        target(1).fd = -35; % Doppler shift in Hz

        target(2).SNR = -35; % SNR of target in dB BEFORE processing
        target(2).delayRange = 25e3; % bistatic delay range in m
        target(2).fd = 20; % Doppler shift in Hz

        target(3).SNR = -30; % SNR of target in dB BEFORE processing
        target(3).delayRange = 80e3; % bistatic delay range in m
        target(3).fd = 140; % Doppler shift in Hz

        TxToRefRxDistance_m = 12600;
        % Use undemodulated ref data for targets
        SurvDataTarget = insertTarget(RefData, SurvData_demod, target, C, RCF, TxToRefRxDistance_m);
    else
        SurvDataTarget = SurvData_demod;
    end

    %-----------------------------------------------------------------------------
    %for debugging purposes 
    proc.jam = 0;

    % % for debugging purposes 
    % % Toggle range-Doppler processing off (0), XF (1), FX (2), InverseFilter (3), Batches (4)
    rangeDoppler = 3; 
    % % Use a window function for Inverse Filtering
    proc.WindowType = 2; % 0 = Top Hat, 1 = Blackman, 2 = Hamming, 3 = Hann 4 = Other
    % % Set cancellation (0) Off, (1) CGLS ,(2) ECA-CD
    proc.cancel = 0;
    % % Plot figures
    plotFigures = 0;
    % % Select a cut of x points in each symbol to plot
    DVBT2.DataPoints = 500;
    %-----------------------------------------------------------------------------

    %% Insert a jamming signal
    if proc.jam == 1

        % Create jamming parameters
        delayRangeStart = 30000;
        delayRangeShift = 0;

        fdStart = 35;
        fdShift = 0;

        for i = 1:1
            jam(i).delayRange = delayRangeStart + delayRangeShift*(i-1); % delay range in m
            jam(i).fd = fdStart + fdShift*(i-1); % Doppler shift in Hz

            % Set the start and end symbol to jam
            jam(i).SymbolStart = 1;
            jam(i).SymbolEnd = 60;
        end

        %----------------------------------------------------------------------------- 

        % Feed the jammer data
        SurvData = SurvDataTarget;

        TxToRefRxDistance_m = 12600;
        SurvDataJam = DVBT2_jammer( RefData_demod, SurvData, jam, DVBT2, C, RCF, TxToRefRxDistance_m, plotFigures ); 

        % Add noise
        SurvDataJam = randn(length(SurvData),1)+1i*randn(length(SurvData),1);
        % Set jammer power
        Psurv = rms(SurvData)^2;
        fprintf('Psurv: %s\n', num2str(Psurv))
        Pjam = rms(SurvDataJam)^2;
        fprintf('Pjam: %s\n', num2str(Pjam))

        JSR = 0; % Jammer to signal ratio in dB
        % Need to determine the jam level, this is done by taking the power
        % ratio of Psurv and Pjam and multiplying it by a JSR as set above. We
        % then need to bring it back to a voltage ratio as we are multiplying
        % it by the jammer signal.
        JamLevel = sqrt(10^(JSR/10).*(Psurv/Pjam));

        Pjam = rms(JamLevel*SurvDataJam)^2;
        fprintf('JamLevel: %s\n\n', num2str(JamLevel))

        % Add jammer to surv data
        SurvDataJam = SurvData + JamLevel.*SurvDataJam;

        JSR = 10*log10(Pjam/Psurv);
        fprintf('JSR: %s dB\n\n', num2str(JSR))

        if plotFigures == 1
           %%
           figure()
           Psurv_ft = 20*log10(abs(fftshift(fft(SurvData))));
           Pjam_ft = 20*log10(abs(fftshift(fft(SurvDataJam))));
           [up, lo] = envelope(Psurv_ft,1e5,'rms');
           plot(lo, 'linewidth', 2)
           hold on
           [up, lo] = envelope(Pjam_ft,1e5,'rms');       
           plot(lo, 'linewidth', 2)
           legend({'SurvData','Jammer'}, 'Location','southeast')
           ylabel('dB')
           grid on
        end

        Filename = ['Jammed_fd_' num2str(jam(1).fd) '_td_' num2str(jam(1).delayRange) '_' Filename]; 
    else
        SurvDataJam = SurvDataTarget;
    end
    %% Process ARD
    % Set the cancellation and ARD parameters
    proc.ARDMaxRange_m = 100000;
    proc.ARDMaxDoppler_Hz = 200;
    proc.cancellationMaxRange_m = 12650; %1000 bins
    proc.cancellationMaxDoppler_Hz = 4; % 3 bins
    proc.TxToRefRxDistance_m = 12600;
    proc.nSegments = 16;
    proc.nIterations = 30;

    proc.samples = max(size(SurvDataJam)); % Determine the number of samples
    proc.Window = blackmanWindow(proc.samples); % Create window function
    proc.Fs = RCF.m_Fs_Hz;
    proc.c = C;
    % Determine the number of CPIs in the data

    proc.alpha = 0;
    proc.initialAlpha = 0;

    % Determine the number of range and Doppler bins corresponding to the max
    % range and Doppler
    proc.nRangeBins = ceil((proc.ARDMaxRange_m - proc.TxToRefRxDistance_m) * RCF.getFs_Hz() / C);
    proc.nDopplerBins = floor(proc.ARDMaxDoppler_Hz / (RCF.getFs_Hz() / RCF.getNSamples())); % Number of bins of 1 side of the Doppler spectrum without DC bin

    if write.Jam == 1
        FrametoRCF(RefData_demod,SurvDataJam,RCF.m_Fc_Hz,RCF.m_Fs_Hz,RCF.m_Bw_Hz,Filename,RCF.m_strComment)
    end

    %% CGLS Cancellation
    if proc.cancel == 1
        RefData = RefData_demod_unchanged;
        tic
        fprintf('Performing CGLS cancellation\n')
        Filename = ['Cancelled_range_' num2str(proc.cancellationMaxRange_m) '_Doppler_' num2str(proc.cancellationMaxDoppler_Hz) '_' Filename];
        SurvData_cancel = CGLS_Cancellation_RefSurv(RefData, SurvDataJam, DVBT2.Fs*1e6, proc);
        if write.Cancel == 1
            FrametoRCF(RefData,SurvData_cancel,RCF.m_Fc_Hz,RCF.m_Fs_Hz,RCF.m_Bw_Hz,Filename,RCF.m_strComment) 
        end
        fprintf('\n')
        toc
    else
        % Add this so that you can run without the need to run the cancel algorithm
        SurvData_cancel = SurvDataJam;
    end

    %% range-Doppler Processing
    if rangeDoppler == 1 % XF Processor
        ARDMatrix = XF_proc(RefData_demod,SurvData_cancel,proc);
    end

    if rangeDoppler == 2 % FX Processor
        ARDMatrix = FX_proc(RefData_demod,SurvData_cancel,proc);
    end

    if rangeDoppler == 3 % Inverse Filter 
        ARDMatrix = InvFilter(RefData_demod,SurvData_cancel,proc,DVBT2);
    end

    if rangeDoppler == 4 % Batches
        proc.nBatches = 256;
        % Number of samples in each batch = (proc.samples / proc.nBatches) * proc.nSampBatches
        % Note that if this is bigger than the stride then the batches overlap. (It shouldn't ever be smaller)
        proc.nSampBatches = 1.1; % 1.1 is the smallest with 256

        ARDMatrix = Batches_proc(RefData_demod,SurvData_cancel,proc);
    end

    %% Determine the peak to noise ratio
    % Effectively using CFAR thresholding for this
    %% Plot ARDMatrix
    Pfa = 10*10^(-1.4);
    % This needs to be changed if we are doing range CFAR
    averageSignalLevel = 20*log10(rms(rms(ARDMatrix(100:end,1:end)))); % Ignore the direct signal peak

    ARDMatrixSize = size(ARDMatrix);
    N = ARDMatrixSize(1)*ARDMatrixSize(2); % Number of cells used to determine the signal level
    alpha = N*(Pfa^(-1/N) -1); % GO-CACFAR Multiplier
    Pn = 10^(averageSignalLevel/20); % Estimated noise power
    threshold = 20*log10(alpha*Pn);

    signalPeak = 20*log10(abs(max(max(ARDMatrix))));
    PSNR = signalPeak-threshold;

    fprintf('\nSignal Peak: %f [dB]\n', signalPeak)
    fprintf('\nNoise floor: %f [dB]\n', threshold)
    fprintf('\nPSNR: %f [dB]\n', PSNR)

    % Plot 2D 0-range cut
    % figure()
    % plot(20*log10(abs(ARDMatrix([1:end],ceil(length(ARDMatrix(1,:))/2+1))))-max(20*log10(abs(ARDMatrix([1:end],ceil(length(ARDMatrix(1,:))/2+1))))))
    % hold on
    % plot(ones(length(ARDMatrix(:,1)),1)*threshold-max(20*log10(abs(ARDMatrix([1:end],ceil(length(ARDMatrix(1,:))/2+1))))))
    % xlim([0 length(ARDMatrix(:,1))]) 
    % hold off
    % title('Zero Doppler Cut')
    % xlabel('Range [samples]')

    %% Plot figures without saving 
    dynamicRange = 120; % Dynamic range of plots in dB

    figure()
    imagesc(20*log10(abs(ARDMatrix.')),[(max(max(20*log10(abs(ARDMatrix))))- dynamicRange) max(max(20*log10(abs(ARDMatrix))))])
    colormap jet
    colorbar

    figure()
    h = surf(20*log10(abs(ARDMatrix.'))-max(max(20*log10(abs(ARDMatrix.')))));
    set(h, 'edgecolor','flat')
    axis([0 length(ARDMatrix(:,1)) 0 length(ARDMatrix(1,:)) -dynamicRange 0])
    caxis([-dynamicRange 0])
    view([135 35])
    colormap parula
    colorbar

    %% Plot Resultant ARD map
    if rangeDoppler == 1 || rangeDoppler == 2 || rangeDoppler == 3 || rangeDoppler == 4

        colourMap = 3;
        dynamicRange = 120; % Dynamic range of plots in dB
        look.az = 135;
        look.el = 35;

        saveARD( ARDMatrix, Filename, oRCF, proc, colourMap, dynamicRange, look )

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
    end
end