clear all;
[I_data, Q_data] = readIQData('data.dat');
[I_data_normalized, Q_data_normalized] = normalizeToRange(I_data, Q_data);
complexData = I_data_normalized + 1i*Q_data_normalized;
complexDataNonNormalized = I_data + 1i*Q_data;

 function [I_data, Q_data] = readIQData(filename)
    % Open the file
    fileID = fopen(filename, 'rb');
    
    % Check if the file opened successfully
    if fileID == -1
        error('Error opening the file.');
    end
    
    % Initialize empty arrays to hold I and Q data
    I_data = [];
    Q_data = [];
    
    % Read the file until the end
    while ~feof(fileID)
        % Read one 32-bit I data sample
        I_sample = fread(fileID, 1, 'double');
        
        % Check if the read was successful
        if isempty(I_sample)
            break;
        end
        
        % Read one 32-bit Q data sample
        Q_sample = fread(fileID, 1, 'double');
        
        % Check if the read was successful
        if isempty(Q_sample)
            break;
        end
        
        % Append the read samples to the respective arrays
        I_data = [I_data; I_sample];
        Q_data = [Q_data; Q_sample];
    end
    
    % Close the file
    fclose(fileID);
 end


 function [I_data_normalized, Q_data_normalized] = normalizeToRange(I_data, Q_data)
    % Normalize I_data to range [-1, 1]
    I_min = min(I_data);
    I_max = max(I_data);
    I_data_normalized = 2 * (I_data - I_min) / (I_max - I_min) - 1;

    % Normalize Q_data to range [-1, 1]
    Q_min = min(Q_data);
    Q_max = max(Q_data);
    Q_data_normalized = 2 * (Q_data - Q_min) / (Q_max - Q_min) - 1;
end


