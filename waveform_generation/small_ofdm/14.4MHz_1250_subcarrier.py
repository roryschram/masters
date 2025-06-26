import numpy as np
import matplotlib.pyplot as plt


# === OFDM Parameters ===
bw = 14.4e6  # Bandwidth = 10 MHz
subcarrier_spacing = 16e3  # 15 kHz LTE spacing
n_subcarriers = 1250  # FFT size
fs = subcarrier_spacing * n_subcarriers  # Sampling rate = 15.36 MHz fs => 20MHz
cp_len = int(n_subcarriers * 1/8)  # Cyclic Prefix (12.5%)

# === Data and Pilot Parameters ===
active_subcarriers = 900
n_pilots = 75
n_data = active_subcarriers - n_pilots

# === Generate pilot and data symbols ===
pilot_symbols = np.random.choice([1+1j, 1+1j], size=n_pilots)  # BPSK pilots
data_symbols = np.random.choice([1+1j, 1-1j, -1+1j, -1-1j], size=n_data)  # QPSK data

# === Insert pilots evenly across the 600 active subcarriers ===
ofdm_symbols = np.zeros(active_subcarriers, dtype=complex)
pilot_indices = np.round(np.linspace(0, active_subcarriers - 1, n_pilots)).astype(int)
data_iter = iter(data_symbols)

for i in range(active_subcarriers):
    if i in pilot_indices:
        ofdm_symbols[i] = pilot_symbols[np.where(pilot_indices == i)[0][0]]
    else:
        ofdm_symbols[i] = next(data_iter)

# === Map to full IFFT input (zero out DC) ===
ifft_input = np.zeros(n_subcarriers, dtype=complex)
half = active_subcarriers // 2
ifft_input[1:1+half] = ofdm_symbols[:half]          # Positive freqs
ifft_input[-half:] = ofdm_symbols[half:]            # Negative freqs

# === Time Domain OFDM Symbol ===
ofdm_symbol = np.fft.ifft((ifft_input), n=n_subcarriers)

# # === Add Cyclic Prefix ===
# ofdm_with_cp = np.concatenate([ofdm_symbol[-cp_len:], ofdm_symbol])

# === Normalize ===
ofdm_symbol -= np.mean(ofdm_symbol)  # Remove any DC offset
ofdm_symbol /= np.max(np.abs(ofdm_symbol)) * 1.1  # Avoid clipping


# === Compute FFT of the OFDM signal (with CP) ===
n_fft_plot = 4096  # Use zero-padding for better resolution
spectrum = np.fft.fftshift(np.fft.fft(ofdm_symbol, n=n_fft_plot))
spectrum_magnitude_db = 20 * np.log10(np.abs(spectrum) + 1e-12)  # avoid log(0)

# Frequency axis in MHz
freq_axis = np.linspace(-fs/2, fs/2, n_fft_plot) / 1e6

# === Plot Spectrum ===
plt.figure(figsize=(10, 4))
plt.plot(freq_axis, spectrum_magnitude_db)
plt.title("FFT of OFDM Signal (Magnitude Spectrum)")
plt.xlabel("Frequency (MHz)")
plt.ylabel("Magnitude (dB)")
plt.grid()
plt.ylim(-100,50)
plt.tight_layout()
plt.show()


# # Normalize to avoid clipping or excessive amplitude
# normalize_ratio = np.max(np.abs(ofdm_symbol))
# ofdm_symbol /= normalize_ratio

# Open a .dat file in binary write mode
with open("../masters_large_data/transmitted_data/transmit.dat", 'wb') as f:
    for sample in ofdm_symbol:
        # Write the real part (I) as 64-bit double
        f.write(np.double(sample.real).tobytes())
        # Write the imaginary part (Q) as 64-bit double
        f.write(np.double(sample.imag).tobytes())





# === Plot Time Domain Signal ===
plt.figure(figsize=(10, 4))
plt.plot(np.real(ofdm_symbol), label='I (real)')
plt.plot(np.imag(ofdm_symbol), label='Q (imag)')
plt.title("10 MHz OFDM Time Domain Signal")
plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.legend()
plt.grid()
plt.show()

# === Plot Time Domain Signal ===
plt.figure(figsize=(10, 4))
freqs = np.fft.fftfreq(len(ofdm_symbol))
plt.plot(freqs, np.fft.fft(ofdm_symbol))
plt.title("FFT of OFDM Time Domain Signal")
plt.xlabel("Freq (Hz)")
plt.ylabel("Amplitude")
plt.legend()
plt.grid()
plt.show()


# === Plot Time Domain Signal ===
plt.figure(figsize=(10, 4))
plt.plot(np.correlate(ofdm_symbol,ofdm_symbol,mode="full"), label='I (real)')
plt.title("10 MHz OFDM Time Domain Signal")
plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.legend()
plt.grid()
plt.show()

