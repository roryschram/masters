import numpy as np
import matplotlib.pyplot as plt

# Parameters for the sweep
f_start = 0             # Start frequency in Hz
f_end = 1e6             # End frequency in Hz (1 MHz)
duration = 0.001            # Duration of the sweep in seconds
sample_rate = 12.5e6      # Sampling rate in Hz (50 MHz)

# Time vector based on the sample rate and duration
t = np.linspace(0, duration, int(sample_rate * duration))

# Generate the sweep signal
sweep_signal = np.sin(2 * np.pi * (f_start + (f_end - f_start) * t / duration) * t)

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



# # Read the binary data
# with open("transmitted_data/transmit.dat", 'rb') as f:
#     data = f.read()
    
#     # Convert the binary data to an array of 32-bit floats
#     double_data = np.frombuffer(data, dtype=np.double)
    
#     # Reshape the data into pairs of (I, Q) values
#     complex_data = double_data[0::2] + 1j * double_data[1::2]

# plt.plot(np.real(complex_data))
# plt.plot(np.imag(complex_data))
# plt.show()
