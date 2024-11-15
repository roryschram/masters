import numpy as np
import matplotlib.pylab as plt

def read_complex_data_from_dat(filename):
    # Read the binary data
    with open(filename, 'rb') as f:
        data = f.read()

    # Convert the binary data to an array of 32-bit floats
    double_data = np.frombuffer(data, dtype=np.double)

    # Reshape the data into pairs of (I, Q) values
    complex_data = double_data[0::2] + 1j * double_data[1::2]
    print(len(double_data))

    return complex_data

# Get received usrp data
received_data = read_complex_data_from_dat("received_data/receive.dat")

#received_data = received_data[255:]

# received_data = received_data - np.mean(received_data)

# for i in range(0,199,1):
#     received_data[i] = 0.0 + 0.0j




# Get the original pulse
# transmitted_data = np.load("waveform_generation/generated_data/padded_OFDM_pulse.npy")
transmitted_data = np.load("chirp_toolchain/sweep_signal.npy")

# plt.plot(np.abs(transmitted_data))
# plt.show()

corrolation = np.correlate(received_data,transmitted_data)

# pos_start_frame = np.argmax(np.abs(corrolation))


#received_data = received_data - np.mean(received_data)
# symbol = received_data[pos_start_frame:pos_start_frame+512]


# plt.plot(np.abs(symbol))
# plt.show()

# np.save("waveform_processing/symbol.npy",symbol)

freqs = np.fft.fftshift(np.fft.fftfreq(len(received_data),d=1/25e6))
plt.plot(freqs,np.fft.fftshift(20*np.log10(np.abs(np.fft.fft(received_data))/len(received_data))))
plt.title("Received signal fft")
plt.xlabel("Frequency (Hz)")
plt.ylabel("|received|")
plt.show()


plt.plot(np.real(received_data))
plt.plot(np.imag(received_data))
plt.xlim(0,100000)
plt.title("Received signal")
plt.xlabel("Samples")
plt.ylabel("|received|")
plt.show()



# Parameters
sampling_rate = 25e6   # Sampling rate in Hz (1 MHz)
num_bins = 7000        # Number of time bins
c = 299702547               # Speed of light in m/s (for distance calculation)

# Calculate the time spacing between samples
time_spacing = 1 / sampling_rate  # Time per sample in seconds

# Create an array of range bins in terms of time
range_bins_time = np.arange(num_bins) * time_spacing

# Convert time bins to distance bins using the speed of light (distance = speed * time)
range_bins_distance = range_bins_time * c / 2  # Divide by 2 for one-way travel time





plt.plot(np.abs(corrolation))

plt.title("Corrolation between received signal and original transmitted signal")
plt.xlabel("Distance (m)")
plt.ylabel("$|\\rho(received data,original frame)|$")
plt.show()


corrolation_abs = np.abs(corrolation)

first_max = np.argmax(corrolation_abs[0:7000])

print(first_max)



chirps = np.zeros(shape=(0,7000))

for i in range(0,70000+1-7000,7000):
    print(first_max)
    chirps = np.vstack((chirps,corrolation_abs[first_max+i:first_max+i+7000]))


output = np.zeros(shape=(7000,))

for row in chirps:
    output += row

plt.plot(range_bins_distance,output)

plt.title("Pulse integration output")
plt.xlabel("Distance (m)")
plt.ylabel("$|\\rho(received data,original frame)|$")
plt.show()