import numpy as np
import matplotlib.pyplot as plt

# Create an array of zeros that is the correct length for the frequency domain version of the signal
waveformFreqDomain = np.zeros(30000,dtype=np.complex128)

# Create an array of sub-carrier indices where the carriers are
subcarrier_indices = [14500,15500,13500,16500,12500,17500,11500,18500,10500,19500]

# Assign value 1+0j to the subcarrier positions
for index in subcarrier_indices:
    waveformFreqDomain[index] = 1 + 1j


# Potentially add padding
waveformFreqDomain = np.pad(waveformFreqDomain, (0, 0), 'constant', constant_values=(0+0j,0+0j))

# Do the IFFT of the time domain signal
waveformTimeDomain = np.fft.ifft(np.fft.fftshift(waveformFreqDomain))



# Define the new range for scaling
new_min = -0.25
new_max = 0.25

# Scale the real part
real_scaled = np.interp(waveformTimeDomain.real, (np.min(waveformTimeDomain.real), np.max(waveformTimeDomain.real)), (new_min, new_max))

# Scale the imaginary part
imag_scaled = np.interp(waveformTimeDomain.imag, (np.min(waveformTimeDomain.imag), np.max(waveformTimeDomain.imag)), (new_min, new_max))

# Reconstruct the scaled complex signal
waveformTimeDomain = real_scaled + 1j * imag_scaled






# Create a chirp for the beginning of the signal

# Parameters
f0 = 10  # Start frequency (Hz)
f1 = 10000  # End frequency (Hz)
t1 = 0.002  # Duration of the chirp (seconds)
fs = 12.5e6  # Sampling rate (samples per second)

# Time array
t = np.linspace(0, t1, int(fs*t1))

# Create chirp signal (linear frequency variation)
chirp_signal = 0.25*np.sin(2 * np.pi * (f0 + (f1 - f0) * t / t1) * t)

chirp_padded = np.pad(chirp_signal, (5000, 2500), 'constant', constant_values=(0+0j,0+0j))

# Appened the arrays together
waveformTimeDomain = np.concatenate((chirp_padded, waveformTimeDomain))







matched_output = np.correlate(chirp_signal,chirp_padded,mode='full')

print(np.argmax(matched_output))






# Save the signal to a file ################
# Step 1: Separate real and imaginary parts
real_part = np.real(waveformTimeDomain)
imag_part = np.imag(waveformTimeDomain)

# Step 2: Interleave real and imaginary parts
interleaved_array = np.empty((real_part.size + imag_part.size,), dtype=np.float64)
interleaved_array[0::2] = real_part
interleaved_array[1::2] = imag_part

# Step 3: Save the interleaved array to a .dat file
interleaved_array.tofile('output.dat')

# Step 1: Load the binary data from the .dat file
loaded_array = np.fromfile('output.dat', dtype=np.float64)

# Step 2: Check the length of the loaded array
length = len(loaded_array)

# Step 3: Calculate the number of complex numbers (each complex number has 2 floats)
num_complex_numbers = length // 2

print(f"Length of the loaded array: {length}")
print(f"Number of complex numbers: {num_complex_numbers}")
###########################################################




# Create the subplots
fig, axs = plt.subplots(3, 2, figsize=(8, 6))

# Axis 1
axs[0,0].plot(np.abs(waveformFreqDomain))
axs[0,0].set_title('Waveform in Freq Domain')
axs[0,0].set_xlabel('Freq (Hz)')
axs[0,0].set_ylabel('Value')

# Axis 2
fft = np.fft.fft(waveformTimeDomain[32499:62500])
axs[1,0].scatter(np.real(fft),np.imag(fft))
axs[1,0].set_title('Waveform in Time Domain')
axs[1,0].set_xlabel('Index')
axs[1,0].set_ylabel('Value')

# Axis 3
axs[2,0].scatter(np.real(waveformFreqDomain), np.imag(waveformFreqDomain))
axs[2,0].set_title('Argand')
axs[2,0].set_xlabel('Real')
axs[2,0].set_ylabel('Imag')

# Axis 4
axs[0,1].plot(chirp_padded)
axs[0,1].set_title('Chirp Signal')
axs[0,1].set_xlabel('Samples')
axs[0,1].set_ylabel('Magnitude')

# Axis 5
axs[1,1].plot(matched_output)
axs[1,1].set_title('Chirp Signal')
axs[1,1].set_xlabel('Samples')
axs[1,1].set_ylabel('Magnitude')

# Axis 6
axs[2,1].plot(waveformTimeDomain)
axs[2,1].set_title('Chirp Signal')
axs[2,1].set_xlabel('Samples')
axs[2,1].set_ylabel('Magnitude')


# Adjust the layout
plt.tight_layout()

# Show the plot
plt.show()


