import numpy as np
import matplotlib.pyplot as plt


# Number of carriers in the signal
numCarriers = 4

# Spacing between each carrier in the signal (must be even number)
carrierSpacing = 1000

# Create an array of zeros that is the correct length for the frequency domain version of the signal
waveformFreqDomain = np.zeros(30000,dtype=np.complex128)


# Create an array of sub-carrier indices where the carriers are
subcarrier_indices = [14500,15500,13500,16500,12500,17500,11500,18500,10500,19500]

# # If you only have one carrier, set that
# if (numCarriers == 1):
#     subcarrier_indices.append(int(len(waveformFreqDomain)/2))
# else:
#     # Build the sub-carrier index array
#     for i in range(0,numCarriers-1):
#         print("Here")
#         subcarrier_indices.append(subcarrier_indices[i]+carrierSpacing)

# print(subcarrier_indices)

# Assign value 1+0j to the subcarrier positions
for index in subcarrier_indices:
    waveformFreqDomain[index] = 1 + 1j



# waveformFreqDomain[10010] = 1+0j


# waveformFreqDomain[9500] = 1+1j
# waveformFreqDomain[10500] = 1+1j

# waveformFreqDomain[8500] = 1+1j
# waveformFreqDomain[11500] = 1+1j

# waveformFreqDomain[7500] = 1+1j
# waveformFreqDomain[12500] = 1+1j

# waveformFreqDomain[6500] = 1+1j
# waveformFreqDomain[13500] = 1+1j

# waveformFreqDomain[55] = 1+0j
# waveformFreqDomain[145] = 1+0j

# waveformFreqDomain[45] = 1+0j
# waveformFreqDomain[155] = 1+0j

# waveformFreqDomain[35] = 1+0j
# waveformFreqDomain[165] = 1+0j

# waveformFreqDomain[25] = 1+0j
# waveformFreqDomain[175] = 1+0j

waveformFreqDomain = np.pad(waveformFreqDomain, (0, 0), 'constant', constant_values=(0+0j,0+0j))

# Do the IFFT of the time domain signal
waveformTimeDomain = np.fft.ifft(np.fft.fftshift(waveformFreqDomain))

#waveformTimeDomain = np.pad(waveformTimeDomain, (5000, 0), mode='constant', constant_values=0+0j)


# Adding AWGN
mean = 0
std_dev = 0.0001

# Generate white Gaussian noise
noise = np.random.normal(mean, std_dev, waveformTimeDomain.shape)

# Add the noise to the signal
noisyWaveformTimeDomain = waveformTimeDomain + noise

# Do FFT of noisy signal
noisyWaveformFreqDomain = np.fft.fftshift(np.fft.fft(noisyWaveformTimeDomain))


# ################## Normalise Time Domain Signal and save as .dat file ###########################
# # Step 1: Find the minimum and maximum values
# min_val = np.min(waveformTimeDomain)
# max_val = np.max(waveformTimeDomain)

# # Step 2: Scale the array to [0, 1]
# scaled_arr = (waveformTimeDomain - min_val) / (max_val - min_val)

# # Step 3: Rescale to [-1, 1]
# normalizedWaveformTimeDomain = 2 * scaled_arr - 1


def scale_complex_signal(signal, new_min, new_max):
    # Normalize real part
    real_part = np.real(signal)
    real_min = np.min(real_part)
    real_max = np.max(real_part)
    normalized_real = (real_part - real_min) / (real_max - real_min)
    
    # Normalize imaginary part
    imag_part = np.imag(signal)
    imag_min = np.min(imag_part)
    imag_max = np.max(imag_part)
    normalized_imag = (imag_part - imag_min) / (imag_max - imag_min)
    
    # Scale real and imaginary parts to the new range
    scaled_real = normalized_real * (np.real(new_max) - np.real(new_min)) + np.real(new_min)
    scaled_imag = normalized_imag * (np.imag(new_max) - np.imag(new_min)) + np.imag(new_min)
    
    # Combine the scaled real and imaginary parts
    scaled_signal = scaled_real + 1j * scaled_imag
    
    return scaled_signal

# Example usage:
signal = waveformTimeDomain

# Define the new complex range
new_min = complex(-0.5, -0.5)
new_max = complex(0.5, 0.5)

# Scale the complex signal
scaled_signal = scale_complex_signal(signal, new_min, new_max)



# Step 1: Separate real and imaginary parts
real_part = np.real(scaled_signal)
imag_part = np.imag(scaled_signal)

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

print(interleaved_array)


# Create the subplots
fig, axs = plt.subplots(3, 2, figsize=(8, 6))

# Axis 1
axs[0,0].plot(np.abs(waveformFreqDomain))
axs[0,0].set_title('Waveform in Freq Domain')
axs[0,0].set_xlabel('Freq (Hz)')
axs[0,0].set_ylabel('Value')

# Axis 2
axs[1,0].plot(np.real(interleaved_array))
axs[1,0].set_title('Waveform in Time Domain')
axs[1,0].set_xlabel('Index')
axs[1,0].set_ylabel('Value')

# Axis 3
axs[0,1].plot(np.real(noisyWaveformTimeDomain))
axs[0,1].set_title('Waveform in Time Domain with Noise')
axs[0,1].set_xlabel('Index')
axs[0,1].set_ylabel('Value')

# Axis 4
axs[1,1].plot(np.abs(noisyWaveformFreqDomain))
axs[1,1].set_title('Waveform in Freq Domain with Noise')
axs[1,1].set_xlabel('Freq (Hz)')
axs[1,1].set_ylabel('Value')

# Axis 5
axs[2,0].scatter(np.real(waveformFreqDomain), np.imag(waveformFreqDomain))
axs[2,0].set_title('Argand')
axs[2,0].set_xlabel('Real')
axs[2,0].set_ylabel('Imag')

# Axis 6
axs[2,1].scatter(np.real(noisyWaveformFreqDomain), np.imag(noisyWaveformFreqDomain))
axs[2,1].set_title('Argand')
axs[2,1].set_xlabel('Real')
axs[2,1].set_ylabel('Imag')

# Adjust the layout
plt.tight_layout()

# Show the plot
plt.show()


