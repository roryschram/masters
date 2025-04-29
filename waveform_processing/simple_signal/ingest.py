import numpy as np
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pylab as plt
from matplotlib.axes import Axes
import scipy
import scipy.signal


# Function to read complex data from given filename
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


# Get the original transmitted clean pulse
transmitted_data = read_complex_data_from_dat("../masters_large_data/transmitted_data/transmit.dat")


# Perform a correlation using scipy for fft correlation (speed)
correlation = scipy.signal.correlate(received_data,transmitted_data,mode='same')
correlation_abs = np.abs(correlation)

# Get the largest value of the correlation --> start of received data
pos_start_frame = np.argmax(correlation_abs)
start_frame_val = np.max(correlation_abs)
start_frame_val_time = received_data[pos_start_frame]

print(str(pos_start_frame)+","+str(start_frame_val))

# get the symbol
symbol = received_data[pos_start_frame:pos_start_frame+1000000]


# Save the symbol for later processing
np.save("../masters_large_data/processing/simple_signal_symbol.npy",symbol)


fig, axs = plt.subplots(2,1)
ax: Axes = axs[0]
ax.plot(np.real(received_data),label = "Real Part")
ax.plot(np.imag(received_data),label = "Imag Part")
ax.set_title("Received signal")
ax.set_xlabel("Samples")
ax.set_ylabel("Amplitude")
ax.legend()
ax.plot(pos_start_frame,np.real(start_frame_val_time),'ro')
ax.annotate(
    str(pos_start_frame),
    xy=(pos_start_frame, np.real(start_frame_val_time)),           # point to annotate
    xytext=(pos_start_frame + 0.5, np.real(start_frame_val_time)), # text position
)



ax = axs[1]
ax.plot(correlation_abs)
ax.set_title("Absoluted correlation of transmit and receive")
ax.set_xlabel("Samples")
ax.set_ylabel("Magnitude")
ax.plot(pos_start_frame,start_frame_val,'ro')
ax.annotate(
    str(pos_start_frame)+","+str(round(start_frame_val,2)),
    xy=(pos_start_frame, start_frame_val),           # point to annotate
    xytext=(pos_start_frame + 0.5, start_frame_val), # text position
)

plt.tight_layout()
plt.show()



fig, axs = plt.subplots(1,1)
axs.plot(np.real(symbol),label = "Real Part")
axs.plot(np.imag(symbol),label = "Imag Part")
axs.set_title("Plot of the OFDM signal")
axs.set_xlabel("Samples")
axs.set_ylabel("Amplitude")
axs.legend()

plt.tight_layout()
plt.show()

# # freqs = np.fft.fftshift(np.fft.fftfreq(len(received_data),d=1/12.5e6))
# # plt.plot(freqs,np.fft.fftshift(20*np.log10(np.abs(np.fft.fft(received_data))/len(received_data))))
# # plt.title("Received signal fft")
# # plt.xlabel("Frequency (Hz)")
# # plt.ylabel("|received|")
# # plt.show()


# plt.plot(np.real(received_data))
# plt.plot(np.imag(received_data))
# plt.title("Received signal")
# plt.xlabel("Samples")
# plt.ylabel("|received|")
# plt.show()



# corrolation_abs = np.abs(corrolation)

# first_max = np.argmax(corrolation_abs)



# # Parameters
# sampling_rate = 12.5e6   # Sampling rate in Hz (1 MHz)
# c = 299702547               # Speed of light in m/s (for distance calculation)

# # Calculate the time spacing between samples
# time_spacing = 1 / sampling_rate  # Time per sample in seconds

# # Create an array of range bins in terms of time
# range_bins_time = np.arange(len(corrolation[first_max:])) * time_spacing


# # Convert time bins to distance bins using the speed of light (distance = speed * time)
# range_bins_distance = range_bins_time * c / 2  # Divide by 2 for one-way travel time




# plt.plot(np.abs(corrolation))

# plt.title("Corrolation between received signal and original transmitted signal")
# plt.xlabel("Distance (m)")
# plt.ylabel("$|\\rho(received data,original frame)|$")
# plt.show()


# print(first_max)
# data_frame = received_data[first_max-12500000:first_max]
# print(len(data_frame))


# # plt.plot(np.real(data_frame))
# # plt.plot(np.imag(data_frame))
# # plt.title("Data Frame")
# # plt.show()

# np.save("../masters_large_data/received_data/data_frame.npy",data_frame)

# # plt.plot(range_bins_distance,corrolation_abs[first_max:])

# # plt.title("Pulse integration output")
# # plt.xlabel("Distance (m)")
# # plt.ylabel("$|\\rho(received data,original frame)|$")
# # plt.show()