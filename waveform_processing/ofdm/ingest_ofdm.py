import numpy as np
import matplotlib.pylab as plt
import scipy
import scipy.signal

def read_complex_data_from_dat(filename):
    # Read the binary data
    with open(filename, 'rb') as f:
        data = f.read()

    # Convert the binary data to an array of 32-bit floats
    double_data = np.frombuffer(data, dtype=np.double)

    # Reshape the data into pairs of (I, Q) values
    complex_data = double_data[0::2] + 1j * double_data[1::2]

    return complex_data

# Get received usrp data
received_data = read_complex_data_from_dat("../masters_large_data/received_data/receive.dat")

# received_data = received_data[255:]

# received_data = received_data - np.mean(received_data)

# for i in range(0,199,1):
#     received_data[i] = 0.0 + 0.0j




# Get the original pulse
transmitted_data = np.load("../masters_large_data/transmitted_data/original_OFDM_pulse.npy")

# plt.plot(np.abs(transmitted_data))
# plt.show()

corrolation = scipy.signal.correlate(received_data,transmitted_data)

# pos_start_frame = np.argmax(np.abs(corrolation))


#received_data = received_data - np.mean(received_data)
# symbol = received_data[pos_start_frame:pos_start_frame+512]


# plt.plot(np.abs(symbol))
# plt.show()

# np.save("waveform_processing/symbol.npy",symbol)

freqs = np.fft.fftshift(np.fft.fftfreq(len(received_data),d=1/12.5e6))
plt.plot(freqs,np.fft.fftshift(20*np.log10(np.abs(np.fft.fft(received_data))/len(received_data))))
plt.title("Received signal fft")
plt.xlabel("Frequency (Hz)")
plt.ylabel("|received|")
plt.show()


plt.plot(np.real(received_data))
plt.plot(np.imag(received_data))
plt.title("Received signal")
plt.xlabel("Samples")
plt.ylabel("|received|")
plt.show()



corrolation_abs = np.abs(corrolation)

first_max = np.argmax(corrolation_abs)



# Parameters
sampling_rate = 12.5e6   # Sampling rate in Hz (1 MHz)
c = 299702547               # Speed of light in m/s (for distance calculation)

# Calculate the time spacing between samples
time_spacing = 1 / sampling_rate  # Time per sample in seconds

# Create an array of range bins in terms of time
range_bins_time = np.arange(len(corrolation[first_max:])) * time_spacing


# Convert time bins to distance bins using the speed of light (distance = speed * time)
range_bins_distance = range_bins_time * c / 2  # Divide by 2 for one-way travel time




plt.plot(np.abs(corrolation))

plt.title("Corrolation between received signal and original transmitted signal")
plt.xlabel("Distance (m)")
plt.ylabel("$|\\rho(received data,original frame)|$")
plt.show()


print(first_max)
data_frame = received_data[first_max-12500000:first_max]
print(len(data_frame))


plt.plot(np.real(data_frame))
plt.plot(np.imag(data_frame))
plt.title("Data Frame")
plt.show()

np.save("../masters_large_data/received_data/data_frame.npy",data_frame)

plt.plot(range_bins_distance,corrolation_abs[first_max:])

plt.title("Pulse integration output")
plt.xlabel("Distance (m)")
plt.ylabel("$|\\rho(received data,original frame)|$")
plt.show()