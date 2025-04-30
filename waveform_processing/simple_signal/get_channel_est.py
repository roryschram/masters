import numpy as np
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pylab as plt
from matplotlib.axes import Axes
import scipy
import scipy.signal

# Import data
dBV_transmit = np.load("../masters_large_data/processing/simple_signal_dBV_transmit.npy")
dBV_receive = np.load("../masters_large_data/processing/simple_signal_dBV_receive.npy")
frequencies = np.load("../masters_large_data/processing/simple_signal_frequencies.npy")

# Work out channel est

# Inputs
Fs = 25e6                      # Sampling rate in Hz
N = 1_000_000                  # FFT length
fft_data = dBV_receive  # Make sure it's fftshifted

# Convert frequencies to indices (fftshifted logic)
indices = np.round((frequencies + Fs/2) / Fs * N).astype(int)

# Clip to valid index range
indices = np.clip(indices, 0, N - 1)

# Extract values
transmit_carrier_values = dBV_transmit[indices]
receive_carrier_values = dBV_receive[indices]

print(indices)


channel_est = receive_carrier_values / transmit_carrier_values

print(dBV_transmit[300000])








# Plot data
fig, axes = plt.subplots(2,1)

ax: Axes = axes[0]
ax.plot(dBV_transmit)
for k in indices:
    ax.axvline(x=k, color='red', linestyle='--', linewidth=1)
ax.set_title("FFT of the transmitted waveform")
ax.set_ylabel("dBv")
ax.set_xlabel("Samples")

ax = axes[1]
ax.plot(dBV_receive)
for k in indices:
    ax.axvline(x=k, color='red', linestyle='--', linewidth=1)
ax.set_title("FFT of the received waveform")
ax.set_ylabel("dBv")
ax.set_xlabel("Samples")


fig, axes = plt.subplots(2,1)
ax = axes[0]
ax.plot(transmit_carrier_values)
ax.set_title("Extracted carriers from transmitted waveform")
ax.set_ylabel("dBv")
ax.set_xlabel("Carriers")

ax = axes[1]
ax.plot(receive_carrier_values)
ax.set_title("Extracted carriers from transmitted waveform")
ax.set_ylabel("dBv")
ax.set_xlabel("Carriers")




fig, axes = plt.subplots(1,1)
axes.plot(channel_est)
plt.tight_layout()
plt.show()