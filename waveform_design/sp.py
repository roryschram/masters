from scipy.fft import fft, ifft
import numpy as np
import matplotlib.pyplot as plt

# Generate a sample signal: a combination of two sine waves
fs = 1000  # Sampling frequency (Hz)
t = np.arange(0, 1, 1/fs)
f1 = 10  # Frequencies of the sine waves (Hz)

# Create the signal
signal = np.cos(2 * np.pi * f1 * t)

# Perform FFT
fft_result = np.fft.fftshift(fft(signal))

# Compute the magnitude and phase
magnitude = np.abs(fft_result)
phase = np.angle(fft_result)


# Plot the original signal
plt.figure(figsize=(14, 6))

plt.subplot(3, 1, 1)
plt.plot(t,signal)
plt.title('Original Signal')
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.grid(True)

# Plot the FFT result
plt.subplot(3, 1, 2)
plt.plot(magnitude)
plt.title('Magnitude of FFT of the Signal')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Magnitude')
plt.grid(True)

# Plot the FFT result
plt.subplot(3, 1, 3)
plt.plot(phase)
plt.title('Angle of FFT of the Signal')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Magnitude')
plt.grid(True)

# Adjust layout
plt.tight_layout()

# Show the plots
plt.show()




