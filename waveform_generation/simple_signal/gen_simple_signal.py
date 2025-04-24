import numpy as np
import matplotlib.pyplot as plt

import os

if not os.path.exists("../masters_large_data"):
    os.makedirs("../masters_large_data/")

if not os.path.exists("../masters_large_data/transmitted_data"):
    os.makedirs("../masters_large_data/transmitted_data/")

if not os.path.exists("../masters_large_data/received_data"):
    os.makedirs("../masters_large_data/received_data/")



# def gen_simple_signal(sampling_rate, frequency, duration=1.0):
#     t = np.arange(0, duration, 1/sampling_rate)
#     signal = np.exp(1j * 2 * np.pi * frequency * t)
#     return signal

# simple_sig = np.complex128(0)

# for i in range(-4000000,4010000,100000):
#     simple_sig += gen_simple_signal(10000000,i,duration=0.1)


def gen_random_complex_signal(length):
    real_part = 2 * np.random.rand(length) - 1   # Uniform in [-1, 1]
    imag_part = 2 * np.random.rand(length) - 1   # Uniform in [-1, 1]
    return real_part + 1j * imag_part


def gen_ofdm_2048_10MHz(data_symbols, cp_len=0):
    Nfft = 2048
    # generate mapping: use all bins 0…2047
    subcarriers = np.arange(Nfft)
    # put your QAM/PSK symbols on every bin
    X = np.zeros(Nfft, dtype=complex)
    X[subcarriers] = data_symbols   # data_symbols must be length 2048
    # IFFT → time domain
    x = np.fft.ifft(X, n=Nfft)
    # optional cyclic prefix
    if cp_len > 0:
        x = np.hstack([x[-cp_len:], x])
    return x, 10e6, 10e6/Nfft   # returns (time_signal, sample_rate, subcarrier_spacing)



# Example: generate 1024 complex samples
rand = gen_random_complex_signal(2048)

simple_sig = gen_ofdm_2048_10MHz(rand)

simple_sig = simple_sig[0]


simple_sig /= np.max(np.abs(simple_sig))
# simple_sig *= 0.005










# Plot the generated sweep signal (showing only a portion for clarity)
plt.plot(np.real(simple_sig),label="Real Part")  # Adjust the portion as needed
plt.plot(np.imag(simple_sig),label="Imag Part") 
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.title("Sweep signal")
plt.show()


freqs = np.fft.fftfreq(len(simple_sig),d=1/10e6)

# Plot the generated sweep signal (showing only a portion for clarity)
plt.plot(freqs, np.abs(np.fft.fft(simple_sig))/len(simple_sig)) # Adjust the portion as needed
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

