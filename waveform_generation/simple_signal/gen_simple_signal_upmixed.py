import numpy as np
import matplotlib
# matplotlib.use("TkAgg")
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

# frequencies = np.array([-60000,-40000,-20000,20000,40000,60000])

carrier = gen_simple_signal(1000000000,100000000,0.0001)

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

simple_sig = np.array(simple_sig)
carrier = np.array(carrier)
simple_sig = simple_sig[0:100000] * carrier[0:100000]



fig1, axs1 = plt.subplots(1,1)

# Plot the generated OFDM signal
axs1.plot(np.real(simple_sig),label="Real Part")  # Adjust the portion as needed
axs1.plot(np.imag(simple_sig),label="Imag Part") 
axs1.set_xlabel("Samples")
axs1.set_ylabel("Amplitude")
axs1.legend()
axs1.set_title("Real and Imag parts of upmixed OFDM signal")

plt.tight_layout()
plt.show()


