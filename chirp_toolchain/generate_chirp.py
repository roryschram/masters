import numpy as np
import matplotlib.pyplot as plt

# Parameters
f_start = 0             # Start frequency in Hz
f_end = 250e3             # End frequency in Hz (1 MHz)
sample_rate = 25e6      # Sampling rate in Hz (50 MHz)
num_samples = 10000    # Number of samples for the chirp signal

# Time vector based on the sample rate and number of samples
t = np.arange(num_samples) / sample_rate

# Generate the chirp signal
# Linear frequency sweep from f_start to f_end over the length of the signal
sweep_signal = np.sin(2 * np.pi * (f_start + (f_end - f_start) * t / t[-1]) * t)

frequencies = np.fft.fftfreq(num_samples, d=1/sample_rate)
plt.plot(frequencies,np.abs(np.fft.fft(sweep_signal)))
plt.show()

padded_sweep_signal = np.pad(sweep_signal, pad_width=200, mode='constant', constant_values=0)

print(len(sweep_signal))

# Plot the generated sweep signal (showing only a portion for clarity)
plt.plot(np.real(padded_sweep_signal),label="Real Part")  # Adjust the portion as needed
plt.plot(np.imag(padded_sweep_signal),label="Imag Part") 
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.title("1 MHz Sweep Signal (Sampled at 50 MHz)")
plt.legend()
plt.show()

# Open a .dat file in binary write mode
with open("transmitted_data/transmit.dat", 'wb') as f:
    for sample in padded_sweep_signal:
        # Write the real part (I) as 64-bit double
        f.write(np.double(sample.real).tobytes())
        # Write the imaginary part (Q) as 64-bit double
        f.write(np.double(sample.imag).tobytes())


np.save("chirp_toolchain/sweep_signal.npy",sweep_signal)
np.save("chirp_toolchain/padded_sweep_signal.npy",padded_sweep_signal)


