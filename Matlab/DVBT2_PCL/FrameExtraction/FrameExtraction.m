clear all; close all; clc;
%% Read from ETTUS BIN file
addpath('..\demod-remod\Demod')
addpath('..\demod-remod\Remod')
addpath('.\ettusFunctions')

% Data file location
filepath = 'D:\RadarData\Bin\';
filename = 'ETTUS_TEST_19.bin';

% filepath = '.\OutputBIN\';
% filename = 'Batch_110_Frame_1of1_ETTUS_TEST_19.bin';

%% Set environment variables
Fc = 706e6;
Fs = (64e6)/7;
Bw = 7.768e6;

List = dir([filepath filename]);
FileLength = List.bytes;
FrameLength = FileLength/100; % Samples/second * bits * frame length in seconds
fprintf('Number of possible batches: %s\n\n', num2str(ceil(FileLength/FrameLength)))

%% -----------------------------------------------------------------------------%
% USER INPUT
%-------------------------------------------------------------------------------%

NoBatches = ceil(FileLength/FrameLength);
% File Start
Start = ceil(NoBatches/2)+31; %NoBatches; % 0 = start of file
% File End
End =ceil(NoBatches/2)+31; %NoBatches; % NoBatches is EoF

% Plot P1 for debugging
PlotP1 = 0; % Set to 1 to plot P1 detections (Debugging)

% Write RAW FRAME to RCF
writeRAW = 0; % Set to 1 to write RAW FRAME to RCF
writeBIN = 0; % Set to 1 to write RAW FRAME to BIN
comment = 'Single DVB-T2 Frame from ETTUS data'; % Write raw FRAME to RCF

% Demod-Remod Parameters
demodREMOD = 1; % Set to 1 to perform Demod-Remod
demodREMODwrite = 1; % Set to 1 to write Demod-Remod frame to file
OutfilePrefix = 'DemodRemod';
GuardSetting = 1; % 1: Unchanged / 0:Blanking
PilotSetting = 1; % 0: Blanking / 1: Equalisation (4/7) / 2: Unchanged / 3: Custom
CustomPilot = 0; % Pilot amplitude if custom is selected above

%-------------------------------------------------------------------------------%

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
        for i=15:15%length(P1Loc)-1
            % Check that the frame is valid before continuing    
            if (P1Loc(i+1) - P1Loc(i)> 2e6)
                %% If there are multiple frames, we can remove them and write to file,
                RefFrame = RefData(P1Loc(i)-2^(16):P1Loc(i+1)+2^(16));
                SurvFrame = SurvData(P1Loc(i)-2^(16):P1Loc(i+1)+2^(16));
                
                subplot(211)
                plot(10*log10(abs(fftshift(fft(RefFrame)))))
                subplot(212)
                plot(10*log10(abs(fftshift(fft(SurvFrame)))))                

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

                %% Perform Demod-Remod
                if demodREMOD == 1
                    %% This index is used for the multiple frames - This demods properly,
                    index = [2^(16)+1 2^(16)+1+(P1Loc(i+1)-P1Loc(i))]; 
                    Outputfile = [OutfilePrefix '_Batch_' num2str(Frame) '_Frame_' num2str(i) 'of' num2str(length(P1Loc)-1) '_' filename(1:end-4)];
                    [RefDataDemodRemod, SurvDataDemodRemod] = DemodremodFast_original(RefFrame,SurvFrame,index,ffreq,Outputfile,GuardSetting,CustomPilot,PilotSetting,demodREMODwrite);
                end
            end
        end
    catch
            fprintf('\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n')        
            fprintf('No valid P1 found, moving to next frame\n')
            fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n')
    end
end