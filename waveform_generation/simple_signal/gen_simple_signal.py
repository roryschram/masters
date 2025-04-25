import numpy as np
import matplotlib.pyplot as plt

import os

if not os.path.exists("../masters_large_data"):
    os.makedirs("../masters_large_data/")

if not os.path.exists("../masters_large_data/transmitted_data"):
    os.makedirs("../masters_large_data/transmitted_data/")

if not os.path.exists("../masters_large_data/received_data"):
    os.makedirs("../masters_large_data/received_data/")



def gen_simple_signal(sampling_rate, frequency, duration=1.0):
    t = np.arange(0, duration, 1/sampling_rate)
    signal = np.exp(1j * 2 * np.pi * frequency * t)
    return signal

# simple_sig = np.complex128(0)

# for i in range(-1000000,1100000,10000):
#     simple_sig += gen_simple_signal(25000000,i,duration=0.005)



# simple_sig /= np.max(np.abs(simple_sig))
# simple_sig *= 0.005








sampling_rate = 25_000_000  # 25 MHz
duration = 0.04             # 40 ms
fft_size = 500
subcarrier_spacing = 20000  # 15 kHz

# Generate 1024 subcarriers centered around 0 Hz
frequencies = np.linspace(-subcarrier_spacing * fft_size / 2,subcarrier_spacing * (fft_size / 2 - 1) ,fft_size)
frequencies = np.append(frequencies,[5000000])

print(frequencies)

# Initialize signal
simple_sig = np.zeros(int(duration * sampling_rate), dtype=np.complex128)

# Sum the tones
for f in frequencies:
    simple_sig += gen_simple_signal(sampling_rate, f, duration)

# window = np.hanning(len(simple_sig))
# simple_sig *= window

# Normalize to avoid clipping or excessive amplitude
simple_sig /= np.max(np.abs(simple_sig))

print(len(simple_sig))








# Plot the generated sweep signal (showing only a portion for clarity)
plt.plot(np.real(simple_sig),label="Real Part")  # Adjust the portion as needed
plt.plot(np.imag(simple_sig),label="Imag Part") 
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.title("Sweep signal")
plt.show()


# Plot the generated sweep signal (showing only a portion for clarity)
plt.plot(np.fft.fftshift(np.abs(np.fft.fft(simple_sig)))) # Adjust the portion as needed
plt.xlabel("Freq (Hz)")
plt.ylabel("|padded_sweep_signal|")
plt.title("FFT of sweep signal")
plt.show()




# Open a .dat file in binary write mode
with open("../masters_large_data/transmitted_data/transmit.dat", 'wb') as f:
    for sample in simple_sig:
        # Write the real part (I) as 64-bit double
        f.write(np.double(sample.real).tobytes())
        # Write the imaginary part (Q) as 64-bit double
        f.write(np.double(sample.imag).tobytes())


np.save("../masters_large_data/transmitted_data/simple_signal.npy",simple_sig)
print(len(simple_sig))

