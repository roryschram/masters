import numpy as np
import matplotlib.pyplot as plt

# Parameters
sampling_rate = 25000000  # Sampling rate (Hz)
duration = 0.016  # Duration of the signal (seconds)
frequencies = np.arange(0, 1000001, 500)  # Frequencies from 100 Hz to 1000 Hz in steps of 100 Hz

# Time array
t = np.linspace(0, duration, int(sampling_rate * duration), endpoint=False)

# Create a signal by adding sinusoids with increasing frequencies
signal = np.zeros_like(t)
for f in frequencies:
    signal += np.sin(2 * np.pi * f * t)

# Compute the FFT of the signal
fft_signal = np.abs(np.fft.fft(signal))
fft_freqs = np.fft.fftfreq(len(t), 1/sampling_rate)

# Only keep the positive frequencies
positive_freqs = fft_freqs[:len(fft_freqs)//2]
positive_fft = np.abs(fft_signal)[:len(fft_signal)//2]

print(len(signal))

signal = signal/200
# Plot the signal
plt.figure(figsize=(10, 6))
plt.subplot(2, 1, 1)
plt.plot(t, signal)
plt.title('Sum of Sinusoids with Increasing Frequencies')
plt.xlabel('Time [s]')
plt.ylabel('Amplitude')
plt.grid(True)

# Plot the FFT
plt.subplot(2, 1, 2)
plt.plot(fft_freqs, fft_signal)
plt.title('FFT of the Signal')
plt.xlabel('Frequency [Hz]')
plt.ylabel('Magnitude')
plt.grid(True)

plt.tight_layout()
plt.show()












# Open a .dat file in binary write mode
with open("transmitted_data/transmit.dat", 'wb') as f:
    for sample in signal:
        # Write the real part (I) as 64-bit double
        f.write(np.double(sample.real).tobytes())
        # Write the imaginary part (Q) as 64-bit double
        f.write(np.double(sample.imag).tobytes())


# np.save("transmitted_data/sweep_signal.npy",sweep_signal)
# np.save("transmitted_data/padded_sweep_signal.npy",padded_sweep_signal)


