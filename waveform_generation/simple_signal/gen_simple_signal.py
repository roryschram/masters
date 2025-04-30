import numpy as np
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pyplot as plt
import os


# Check to make sure that certain file paths exist, if not create them --> for data storage purposes
if not os.path.exists("../masters_large_data"):
    os.makedirs("../masters_large_data/")

if not os.path.exists("../masters_large_data/transmitted_data"):
    os.makedirs("../masters_large_data/transmitted_data/")

if not os.path.exists("../masters_large_data/received_data"):
    os.makedirs("../masters_large_data/received_data/")



# Define the simple signal function generation function --> essentially just returns a complex exponential at a certain frequency and sampling rate and duration
def gen_simple_signal(sampling_rate, frequency, duration=1.0):
    t = np.arange(0, duration, 1/sampling_rate)
    signal = np.exp(1j * 2 * np.pi * frequency * t)
    return signal


sampling_rate = 25_000_000  # 25 MHz
duration = 0.04             # 40 ms
num_pilots = 320              # The number of carriers (pilots in my case --> Reid says that an LTE subframe has 400 pilots :) ) in the signal
subcarrier_spacing = 31250  # 20 kHz

# Generate 501 subcarriers centered around 0 Hz with 10MHz of bandwidth
frequencies = np.linspace(-subcarrier_spacing * num_pilots / 2,subcarrier_spacing * (num_pilots / 2 - 1) ,num_pilots)
frequencies = np.append(frequencies,[5000000])

# Remove DC signal
frequencies = frequencies[frequencies != 0]

# Save the frequencies
np.save("../masters_large_data/processing/simple_signal_frequencies.npy",frequencies)


# Initialize signal
simple_sig = np.zeros(int(duration * sampling_rate), dtype=np.complex128)

# Sum the tones
for f in frequencies:
    simple_sig += gen_simple_signal(sampling_rate, f, duration)

# Normalize to avoid clipping or excessive amplitude
normalize_ratio = np.max(np.abs(simple_sig))
simple_sig /= normalize_ratio


print(frequencies)
print("The amount that was divided by to normalize was: "+str(normalize_ratio))
print("The length of the signal generated is: "+str(len(simple_sig)))





fig1, axs1 = plt.subplots(1,1)

# Plot the generated OFDM signal
axs1.plot(np.real(simple_sig),label="Real Part")  # Adjust the portion as needed
axs1.plot(np.imag(simple_sig),label="Imag Part") 
axs1.set_xlabel("Samples")
axs1.set_ylabel("Amplitude")
axs1.set_title("Real and Imag parts of OFDM signal")

plt.tight_layout()
plt.show()


fig2, axs2 = plt.subplots(2,1)

fft_vals = np.fft.fft(simple_sig)
freqs = np.fft.fftfreq(len(simple_sig),1/25000000)
fft_vals_abs = np.abs(fft_vals)

dBV = 20 * np.log10(fft_vals_abs + 1e-12)

# Plot the spectra of the generated OFDM signal
axs2[0].plot(freqs,dBV) # Adjust the portion as needed
axs2[0].set_xlabel("Freq (Hz)")
axs2[0].set_ylabel("Magnitude")
axs2[0].set_title("FFT of generated OFDM signal")

axs2[1].plot(freqs,np.angle(np.fft.fft(simple_sig))) # Adjust the portion as needed
axs2[1].set_xlabel("Freq (Hz)")
axs2[1].set_ylabel("Phase")
axs2[1].set_title("Phase of FFT of generated OFDM signal")


plt.tight_layout()
plt.show()







# Open a .dat file in binary write mode
with open("../masters_large_data/transmitted_data/transmit.dat", 'wb') as f:
    for sample in simple_sig:
        # Write the real part (I) as 64-bit double
        f.write(np.double(sample.real).tobytes())
        # Write the imaginary part (Q) as 64-bit double
        f.write(np.double(sample.imag).tobytes())


np.save("../masters_large_data/transmitted_data/simple_signal.npy",simple_sig)

