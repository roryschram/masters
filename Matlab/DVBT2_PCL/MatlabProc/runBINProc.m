clear all; close all; clc;
addpath('.\ARDMakers')
addpath('.\Cancellation')
addpath('.\Classes')
addpath('.\makeRCF')
addpath('.\Processing')
addpath('.\Plot')
addpath('.\TestFrames')
addpath('.\..\FrameExtraction\ettusFunctions')
addpath('.\..\demod-remod\Demod')
addpath('.\..\demod-remod\Remod')

% Data file location
filepath = 'G:\Radar_Recordings\DVBT_FM_PCL_FieldTrials\Ettus_DVBT2_Recordings\';
filename = 'TEST_19.bin';

% Fixed environmental variables
C = 299792458; %speed of the light (m/s)
Fc = 706e6;
Fs = (64e6)/7;
Bw = 7.768e6;

%% -----------------------------------------------------------------------------%
% USER INPUT
%-------------------------------------------------------------------------------%

% Toggle the cancellation off (0), CGLS (1), ECA-CD (2)
proc.cancel = 2;
% Toggle writing cancelled RCF on (1) or off (0) - Only works with CGLS
write.Cancel = 0;
% Toggle inserting targets on (1) or off (0)
proc.targets = 1;
% Toggle jamming on (1) or off (0)
proc.jam = 1;
% Toggle writing RCF on (1) or off (0)
write.Jam = 0;
% Toggle range-Doppler processing off (0), XF (1), FX (2), InverseFilter (3), Batches (4)
rangeDoppler = 3; 
% Togle figure plots on (1) or off (0)
plotFigures = 0;

% Demod-Remod Parameters
PlotP1 = 0;
demodREMODwrite = 0; % Set to 1 to write Demod-Remod frame to file
OutfilePrefix = 'DemodRemod';
GuardSetting = 1; % 1: Unchanged / 0:Blanking
PilotSetting = 2; % 0: Blanking / 1: Equalisation (4/7) / 2: Unchanged / 3: Custom
CustomPilot = 0; % Pilot amplitude if custom is selected above

% Pilot parameters for jamming each one manipulated individually
% Can be set to any specific value
JamPilotSetting.Cp = 1; % 0 for blanking, 1 for unchanged, (4/9)^2 for equalisation
JamPilotSetting.Sp = 1; % (3/7)^2 for equalisation
JamPilotSetting.P2 = 1; % (3/7)^2 for equalisation
JamPilotSetting.Guard = 1; % Set to 0 to blank, 1 to leave unchanged

% File Start
Start = 0; %NoBatches; % 0 = start of file
% File End
End = 1; %NoBatches; % NoBatches is EoF

% Write RAW FRAME to RCF
writeRAW = 1; % Set to 1 to write RAW FRAME to RCF
writeBIN = 0; % Set to 1 to write RAW FRAME to BIN
comment = 'Single DVB-T2 Frame from ETTUS data'; % Write raw FRAME to RCF

% Cancellation and ARD variables
proc.ARDMaxRange_m = 300000;
proc.ARDMaxDoppler_Hz = 300; % This one doesnt work with the inverse filtering

proc.cancellationMaxRange_m = 12650; %1000 bins
proc.cancellationMaxDoppler_Hz = 4; % 3 bins
proc.TxToRefRxDistance_m = 12600;
proc.nSegments = 16;
proc.nIterations = 30;

%-------------------------------------------------------------------------------%

List = dir([filepath filename]);
FileLength = List.bytes;
FrameLength = 1024*32*2*2; % Samples/second * bits * frame length in seconds
fprintf('Number of possible batches: %s\n\n', num2str(ceil(FileLength/FrameLength)))
NoBatches = ceil(FileLength/FrameLength);

% Loop through entire BIN file
for Frame = Start:End
    clear RefData SurvData
    fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~\n')
    fprintf('Batch Number: %s\n', num2str(Frame))
    fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~\n\n')
    [RefData, SurvData] = ettusReadBin( filepath, filename, Frame, FrameLength );

    % We only ever need to resample once when reading in the ORIGINAL data     
    [RefData, SurvData] = ettusResample( RefData, SurvData );

    % Perform P1 Detection
    tic
    [P1Loc, ffreq] = P1FastDetection(RefData, PlotP1);
    fprintf('P1 Location: %s\n', num2str(P1Loc))
    fprintf('Number of Valid Frames: %s\n\n', num2str(length(P1Loc)-1))
    toc

    try
        for i=1:length(P1Loc)-1
            % Check that the frame is valid before continuing    
            if (P1Loc(i+1) - P1Loc(i)> 2e6)
                %% If there are multiple frames, we can remove them and write to file,
                RefFrame = RefData(P1Loc(i)-2^(16):P1Loc(i+1)+2^(16));
                SurvFrame = SurvData(P1Loc(i)-2^(16):P1Loc(i+1)+2^(16));

                %% Write Frame to RCF/BIN
                if writeRAW == 1
                    fprintf('Writing Frame: %s of %s\n', num2str(i), num2str(length(P1Loc)-1))
                    name = ['Batch_' num2str(Frame) '_Frame_' num2str(i) 'of' num2str(length(P1Loc)-1) '_' filename(1:end-4) '.rcf'];
                    FrametoRCF(RefFrame,SurvFrame,Fc,Fs,Bw,name,comment);

                    % This will write the same file to a BIN file (FAST) - can be
                    % read using the ettusReadBin function
                    if writeBIN == 1
                        ettusWriteBin( [name(1:end-4) '.bin'], RefData, SurvData );
                    end
                end

                Filename = filename(1:end-4);

                %% Determine the frequency bins
                REF = 20*log10(fftshift(fft(RefFrame)));
				SUR = 20*log10(fftshift(fft(SurvFrame)));
                samples = max(size(RefFrame)); % Determine the number of samples
                T = Fs/(samples-1); % Bin size
                bins = (((Fc/1e6)-(Fs/1e6)/2):T:((Fc/1e6)+(Fs/1e6)/2))'; % Vector containing each bin in frequency steps

                % Perform Demod-Remod
                %% This index is used for the multiple frames - This demods properly,	
                index = [2^(16)+1 2^(16)+1+(P1Loc(i+1)-P1Loc(i))]; 
                Outputfile = [OutfilePrefix '_Batch_' num2str(Frame) '_Frame_' num2str(i) 'of' num2str(length(P1Loc)-1) '_' filename(1:end-4)];

                Filename = [OutfilePrefix '_Pilot_' num2str(PilotSetting) '_Guard_' num2str(GuardSetting) '_Custom_' num2str(CustomPilot) '_' Filename];
                [RefData_demod, SurvData_demod, DVBT2] = DemodremodFast(RefFrame,SurvFrame,index,ffreq,Outputfile,GuardSetting,CustomPilot,PilotSetting,JamPilotSetting,demodREMODwrite);

                DVBT2.StartCarrier = 2465;
                DVBT2.EndCarrier = 30305;
                DVBT2.P1Length = 542 + 1024 + 482;  
                DVBT2.nSymbols = length(DVBT2.DataMap(:,1));
				DVBT2.Fs = Fs/(1e6); % Sampling frequency in MHz
                DVBT2.Fc = Fc/(1e6); % Centre frequency in MHz
                
                DVBT2.DataPoints = 500; % Set the amount of data to cut from the matrix when plotting
                
                % Create RCF class for processing and saving purposes
                % Legacy code - too lazy to change
                RCF.getNSamples = length(SurvData_demod);
                RCF.getFs_Hz = Fs;
                RCF.m_Fs_Hz = Fs;
                RCF.getTimeStamp_us = 0;
                RCF.getFc_Hz = Fc;
                RCF.m_Fc_Hz = Fc;                
                RCF.getBw_Hz = Bw;
                oRCF = RCF;
                
                %% Plot Pilots
                if plotFigures == 1
                %     close all;

                    % Plot spectrum
                    fprintf('Plotting figures\n\n')

                    figure()
                    subplot(2,1,1)
                    plot(bins,abs(REF)-max(abs(REF)))
                    xlim([(fc-fs/2) (fc+fs/2)])
                    xlabel('Frequency [MHz]')
                    ylabel('Normalised Power [dB]')
                    title('Raw Reference Data')

                    subplot(2,1,2)
                    plot(bins,abs(SUR)-max(abs(SUR)))
                    xlim([(fc-fs/2) (fc+fs/2)])
                    xlabel('Frequency [MHz]')
                    ylabel('Normalised Power [dB]')
                    title('Raw Surveillance Data')

                    % Demod Pilots - length(P1_c) + length(P1_a) + length(P1_b) + length(guard) + length(P2) + length(guard) + length(DATA) + length(guard) ...
                    DataSymbols = DVBT2.nSymbols-1; % Select how many sumbols you want to look at (60 QAM symbols per Frame)

                    for i = 1:DataSymbols
                        symbols(:,i) = abs(fftshift(fft(RefData_demod((DVBT2.P1Length+DVBT2.guard+DVBT2.symbol+DVBT2.guard+(i-1)*(DVBT2.symbol)+(i-1)*(DVBT2.guard)) : (DVBT2.P1Length+DVBT2.guard+DVBT2.symbol+DVBT2.guard+(i-1)*(DVBT2.symbol)+(i-1)*(DVBT2.guard)+DVBT2.symbol-1)))));
                    end

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

                    PilotMap(DVBT2.DataPoints, DataSymbols) = 0;
                    for x = 1:DataSymbols
                        PilotMap(1:DVBT2.DataPoints, x) = demod_pilots((15*1024 - DVBT2.DataPoints/2 + 1):(15*1024 + DVBT2.DataPoints/2), x);
                    end

                    % Plot Complete Pilot Map
                    figure()
                    imagesc((PilotMap))
                    colormap jet
                    title('Complete Remodulated Pilot Map')
                    xlabel('Time [OFDM Symbol]')
                    ylabel('Frequency [Carrier Number]')
                    % colorbar 
                    figure()
                    surf((PilotMap)) % Replace with symbols to plot full map
                    title('Complete Remodulated Pilot Map')
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
                    plot((abs(fftshift(fft(pilotSymbol)))))
                    title('Single Symbol Pilot Map for Jam')
                end
                
                %% Insert a target signal
                if proc.targets == 1

                    target(1).SNR = -30; % SNR of target in dB BEFORE processing
                    target(1).delayRange = 100e3; % bistatic delay range in m
                    target(1).fd = 30; % Doppler shift in Hz

                    target(2).SNR = -40; % SNR of target in dB BEFORE processing
                    target(2).delayRange = 300e3; % bistatic delay range in m
                    target(2).fd = 70; % Doppler shift in Hz

                    target(3).SNR = -35; % SNR of target in dB BEFORE processing
                    target(3).delayRange = 200e3; % bistatic delay range in m
                    target(3).fd = -35; % Doppler shift in Hz
                    
                    TxToRefRxDistance_m = 12600;
                    SurvDataTarget = insertTarget(RefData_demod, SurvData_demod, target, C, RCF, TxToRefRxDistance_m);
                else
                    SurvDataTarget = SurvData_demod;
                end

                %% Insert a jamming signal
                if proc.jam == 1

                    %-----------------------------------------------------------------------------
                    %for debugging purposes 
                    % Toggle range-Doppler processing off (0), XF (1), FX (2), InverseFilter (3)
                    rangeDoppler = 3; 
                    % Set cancellation (0) Off, (1) CGLS ,(2) ECA-CD
                    proc.cancel = 2;
                    % Plot figures
                    plotFigures = 0;
                    %-----------------------------------------------------------------------------

                    % Create jamming parameters
                    jam(1).SNR = -1000; % SNR of jamming singal in dB BEFORE processing
                    jam(1).delayRange = 0e3; % delay range in m
                    jam(1).fd = 0; % Doppler shift in Hz

                    % Set the start and end symbol to jam
                    jam(1).SymbolStart = 1;
                    jam(1).SymbolEnd = 2;

                    % Feed the jammer data
                    SurvData = SurvDataTarget;
                    
                    TxToRefRxDistance_m = 12600;
                    SurvDataJam = DVBT2_jammer( RefData_demod, SurvData, jam, DVBT2, C, RCF, TxToRefRxDistance_m, plotFigures ); 

                    Filename = ['Jammed_fd_' num2str(jam(1).fd) '_td_' num2str(jam(1).delayRange) '_' Filename]; 
                else
                    SurvDataJam = SurvDataTarget;
                end

                %% Process ARD
                % Determine the number of range and Doppler bins corresponding to the max
                % range and Doppler
                proc.nRangeBins = ceil((proc.ARDMaxRange_m - proc.TxToRefRxDistance_m) * RCF.getFs_Hz() / C);
                proc.nDopplerBins = floor(proc.ARDMaxDoppler_Hz / (RCF.getFs_Hz() / RCF.getNSamples())); % Number of bins of 1 side of the Doppler spectrum without DC bin

                if write.Jam == 1
                    FrametoRCF(RefData_demod,SurvDataJam,RCF.m_Fc_Hz,RCF.m_Fs_Hz,RCF.m_Bw_Hz,Filename,RCF.m_strComment)
                end

                % Add this so that you can run without the need to run the cancel algorithm
                SurvData_cancel = SurvDataJam;
                
                proc.samples = max(size(SurvDataJam)); % Determine the number of samples
                proc.Window = blackmanWindow(proc.samples); % Create window function
                proc.Fs = RCF.m_Fs_Hz;
                proc.c = C;
                
                proc.initialAlpha = 0;
                proc.alpha = 0;
                
                %% CGLS Cancellation
                if proc.cancel == 1
                    Filename = ['Cancelled_range_' num2str(proc.cancellationMaxRange_m) '_Doppler_' num2str(proc.cancellationMaxDoppler_Hz) '_' Filename];
                    SurvData_cancel = CGLS_Cancellation_RefSurv(RefData_demod, SurvDataJam, DVBT2.Fs*1e6, proc);
                    if write.Cancel == 1
                        FrametoRCF(RefData_demod,SurvData_cancel,RCF.m_Fc_Hz,RCF.m_Fs_Hz,RCF.m_Bw_Hz,Filename,RCF.m_strComment) 
                    end
                    fprintf('\n')
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
                    proc.nBatches = 2048;
                    % Number of samples in each batch = (proc.samples / proc.nBatches) * proc.nSampBatches
                    % Note that if this is bigger than the stride then the batches overlap. (It shouldn't ever be smaller)
                    proc.nSampBatches = 10;
                    ARDMatrix = Batches_proc(RefData_demod,SurvData_cancel,proc);
                end

                %% Plot Resultant ARD map
                if rangeDoppler == 1 || rangeDoppler == 2 || rangeDoppler == 3 || rangeDoppler == 4
    
                    colourMap = 1;
                    dynamicRange = 100; % Dynamic range of plots in dB
                    
                    saveARD( ARDMatrix, Filename, oRCF, proc, colourMap, dynamicRange )
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
        end
    catch
            fprintf('\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n')        
            fprintf('No valid P1 found, moving to next frame\n')
            fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n')
    end
end