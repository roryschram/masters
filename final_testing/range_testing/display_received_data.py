import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.axes import Axes
from scipy import signal

fs = 25e6

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
transmitted_data = read_complex_data_from_dat("../masters_large_data/transmitted_data/transmit.dat")

# Get correlation
corr = signal.correlate(received_data,transmitted_data)
corr = np.abs(corr)

# Get maximum of correlation
# Compute the lag array (for correct alignment of index)
pos_max = np.argmax(corr)

# Get corresponding lag value
print("Position of start of frame: "+str(pos_max))

# Extract rough frame
frame = np.array(received_data[pos_max-1250:pos_max])

# # Do FFT
# fft = np.abs(np.fft.fft(frame))
# freqs = np.fft.fftfreq(len(frame),1/fs)

# === Compute FFT of the OFDM signal (with CP) ===
n_fft_plot = 1250  # Use zero-padding for better resolution
spectrum = np.fft.fftshift(np.fft.fft(frame, n=n_fft_plot))
spectrum_magnitude_db = 20 * np.log10(np.abs(spectrum) + 1e-12)  # avoid log(0)

# Frequency axis in MHz
freq_axis = np.linspace(-fs/2, fs/2, n_fft_plot) / 1e6


active_subcarriers = 900
n_pilots = 75
pilot_indices = np.round(np.linspace(0, active_subcarriers - 1, n_pilots)).astype(int)
print(pilot_indices)

# Map active subcarriers: first 450 go to positive freqs, next 450 to negative
pilot_indices_pos = pilot_indices[pilot_indices < 450]
pilot_indices_neg = pilot_indices[pilot_indices >= 450]

# Convert to FFT bin positions
fft_bins_pos = 1 + pilot_indices_pos
fft_bins_neg = -450 + (pilot_indices_neg - 450) + 1250  # wrap-around for negative freqs

# Combine both into full FFT bin indices
pilot_fft_bins = np.concatenate([fft_bins_pos, fft_bins_neg])
print(pilot_fft_bins)


fig, axis = plt.subplots(2,1)

axis = axis.flatten()
ax:Axes = axis[0]

ax.plot(np.real(received_data),label = "Real")
ax.plot(np.imag(received_data), label = "Imag")
ax.legend()
ax.set_title("Raw received signal")
ax.set_xlabel("Samples")
ax.set_ylabel("Amplitude")

ax = axis[1]
ax.plot(corr)
ax.set_title("Correlation of transmitted and received")
ax.set_xlabel("Samples")
ax.set_ylabel("|corr|")

plt.tight_layout()
plt.show()


fig, axis = plt.subplots(2,1)

axis = axis.flatten()
ax:Axes = axis[0]

ax = axis[0]
ax.plot(np.real(frame),label = "Real")
ax.plot(np.imag(frame), label = "Imag")
ax.legend()
ax.set_title("Roughly extracted frame")
ax.set_xlabel("Samples")
ax.set_ylabel("Amplitude")

ax = axis[1]
ax.plot(freq_axis,spectrum_magnitude_db)
ax.set_title("FFt of roughly extracted frame")
ax.set_xlabel("Freq (Hz)")
ax.set_ylabel("Amplitude")

# twin = ax.twiny()
# # twin.set_xlim(ax.get_xlim())
# twin.set_xticks(np.arange(0, 1249))
# twin.set_xlabel("Freq bins")


plt.tight_layout()
plt.show()
