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

    return np.array(complex_data)

# Get received usrp data
received_data = read_complex_data_from_dat("../masters_large_data/received_data/receive.dat")
transmitted_data = read_complex_data_from_dat("../masters_large_data/transmitted_data/transmit.dat")

received_data = received_data[1000000:]


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












# ######################## Experimental # ###################
# === OFDM Parameters ===
bw = 18e6  # Bandwidth = 10 MHz
subcarrier_spacing = 20e3  # 15 kHz LTE spacing
n_subcarriers = 1250  # FFT size
fs = subcarrier_spacing * n_subcarriers  # Sampling rate = 15.36 MHz fs => 25MHz
cp_len = int(n_subcarriers * 1/8)  # Cyclic Prefix (12.5%)

# === Data and Pilot Parameters ===
active_subcarriers = 900
n_pilots = 75
n_data = active_subcarriers - n_pilots


pilot_symbols = np.random.choice([1+1j, 1+1j], size=n_pilots)  # BPSK pilots
data_symbols = np.random.choice([1+1j, 1-1j, -1+1j, -1-1j], size=n_data)  # QPSK data

# === Insert pilots evenly across the 600 active subcarriers ===
ofdm_symbols = np.zeros(active_subcarriers, dtype=complex)
pilot_indices = np.round(np.linspace(0, active_subcarriers - 1, n_pilots)).astype(int)
data_iter = iter(data_symbols)

for i in range(active_subcarriers):
    if i in pilot_indices:
        ofdm_symbols[i] = 1
    else:
        ofdm_symbols[i] = 0

# === Map to full IFFT input (zero out DC) ===
ifft_input = np.zeros(n_subcarriers, dtype=complex)
half = active_subcarriers // 2
ifft_input[1:1+half] = ofdm_symbols[:half]          # Positive freqs
ifft_input[-half:] = ofdm_symbols[half:]            # Negative freqs

# ######################## Experimental # ###################


ifft_input = np.fft.fftshift(ifft_input)
print(ifft_input)
# Get indices where pilots exist
pilot_bins = np.where(ifft_input == 1)[0]

# Get the corresponding magnitudes
pilot_mags = spectrum_magnitude_db[pilot_bins]

# Plot
plt.figure(figsize=(10, 4))
plt.plot(pilot_bins, pilot_mags)
plt.xlabel("FFT Bin Index")
plt.ylabel("Magnitude (dB)")
plt.ylim(-60,0)
plt.title("FFT Magnitude at Pilot Positions")
plt.grid()
plt.tight_layout()
plt.show()














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
ax.plot(spectrum_magnitude_db)
ax.set_title("FFt of roughly extracted frame")
ax.set_xlabel("Freq (Hz)")
ax.set_ylabel("Amplitude")

for bin_idx in pilot_bins:
    ax.axvline(x=bin_idx, color='red', linestyle='--', linewidth=0.5, alpha=0.7)

# twin = ax.twiny()
# # twin.set_xlim(ax.get_xlim())
# twin.set_xticks(np.arange(0, 1249))
# twin.set_xlabel("Freq bins")


plt.tight_layout()
plt.show()
