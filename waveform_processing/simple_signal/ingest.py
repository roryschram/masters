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
# received_data = read_complex_data_from_dat("../masters_large_data/received_data/multi_receive/raw_captures/receive1.dat")
received_data = read_complex_data_from_dat("../masters_large_data/received_data/receive.dat")

# Get the original transmitted clean pulse
transmitted_data = read_complex_data_from_dat("../masters_large_data/transmitted_data/transmit.dat")


# Perform a correlation using scipy for fft correlation (speed)
correlation = scipy.signal.correlate(received_data,transmitted_data,mode='same')
correlation_abs = np.abs(correlation)

print(len(correlation))

# Get the largest value of the correlation --> start of received data
pos_start_frame = np.argmax(correlation_abs)
start_frame_val = np.max(correlation_abs)
start_frame_val_time = received_data[pos_start_frame]

print(str(pos_start_frame)+","+str(start_frame_val))

# get the symbol
symbol = np.array(received_data[pos_start_frame-500000:pos_start_frame+500000])
print(len(symbol))
# Normalize to avoid clipping or excessive amplitude
normalize_ratio = np.max(np.abs(symbol))
symbol /= normalize_ratio

print("Normalization Ratio: "+str(round(normalize_ratio,20)))


# Save the symbol for later processing
np.save("../masters_large_data/processing/simple_signal_symbol.npy",symbol)

# Import frequencies
frequencies = np.load("../masters_large_data/processing/simple_signal_frequencies.npy")




# Plot the received signal and the correlation
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


# Plot the symbol
fig, axs = plt.subplots(1,1)
axs.plot(np.real(symbol),label = "Real Part")
axs.plot(np.imag(symbol),label = "Imag Part")
axs.set_title("Plot of the OFDM received symbol")
axs.set_xlabel("Samples")
axs.set_ylabel("Amplitude")
axs.legend()

plt.tight_layout()
plt.show()




# Plot the fft and phase
fig, axs = plt.subplots(2,1)
ax: Axes = axs[0]

fft_vals = np.fft.fft(symbol)
freqs = np.fft.fftfreq(len(fft_vals),1/25000000)
fft_vals_abs = np.abs(fft_vals)

dBV = 20 * np.log10(fft_vals_abs + 1e-12)

np.save("../masters_large_data/processing/simple_signal_dBV_receive.npy",np.fft.fftshift(dBV))

ax.plot(freqs,dBV) # Adjust the portion as needed
for freq in frequencies:
    ax.axvline(x=freq, color='red', linestyle='--', linewidth=1)

ax.set_xlabel("Freq (Hz)")
ax.set_ylabel("dBV")
ax.set_title("FFT of generated OFDM signal")

ax = axs[1]
ax.plot(freqs,np.angle(fft_vals)) # Adjust the portion as needed
ax.set_xlabel("Freq (Hz)")
ax.set_ylabel("Phase")
ax.set_title("Phase of FFT of generated OFDM signal")

plt.tight_layout()
plt.show()


