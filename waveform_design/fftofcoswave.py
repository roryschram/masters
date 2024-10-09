import numpy as np
import matplotlib.pyplot as plt

# Generate a sample signal: a combination of two sine waves
fs = 1000  # Sampling frequency (Hz)
t = np.linspace(0, 1, fs)
f1 = 100  # Frequencies of the sine waves (Hz)

# Create the signal
signal = np.sin(2 * np.pi * f1 * t)

# Perform FFT
fft_result = np.fft.fftshift(np.fft.fft(signal))

# Get frequency axis
fft_freq = np.fft.fftshift(np.fft.fftfreq(len(signal), d=1/fs))

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
plt.plot(fft_freq,magnitude)
plt.title('Magnitude of FFT of the Signal')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Magnitude')
plt.grid(True)

# Plot the FFT result
plt.subplot(3, 1, 3)
plt.plot(fft_freq,phase)
plt.title('Angle of FFT of the Signal')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Magnitude')
plt.grid(True)

# Adjust layout
plt.tight_layout()

# Show the plots
plt.show()
