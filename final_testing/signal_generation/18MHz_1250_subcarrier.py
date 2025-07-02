import numpy as np
import matplotlib.pyplot as plt



'''
Below is my offcial code to generate an OFDM like waveform that has 1250 carriers spaced over 18MHz of spectrum.

'''



# Parameters of the OFDM signal
bw = 18e6  # Bandwidth = 10 MHz
subcarrier_spacing = 20e3  # 15 kHz LTE spacing
n_subcarriers = 1250  # FFT size
fs = subcarrier_spacing * n_subcarriers  # Sampling rate fs => 16.66666667MHz

# Here I define the number of active subcarriers and pilots
active_subcarriers = 900
n_pilots = 75
n_data = active_subcarriers - n_pilots


# Now I define the bits per symbol, mu. In this case it is 4 -> 16 QAM
mu = 4
payloadBits_per_OFDM = n_data*mu  # number of payload bits per OFDM symbol

# 16 QAM mapping table
mapping_table = {
    (0,0,0,0) : -3-3j,
    (0,0,0,1) : -3-1j,
    (0,0,1,0) : -3+3j,
    (0,0,1,1) : -3+1j,
    (0,1,0,0) : -1-3j,
    (0,1,0,1) : -1-1j,
    (0,1,1,0) : -1+3j,
    (0,1,1,1) : -1+1j,
    (1,0,0,0) :  3-3j,
    (1,0,0,1) :  3-1j,
    (1,0,1,0) :  3+3j,
    (1,0,1,1) :  3+1j,
    (1,1,0,0) :  1-3j,
    (1,1,0,1) :  1-1j,
    (1,1,1,0) :  1+3j,
    (1,1,1,1) :  1+1j
}

for b3 in [0, 1]:
    for b2 in [0, 1]:
        for b1 in [0, 1]:
            for b0 in [0, 1]:
                B = (b3, b2, b1, b0)
                Q = mapping_table[B]
                plt.plot(Q.real, Q.imag, 'bo')
                plt.text(Q.real, Q.imag+0.2, "".join(str(x) for x in B), ha='center')


plt.title("16 QAM Constellation with Grey-Mapping")
plt.xlabel("Real Part (I)")
plt.ylabel("Imaginary Part (Q)")
plt.ylim(-4,4)
plt.xlim(-4,4)
plt.grid()
plt.show()



# Generate and save random bits of length n_data*4 = 3300
bits = np.random.binomial(n=1, p=0.5, size=(payloadBits_per_OFDM, ))
np.save("../masters_large_data/final_testing/com_testing/bits.npy",bits)



print ("Bits count: ", len(bits))
print ("First 20 bits: ", bits[:20])
print ("Mean of bits (should be around 0.5): ", np.mean(bits))


def SP(bits):
    return bits.reshape((n_data, mu))
bits_SP = SP(bits)


def Mapping(bits):
    return np.array([mapping_table[tuple(b)] for b in bits])
QAM = Mapping(bits_SP)

print ("First 5 QAM symbols and bits:")
print (bits_SP[:5,:])
print (QAM[:5])


pilots_choice = [-3-3j,-3-1j,-3+3j,-3+1j,-1-3j,-1-1j,-1+3j,-1+1j, 3-3j, 3-1j, 3+3j, 3+1j, 1-3j, 1-1j, 1+3j, 1+1j]


# === Generate pilot and data symbols ===
pilot_symbols = np.random.choice(pilots_choice, size=n_pilots, replace=True)  # BPSK pilots
# data_symbols = np.random.choice([1+1j, 1-1j, -1+1j, -1-1j], size=n_data)  # QPSK data
data_symbols = QAM

# === Insert pilots evenly across the 600 active subcarriers ===
ofdm_symbols = np.zeros(active_subcarriers, dtype=complex)
pilot_indices = np.round(np.linspace(0, active_subcarriers - 1, n_pilots)).astype(int)
data_iter = iter(data_symbols)

print(pilot_indices)

for i in range(active_subcarriers):
    if i in pilot_indices:
        ofdm_symbols[i] = pilot_symbols[np.where(pilot_indices == i)[0][0]]
    else:
        ofdm_symbols[i] = next(data_iter)



pilot_indices_shifted = pilot_indices + 175
ofdm_symbols = np.pad(ofdm_symbols,(175,175),mode="constant")

np.save("../masters_large_data/final_testing/com_testing/pilot_indices_shifted.npy",pilot_indices_shifted)
np.save("../masters_large_data/final_testing/com_testing/pilot_symbols.npy",pilot_symbols)




plt.plot(np.abs(ofdm_symbols))
plt.title("Full symbol in frequency domain")
plt.xlabel("Frequency bins")
plt.ylabel("Value")
for bin_idx in pilot_indices_shifted:
    plt.axvline(x=bin_idx, color='red', linestyle='--', linewidth=0.5, alpha=0.7)
plt.show()


# === Time Domain OFDM Symbol ===
ofdm_symbol = np.fft.ifft(np.fft.fftshift(ofdm_symbols), n=n_subcarriers)


# === Normalize ===
ofdm_symbol /= np.max(np.abs(ofdm_symbol))  # Avoid clipping


# === Compute FFT of the OFDM signal (with CP) ===
n_fft_plot = 1250  # Use zero-padding for better resolution
spectrum = np.fft.fftshift(np.fft.fft(ofdm_symbol, n=n_fft_plot))
spectrum_magnitude_db = 20 * np.log10(np.abs(spectrum) + 1e-12)  # avoid log(0)

# Frequency axis in MHz
freq_axis = np.linspace(-fs/2, fs/2, n_fft_plot) / 1e6

# === Plot Spectrum ===
# plt.figure(figsize=(10, 4))
plt.plot(spectrum_magnitude_db)
plt.title("FFT of OFDM Signal (Magnitude Spectrum)")
plt.xlabel("Frequency bins")
plt.ylabel("Magnitude (dB)")
plt.grid()
# plt.ylim(-100,50)

for bin_idx in pilot_indices_shifted:
    plt.axvline(x=bin_idx, color='red', linestyle='--', linewidth=0.5, alpha=0.7)

plt.tight_layout()
plt.show()


# === Plot Time Domain Signal ===
# plt.figure(figsize=(10, 4))
plt.plot(np.real(ofdm_symbol), label='I (real)')
plt.plot(np.imag(ofdm_symbol), label='Q (imag)')
plt.title("18 MHz OFDM Time Domain Signal")
plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.legend()
plt.grid()
plt.show()



# === Plot Time Domain Signal ===
# plt.figure(figsize=(10, 4))
plt.plot(np.abs(np.correlate(ofdm_symbol,ofdm_symbol,mode="full")))
plt.title("Auto correlation of OFDM symbol")
plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.grid()
plt.show()

# Open a .dat file in binary write mode
with open("../masters_large_data/transmitted_data/transmit.dat", 'wb') as f:
    for sample in ofdm_symbol:
        # Write the real part (I) as 64-bit double
        f.write(np.double(sample.real).tobytes())
        # Write the imaginary part (Q) as 64-bit double
        f.write(np.double(sample.imag).tobytes())

