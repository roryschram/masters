function plotFFT(input,sample_rate)
%
%   Function that takes in an array of complex values and displays an double
%   sided FFT of the data
%

    % Length of data
    N = length(input);

    % Compute the FFT
    fftData = fft(input);

    % Shift the zero frequency component to the center of the spectrum
    fftDataShifted = fftshift(fftData);

    % Frequency vector
    f = (-N/2:N/2-1)*(sample_rate/N);

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

