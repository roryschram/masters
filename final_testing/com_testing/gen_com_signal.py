"""
===============================================================================
Script Name   : gen_com_signal.py
Author        : Rory Schram

Description   : 
    This script generates an OFDM based signal based on the given input parameters


===============================================================================
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.axes import Axes



# Input parameters
fs = 25e6
n_subcarriers = 32768  # FFT size
active_subcarriers = 24000
n_pilots = 4000
n_data = active_subcarriers - n_pilots



all_carriers = np.arange(active_subcarriers)
subcarrier_spacing = fs/n_subcarriers



# Print information about the signal
print("=== Signal Configuration ===")
print(f"Sampling rate           : {fs/1e6:.2f} MHz")
print(f"FFT size                : {n_subcarriers}")
print(f"Active subcarriers      : {active_subcarriers}")
print(f"Number of Pilots        : {n_pilots}")
print(f"Subcarrier spacing      : {subcarrier_spacing:.4f} Hz")
print(f"Active Signal bandwidth : {((subcarrier_spacing*active_subcarriers)/1e6):.2f} MHz")
print("Encoding                : 4-QAM")
print("============================")




# Number of bits per carrier => essentially governs QAM encoding
mu = 2
payloadBits_per_OFDM = n_data*mu

# 16 QAM mapping table
mapping_table = {
    (0,0) : -1-1j,
    (0,1) :  1-1j,
    (1,0) : -1+1j,
    (1,1) :  1+1j,
}




fig , axes = plt.subplots(2,2)
axes = axes.flatten()


ax:Axes = axes[0]
for b1 in [0, 1]:
    for b0 in [0, 1]:
        B = (b1, b0)
        Q = mapping_table[B]
        ax.plot(Q.real, Q.imag, 'bo')
        ax.text(Q.real, Q.imag+0.2, "".join(str(x) for x in B), ha='center')
ax.set_title("4 QAM Constellation Mapping")
ax.set_xlabel("Real Part (I)")
ax.set_ylabel("Imaginary Part (Q)")
ax.set_ylim(-2,2)
ax.set_xlim(-2,2)
ax.grid()







fig.set_size_inches(15,8)
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


pilots_choice = [-1-1j, 1-1j,-1+1j, 1+1j]
# === Generate pilot and data symbols ===
pilot_symbols = np.random.choice(pilots_choice, size=n_pilots, replace=True)  # BPSK pilots
# data_symbols = np.random.choice([1+1j, 1-1j, -1+1j, -1-1j], size=n_data)  # QPSK data
data_symbols = QAM

# === Insert pilots evenly across the 600 active subcarriers ===
ofdm_symbols = np.zeros(active_subcarriers, dtype=complex)
pilot_indices = np.round(np.linspace(0, active_subcarriers - 1, n_pilots)).astype(int)
data_iter = iter(data_symbols)

print("Pilot Indices:")
print(pilot_indices)
np.save("../masters_large_data/final_testing/com_testing/pilot_indices.npy",pilot_indices)

for i in range(active_subcarriers):
    if i in pilot_indices:
        ofdm_symbols[i] = pilot_symbols[np.where(pilot_indices == i)[0][0]]
    else:
        ofdm_symbols[i] = next(data_iter)




# ofdm_symbols = np.pad(ofdm_symbols,(175,175),mode="constant")
np.save("../masters_large_data/final_testing/com_testing/pilot_symbols.npy",pilot_symbols)




# === Time Domain OFDM Symbol ===
pad_amount = (n_subcarriers-active_subcarriers)//2
print("Pad amount: "+str(pad_amount))
ofdm_symbol = np.pad(ofdm_symbols,(pad_amount,pad_amount),mode="constant",constant_values=0+0j)
pilot_indices_shifted = pilot_indices + pad_amount
all_carriers_shifted = all_carriers + pad_amount
np.save("../masters_large_data/final_testing/com_testing/all_carriers_shifted.npy",all_carriers_shifted)
np.save("../masters_large_data/final_testing/com_testing/pilot_indices_shifted.npy",pilot_indices_shifted)


plt.plot(np.abs(ofdm_symbol))
plt.title("Full symbol in frequency domain")
plt.xlabel("Frequency bins")
plt.ylabel("Value")
for bin_idx in pilot_indices_shifted:
    plt.axvline(x=bin_idx, color='red', linestyle='--', linewidth=0.5, alpha=0.7)
plt.show()


ofdm_symbol_time = np.fft.ifft(np.fft.fftshift(ofdm_symbol))

plt.plot(np.real(ofdm_symbol_time))
plt.plot(np.imag(ofdm_symbol_time))
plt.show()

# === Normalize ===
ofdm_symbol_time /= np.max(np.abs(ofdm_symbol_time))  # Avoid clipping


# === Compute FFT of the OFDM signal (with CP) ===
# n_fft_plot = n_subcarriers  # Use zero-padding for better resolution
spectrum = np.fft.fftshift(np.fft.fft(ofdm_symbol_time))
spectrum_magnitude_db = 20 * np.log10(np.abs(spectrum) + 1e-12)  # avoid log(0)



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
plt.plot(np.real(ofdm_symbol_time), label='I (real)')
plt.plot(np.imag(ofdm_symbol_time), label='Q (imag)')
plt.title("18 MHz OFDM Time Domain Signal")
plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.legend()
plt.grid()
plt.show()



# === Plot Time Domain Signal ===
# plt.figure(figsize=(10, 4))
plt.plot(np.abs(np.correlate(ofdm_symbol_time,ofdm_symbol_time,mode="full")))
plt.title("Auto correlation of OFDM symbol")
plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.grid()
plt.show()

# Open a .dat file in binary write mode
with open("../masters_large_data/transmitted_data/transmit.dat", 'wb') as f:
    for sample in ofdm_symbol_time:
        # Write the real part (I) as 64-bit double
        f.write(np.double(sample.real).tobytes())
        # Write the imaginary part (Q) as 64-bit double
        f.write(np.double(sample.imag).tobytes())

