% Read IQ data from a .wav file
[I_data_wav, Q_data_wav, Fs] = processIQWav('data.wav');
plotIQData(I_data_wav, Q_data_wav);


function [I_data, Q_data, Fs] = processIQWav(filename)
    % Read the .wav file
    [y, Fs] = audioread(filename);
    
    % Check if the audio file has two channels
    if size(y, 2) ~= 2
        error('The .wav file must have two channels for I and Q data.');
    end
    
    % Extract I and Q data
    I_data = y(:, 1);
    Q_data = y(:, 2);
    
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