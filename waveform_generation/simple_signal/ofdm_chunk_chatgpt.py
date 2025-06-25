import numpy as np
import matplotlib.pyplot as plt

# === OFDM Parameters ===
bw = 10e6  # Bandwidth = 10 MHz
subcarrier_spacing = 15e3  # 15 kHz LTE spacing
n_subcarriers = 1024  # FFT size
fs = subcarrier_spacing * n_subcarriers  # Sampling rate = 15.36 MHz

cp_len = int(n_subcarriers * 1/8)  # Cyclic Prefix (12.5%)

# === Generate Random QPSK Symbols ===
active_subcarriers = 600  # LTE uses only part of the FFT (guard bands)
data = np.random.choice([1+1j, 1-1j, -1+1j, -1-1j], size=active_subcarriers)

# === Insert into full IFFT bin ===
ifft_input = np.zeros(n_subcarriers, dtype=complex)

# Put data in the center of the IFFT input (Hermitian symmetry not needed for complex data)
start = n_subcarriers//2 - active_subcarriers//2
ifft_input[start:start+active_subcarriers] = data

# === Time Domain OFDM Symbol ===
ofdm_symbol = np.fft.ifft(np.fft.fftshift(ifft_input), n=n_subcarriers)

# === Add Cyclic Prefix ===
ofdm_with_cp = np.concatenate([ofdm_symbol[-cp_len:], ofdm_symbol])

# === Normalize Power ===
ofdm_with_cp /= np.sqrt(np.mean(np.abs(ofdm_with_cp)**2))




# Normalize to avoid clipping or excessive amplitude
normalize_ratio = np.max(np.abs(ofdm_symbol))
ofdm_symbol /= normalize_ratio

# Open a .dat file in binary write mode
with open("../masters_large_data/transmitted_data/transmit.dat", 'wb') as f:
    for sample in ofdm_symbol:
        # Write the real part (I) as 64-bit double
        f.write(np.double(sample.real).tobytes())
        # Write the imaginary part (Q) as 64-bit double
        f.write(np.double(sample.imag).tobytes())





# === Plot Time Domain Signal ===
plt.plot(np.real(ofdm_symbol), label='I (real)')
plt.plot(np.imag(ofdm_symbol), label='Q (imag)')
plt.title("10 MHz OFDM Time Domain Signal")
plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.legend()
plt.grid()
plt.show()

# === Plot Time Domain Signal ===
plt.plot(np.abs(np.fft.fft(ofdm_symbol)), label='I (real)')
plt.title("10 MHz OFDM Time Domain Signal")
plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.legend()
plt.grid()
plt.show()


# === Plot Time Domain Signal ===
plt.plot(np.correlate(ofdm_symbol,ofdm_symbol,mode="full"), label='I (real)')
plt.title("10 MHz OFDM Time Domain Signal")
plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.legend()
plt.grid()
plt.show()

