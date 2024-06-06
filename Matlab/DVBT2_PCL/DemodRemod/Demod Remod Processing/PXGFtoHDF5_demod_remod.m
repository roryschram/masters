% Demod Remod Batch Script for HDF5 files (Works for pilot equalization and guard unchanged)
% TODO: read directory of HDF5 files and process a batch of hdf5 files
clear all;fclose all;
addpath('..\Demod') % Demod Folder location
addpath('..\Remod') % Remod Folder location

%% INPUT PARAMETERS
filepath = 'C:\Users\Motlatsi\Desktop\DVBT2 Signal Reconstruction - Home\recording\test20.h5';
Outputfile = []; % if empty, name is auto generated
PilotSettings = 1; %Pilot blanking 0/ equalisation 1/ unchanged 2/ custom 3
GuardSettings = 1; %guard interval blanking 0 or unchanged 1
CustomPilot = 3; % Custom Pilot amplitude
AllGSNC = 0; %  Toggle for all GSNC chunks or single chunk
GSNC_ChunkNo = '/GSNC_data2'; %(Use hdf5info for info on all GSNC chunks ) IGNORED IF AllGSNC==1
%%

for Pilotloop = 1:length(PilotSettings) 
    for Guardloop = 1:length(GuardSettings)

        PilotSetting = PilotSettings(Pilotloop);
        GuardSetting = GuardSettings(Guardloop);
        
        switch PilotSetting
            case 0
                Pilotlvl = 'BlankPilot';
            case 1
                Pilotlvl = 'EQPilot';
            case 2
                Pilotlvl = 'UnchangedPilot';
            case 3
                Pilotlvl = 'CustomPilot';
            otherwise
                fprintf('Signal Reconstruction settings - Invalid Pilot setting. Pilots are unchanged \r\n')
                PilotSetting = 2;
                Pilotlvl = 'UnchangedPilot';
        end

        switch GuardSetting
            case 0
                Guardlvl = 'Guard0';
            case 1
                Guardlvl = 'Guard1';
            otherwise
                GuardSetting = 1;
                Guardlvl = 'Guard1';
        end
        %% LOAD DATA FROM HDF5
        % Data path ------------------------
        % a. Extract all info (Use hdf5info for info on all GSNC chunks )
        if ~AllGSNC
            Chunk_number = 1;
            GSNC_Name = {GSNC_ChunkNo};
        else
            % OR Extract all GSNC Chunks found in in file (COMMENT  OUT IF NOT IN USE)
            Chunk_info = hdf5info(filepath);
            matches = regexp({Chunk_info.GroupHierarchy.Datasets.Name},'/GSNC');
            Chunk_id = ~cellfun('isempty',matches);
            Chunk_id = find(Chunk_id);
            Chunk_number = length(Chunk_id);
            GSNC_Name = extractfield(Chunk_info.GroupHierarchy.Datasets,'Name');
            GSNC_Name = GSNC_Name(Chunk_id);
        end
        for i1 = 1:Chunk_number
        %% OUTPUT FILE NAME GENERATION
            if isempty(Outputfile)||(i1>1)||(Pilotloop>1)||(Guardloop>1)
                [~,name,ext] = fileparts(filepath);
                ext = ext(2:end);
                GSNC_Number = GSNC_Name{i1};
                GSNC_Number = GSNC_Number(2:end);
                Outputfile = sprintf('%s_%s_%s_%s_%s',name,ext,GSNC_Number,Pilotlvl,Guardlvl);
                fprintf('Auto generated filename in ..\\OutputRCF: %s.rcf \n',Outputfile);
            end
        %%
            if AllGSNC
                GSNC_ChunkNo = GSNC_Name(i1);
                GSNC_ChunkNo = GSNC_ChunkNo(2:end);
                H5Data = h5read(filepath,GSNC_ChunkNo);
            else 
                H5Data = h5read(filepath,GSNC_ChunkNo);
            end

            CPI_ref = H5Data.real(:,1)-1i*H5Data.imag(:,1);
            CPI_ref = double(CPI_ref);
            CPI_ref = resample(CPI_ref,5,7); % Resampled Reference

            CPI_sur = H5Data.real(:,2)-1i*H5Data.imag(:,2); % Conjugated due Comrad error
            CPI_sur = double(CPI_sur);
            CPI_sur = resample(CPI_sur,5,7); %        Resampled Surveillance

            clear H5Data
            Demodremod(CPI_ref,CPI_sur,Outputfile,GuardSetting,CustomPilot,PilotSetting);
        end
    end
end
fclose all;
%% Demod Remod