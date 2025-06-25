import numpy as np
import matplotlib
# matplotlib.use("TkAgg")
import matplotlib.pyplot as plt
from matplotlib.axes import Axes
from matplotlib.gridspec import GridSpec

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


# Enter the capture number that we want to check
capture_num = 2

# Load the data
raw_data = read_complex_data_from_dat(f"../masters_large_data/received_data/multi_receive/raw_captures/receive{capture_num}.dat")
correlation = np.load(f"../masters_large_data/received_data/multi_receive/correlations/correlation{capture_num}.npy")
data_frame = np.load(f"../masters_large_data/received_data/multi_receive/data_frames/data_frame{capture_num}.npy")
data_frame_dBV = np.load(f"../masters_large_data/received_data/multi_receive/data_frames_dBV/data_frame_dBV{capture_num}.npy")
channel_est = np.load(f"../masters_large_data/received_data/multi_receive/channel_estimations/channel_est{capture_num}.npy")


fig = plt.figure(figsize=(10, 8))
gs = GridSpec(2, 2, height_ratios=[1, 1])

# First subplot (top-left)
ax1: Axes = fig.add_subplot(gs[0, 0])
ax1.plot(np.real(raw_data), label="Real")
ax1.plot(np.imag(raw_data), label="Imag")
ax1.set_title(f"Raw IQ data for capture {capture_num}")
ax1.set_ylabel("Voltage (V)")
ax1.set_xlabel("Samples")
ax1.legend(loc='upper right')

# Second subplot (top-right)
ax2: Axes = fig.add_subplot(gs[0, 1])
ax2.plot(np.real(data_frame), label="Real")
ax2.plot(np.imag(data_frame), label="Imag")
ax2.set_title(f"Raw IQ from data frame for capture {capture_num} (normalised)")
ax2.set_ylabel("Voltage (V)")
ax2.set_xlabel("Samples")
ax2.legend(loc='upper right')

# Third subplot (bottom, spanning both columns)
ax3: Axes = fig.add_subplot(gs[1, :])
# Example content (you can replace this with whatever you'd like to plot)
correlation_abs = np.abs(correlation)
correlation_max_pos = np.argmax(correlation_abs)
ax3.plot(correlation_abs)
ax3.axvline(x=correlation_max_pos, color='red', linestyle='--', linewidth=1)
# ax3.set_xbound(correlation_max_pos-50,correlation_max_pos+150)
ax3.set_title("Correlation output of return signal")
ax3.set_ylabel("V^2")
ax3.set_xlabel("Samples")

plt.tight_layout()
plt.show()
# fig, axes = plt.subplots(2,1)

# axs: Axes = axes[0]
# axs.plot(np.real(raw_data),label="Real")
# axs.plot(np.imag(raw_data),label="Imag")
# axs.set_title(f"Raw IQ data for capture {capture_num}")
# axs.set_ylabel("Voltage (V)")
# axs.set_xlabel("Samples")
# axs.legend(loc='upper right')

# axs = axes[1]
# axs.plot(np.real(data_frame),label="Real")
# axs.plot(np.imag(data_frame),label="Imag")
# axs.set_title(f"Raw IQ from data frame for capture {capture_num}")
# axs.set_ylabel("Voltage (V)")
# axs.set_xlabel("Samples")
# axs.legend(loc='upper right')


# plt.tight_layout()
# plt.show()





fig, axes = plt.subplots(2,1)

axs: Axes = axes[0]
freqs = np.fft.fftshift(np.fft.fftfreq(len(data_frame_dBV),1/25000000))
axs.plot(freqs,data_frame_dBV)
axs.set_title(f"FFT of dataframe for capture {capture_num}")
axs.set_ylabel("Magnitude (dBV)")
axs.set_xlabel("Frequency (Hz)")

axs = axes[1]
axs.plot(channel_est)
axs.set_title(f"Channel estimation for capture {capture_num}")
axs.set_ylabel("Channel Est")
axs.set_xlabel("Pilots (Excluding DC)")


plt.tight_layout()
plt.show()