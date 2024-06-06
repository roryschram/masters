clear all; close all; clc;
addpath('./ARDMakers')
addpath('./Cancellation')
addpath('./Classes')
addpath('./makeRCF')
addpath('./Processing')
%addpath('../TestFrames')
addpath('../FrameExtraction/ettusFunctions')
addpath('../DemodRemod/Demod')
addpath('../DemodRemod/Remod')

% Data file location
filepath = '/Users/roryschram/Documents/Work/masters/Matlab/dataImport/';
filename = 'data.dat';

% Fixed environmental variables
C = 299792458; %speed of the light (m/s)
Fc = 610e6;
Fs = (64e6)/7;
Bw = 7.768e6;

%% -----------------------------------------------------------------------------%
% USER INPUT
%-------------------------------------------------------------------------------%

% Toggle the cancellation off (0), CGLS (1), ECA-CD (2)
proc.cancel = 2;
% Toggle range-Doppler processing off (0), XF (1), FX (2), InverseFilter (3), Batches (4)
rangeDoppler = 3; 

% Demod-Remod Parameters
PlotP1 = 0;
demodREMODwrite = 0; % Set to 1 to write Demod-Remod frame to file
OutfilePrefix = 'DemodRemod';
GuardSetting = 1; % 1: Unchanged / 0:Blanking
PilotSetting = 2; % 0: Blanking / 1: Equalisation (4/7) / 2: Unchanged / 3: Custom
CustomPilot = 0; % Pilot amplitude if custom is selected above

% Write RAW FRAME to RCF
writeRAW = 0; % Set to 1 to write RAW FRAME to RCF
writeBIN = 0; % Set to 1 to write RAW FRAME to BIN
comment = 'Single DVB-T2 Frame from ETTUS data'; % Write raw FRAME to RCF

%% Process ARD
proc.ARDMaxRange_m = 300000;
proc.ARDMaxDoppler_Hz = 300; % This one doesnt work with the inverse filtering

proc.alpha = 0;
proc.cancellationMaxRange_m = 12650; %1000 bins
proc.cancellationMaxDoppler_Hz = 4; % 3 bins
proc.TxToRefRxDistance_m = 12600;
proc.nSegments = 16;
proc.nIterations = 30;
proc.initialAlpha = 0;

List = dir([filepath filename]);
FileLength = List.bytes;
FrameLength = FileLength/1000; % Samples/second * bits * frame length in seconds
fprintf('Number of possible batches: %s/n/n', num2str(ceil(FileLength/FrameLength)))

NoBatches = ceil(FileLength/FrameLength);
% File Start
Start = 0; %NoBatches; % 0 = start of file
% File End
End = NoBatches; %NoBatches; % NoBatches is EoF

%-------------------------------------------------------------------------------%
% Include because I dont feel like rewriting more code
%-------------------------------------------------------------------------------%
JamPilotSetting.Cp = 1; % 0 for blanking, 1 for unchanged, (4/9)^2 for equalisation
JamPilotSetting.Sp = 1; % (3/7)^2 for equalisation
JamPilotSetting.P2 = 1; % (3/7)^2 for equalisation
JamPilotSetting.Guard = 1; % Set to 0 to blank, 1 to leave unchanged

% Loop through entire BIN file
for Frame = Start:End
	clear RefData SurvData
	fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~/n')
	fprintf('Batch Number: %s/n', num2str(Frame))
	fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~/n/n')
	[RefData, SurvData] = ettusReadBin( filepath, filename, Frame, FrameLength );

	% We only ever need to resample once when reading in the ORIGINAL data     
	[RefData, SurvData] = ettusResample( RefData, SurvData );

	% Perform P1 Detection
	tic
	[P1Loc, ffreq] = P1FastDetection(RefData, PlotP1);
	fprintf('P1 Location: %s/n', num2str(P1Loc))
	fprintf('Number of Valid Frames: %s/n/n', num2str(length(P1Loc)-1))
	toc
 
% 	try
		for i=1:length(P1Loc)-1
			% Check that the frame is valid before continuing    
			if (P1Loc(i+1) - P1Loc(i)> 2e6)
				%% If there are multiple frames, we can remove them and write to file,
				RefFrame = RefData(P1Loc(i)-2^(16):P1Loc(i+1)+2^(16));
				SurvFrame = SurvData(P1Loc(i)-2^(16):P1Loc(i+1)+2^(16));              

				%% Write Frame to RCF/BIN
				if writeRAW == 1
					fprintf('Writing Frame: %s of %s/n', num2str(i), num2str(length(P1Loc)-1))
					name = ['Batch_' num2str(Frame) '_Frame_' num2str(i) 'of' num2str(length(P1Loc)-1) '_' filename(1:end-4) '.rcf'];
					FrametoRCF(RefFrame,SurvFrame,Fc,Fs,Bw,name,comment);

					% This will write the same file to a BIN file (FAST) - can be
					% read using the ettusReadBin function
					if writeBIN == 1
						ettusWriteBin( [name(1:end-4) '.bin'], RefData, SurvData );
					end
				end

				Filename = filename(1:end-4);

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
				DVBT2.Fs = 64/7; % Sampling frequency in MHz
                DVBT2.Fc = 706; % Centre frequency in MHz

% 				% remove all the variables that arent required
% 				clearvars -except DVBT2 proc C Filename RefData_demod SurvData_demod RCF oRCF write rangeDoppler plotFigures GuardSetting PilotSetting CustomPilot JamPilotSetting import P1Loc
            
                proc.samples = max(size(SurvData_demod)); % Determine the number of samples
                proc.Window = blackmanWindow(proc.samples); % Create window function
                proc.Fs = Fs;
                proc.c = C;
                
				% Create RCF class for processing and saving purposes
                % Legacy code - too lazy to change
                RCF.getNSamples = proc.samples;
                RCF.getFs_Hz = Fs;
                RCF.getTimeStamp_us = 0;
                RCF.getFc_Hz = Fc;
                RCF.getBw_Hz = Bw;
                oRCF = RCF;

                % Determine the number of range and Doppler bins corresponding to the max
                % range and Doppler
                proc.nRangeBins = ceil((proc.ARDMaxRange_m - proc.TxToRefRxDistance_m) * RCF.getFs_Hz() / C);
                proc.nDopplerBins = floor(proc.ARDMaxDoppler_Hz / (RCF.getFs_Hz() / RCF.getNSamples())); % Number of bins of 1 side of the Doppler spectrum without DC bin

                %% CGLS Cancellation
                if proc.cancel == 1
                    tic
                    fprintf('Performing CGLS cancellation/n')
                    Filename = ['Cancelled_range_' num2str(proc.cancellationMaxRange_m) '_Doppler_' num2str(proc.cancellationMaxDoppler_Hz) '_' Filename];
                    SurvData_cancel = CGLS_Cancellation_RefSurv(RefData_demod, SurvData_demod, DVBT2.Fs*1e6, proc);
                    fprintf('/n')
                    toc
                else
                    SurvData_cancel = SurvData_demod;
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

                    % Square law detector - note that the cARD class assumes that the
                    % ARDMatrix is given as a power and is therefore 10log10() when
                    % plotting. We need to make it a power as done below.
                    ARDMatrix = ARDMatrix.^2;
                    
                    %% Write ARD to File
                    Filename = [Filename '.ard'];

                    % Put ARD into correct folder
                    if (exist('./OutputARD'))
                        Filename = ['./OutputARD/' Filename];
                    else
                        mkdir './OutputARD'
                        Filename = ['./OutputARD/' Filename];
                    end

                    oARD = cARD;
                    oARD.setDataMatrix(transpose(ARDMatrix));
                    oARD.setRangeResolution_m(C / oRCF.getFs_Hz());
                    oARD.setDopplerResolution_Hz(oRCF.getFs_Hz() / oRCF.getNSamples());
                    oARD.setTimeStamp_us(oRCF.getTimeStamp_us());
                    oARD.setFc_Hz(oRCF.getFc_Hz());
                    oARD.setFs_Hz(oRCF.getFs_Hz());
                    oARD.setBw_Hz(oRCF.getBw_Hz());
                    oARD.setTxRxDistance_m(proc.TxToRefRxDistance_m);
                    oARD.setFilename(oARD.timeStampToString());
                    fprintf('/n')
                    oARD.writeToFile(Filename);
                    fprintf('ARD write complete/n/n');

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
                    colourMap = 1;

                    % Plot 2D function
                    figure();
                    % Can use (km or m) (m/s or Hz)
                    oARD.plot2D('m','Hz',0,-100);

                    % Plot 3D function
                    figure();
                    % x units, y units, z units, colormap
                    oARD.plot3D('km','Hz',0,-70,colourMap);
                end

            %   catch
            % 		fprintf('/n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/n')        
            % 		fprintf('No valid P1 found, moving to next frame/n')
            % 		fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/n/n')
            % 	end
            end
        end
end