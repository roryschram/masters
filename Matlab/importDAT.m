clear all;
[I_data, Q_data, complexData] = readIQData('data.dat');
[I_data_normalized, Q_data_normalized] = normalizeToRange(I_data, Q_data);


% Assuming I_data and Q_data are already loaded using the readIQData function
plotIQData(I_data_normalized, Q_data_normalized);

plotIQFFT(I_data, Q_data, 10e6);


 function [I_data, Q_data, complex_data] = readIQData(filename)
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
    complex_data = I_data + 1i * Q_data;
    
    % Close the file
    fclose(fileID);
 end


 function plotIQData(I_data, Q_data)
    % Create a complex vector from I_data and Q_data
    complexData = I_data + 1i * Q_data;
    
    % Plot the real (I) and imaginary (Q) parts
    figure;
    plot(real(complexData), imag(complexData), 'o');
    
    % Add labels and title
    xlabel('In-phase (I)');
    ylabel('Quadrature (Q)');
    title('IQ Data Plot');
    grid on;

 end


 function plotIQFFT(I_data, Q_data, Fs)
    % Create a complex vector from I_data and Q_data
    complexData = I_data + 1i * Q_data;

    % Length of data
    N = length(complexData);

    % Compute the FFT
    fftData = fft(complexData);

    % Shift the zero frequency component to the center of the spectrum
    fftDataShifted = fftshift(fftData);

    % Frequency vector
    f = (-N/2:N/2-1)*(Fs/N);

    % Calculate the magnitude of the FFT in dB
    fftMagnitude_dB = 20*log10(abs(fftDataShifted));


    % Plot the magnitude of the FFT in dB
    figure;
    plot(f, fftMagnitude_dB);
    
    % Add labels and title
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title('Double-Sided FFT of IQ Data');
    grid on;
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


