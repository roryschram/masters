import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.axes import Axes
from matplotlib.widgets import Button
from scipy import signal
from scipy import interpolate

# === Globals and Constants ===
fs = 25e6
fft_bins = 32768
allCarriers = np.arange(24000)

# Load fixed data
pilot_symbols = np.load("../masters_large_data/final_testing/com_testing/pilot_symbols.npy")
pilot_indices = np.load("../masters_large_data/final_testing/com_testing/pilot_indices.npy")
pilot_indices_shifted = np.load("../masters_large_data/final_testing/com_testing/pilot_indices_shifted.npy")
all_carriers_shifted = np.load("../masters_large_data/final_testing/com_testing/all_carriers_shifted.npy")
bits = np.load("../masters_large_data/final_testing/com_testing/bits.npy")

data_indices = np.setdiff1d(allCarriers, pilot_indices)

mapping_table = {
    (0, 0): -1 - 1j,
    (0, 1): 1 - 1j,
    (1, 0): -1 + 1j,
    (1, 1): 1 + 1j,
}
constellation_points = np.array(list(mapping_table.values()))
demapping_table = {v: k for k, v in mapping_table.items()}

# === Helper Functions ===
def read_complex_data_from_dat(filename):
    with open(filename, 'rb') as f:
        data = f.read()
    double_data = np.frombuffer(data, dtype=np.double)
    complex_data = double_data[0::2] + 1j * double_data[1::2]
    return np.array(complex_data)

def channelEstimate(OFDM_demod):
    pilots = OFDM_demod[pilot_indices]
    Hest_at_pilots = pilots / pilot_symbols
    Hest_abs = interpolate.interp1d(pilot_indices, np.abs(Hest_at_pilots), kind="linear")(allCarriers)
    Hest_phase = interpolate.interp1d(pilot_indices, np.angle(Hest_at_pilots), kind="linear")(allCarriers)
    Hest = Hest_abs * np.exp(1j * Hest_phase)
    return Hest

def equalize(OFDM_demod, Hest):
    return OFDM_demod / Hest

def get_payload(equalized):
    return equalized[data_indices]

def Demapping(QAM):
    constellation = np.array([x for x in demapping_table.keys()])
    dists = abs(QAM.reshape((-1, 1)) - constellation.reshape((1, -1)))
    const_index = dists.argmin(axis=1)
    hardDecision = constellation[const_index]
    return np.vstack([demapping_table[C] for C in hardDecision]), hardDecision

def PS(bits):
    return bits.reshape((-1,))

# === Plotting and Refresh Logic ===
def process_and_plot(axarr):
    received_data = read_complex_data_from_dat("../masters_large_data/received_data/receive.dat")[1000000:]
    transmitted_data = read_complex_data_from_dat("../masters_large_data/transmitted_data/transmit.dat")

    corr = signal.correlate(received_data, transmitted_data)
    corr_abs = np.abs(corr)
    pos_max = np.argmax(corr_abs)
    frame = received_data[pos_max - fft_bins:pos_max]
    frame = frame - np.mean(frame)

    spectrum = np.fft.fftshift(np.fft.fft(frame, n=fft_bins))
    spectrum_magnitude_db = 20 * np.log10(np.abs(spectrum) / len(spectrum))

    signal_bins = all_carriers_shifted
    all_bins = np.arange(fft_bins)
    zero_padding_indices = np.setdiff1d(all_bins, signal_bins)

    received_signal_avg_dBV = np.mean(spectrum_magnitude_db[signal_bins])
    received_noise_avg_dBV = np.mean(spectrum_magnitude_db[zero_padding_indices])
    snr_dB = received_signal_avg_dBV - received_noise_avg_dBV

    temp = spectrum[all_carriers_shifted]
    Hest = channelEstimate(temp)
    equalized_Hest = equalize(temp, Hest)
    QAM_est = get_payload(equalized_Hest)

    PS_est, hardDecision = Demapping(QAM_est)
    bits_est = PS(PS_est)
    ber = np.sum(bits != bits_est) / len(bits) * 100

    print(f"\nSNR: {snr_dB:.2f} dB — BER: {ber:.2f}%")

    # === Plotting ===
    ax = axarr[0]
    ax.clear()
    ax.plot(np.real(received_data), label="Real")
    ax.plot(np.imag(received_data), label="Imag")
    ax.set_title("Raw received signal")
    ax.set_xlabel("Samples")
    ax.set_ylabel("Amplitude")
    ax.legend()

    ax = axarr[1]
    ax.clear()
    ax.plot(corr_abs)
    ax.set_title("Correlation")
    ax.set_xlabel("Samples")

    ax = axarr[2]
    ax.clear()
    ax.plot(corr_abs)
    ax.set_xlim(pos_max - 20, pos_max + 20)
    ax.set_title("Correlation Zoomed")
    ax.set_xlabel("Samples")

    ax = axarr[3]
    ax.clear()
    ax.plot(np.real(frame), label="Real")
    ax.plot(np.imag(frame), label="Imag")
    ax.set_title("Extracted Frame")
    ax.set_xlabel("Samples")
    ax.legend()

    ax = axarr[4]
    ax.clear()
    ax.plot(np.real(spectrum), label="Real")
    ax.plot(np.imag(spectrum), label="Imag")
    ax.set_title("FFT of Frame")
    ax.legend()

    ax = axarr[5]
    ax.clear()
    ax.plot(spectrum_magnitude_db)
    ax.axhline(y=received_signal_avg_dBV, color='red', linestyle='--')
    ax.axhline(y=received_noise_avg_dBV, color='red', linestyle='--')
    ax.set_title("FFT Magnitude (dBV)")

    ax = axarr[6]
    ax.clear()
    ax.plot(Hest)
    ax.set_title("Channel Estimate")

    ax = axarr[7]
    ax.clear()
    ax.plot(QAM_est.real, QAM_est.imag, 'bo', label="Equalized")
    ax.plot(constellation_points.real, constellation_points.imag, 'ro', label="Constellation")
    ax.set_title("Constellation")
    ax.legend()

    plt.draw()

# === Main Interactive Plot ===
fig, axes = plt.subplots(2, 4)
axes = axes.flatten()
fig.set_size_inches(15, 8)
plt.subplots_adjust(bottom=0.15)

refresh_ax = fig.add_axes([0.45, 0.01, 0.1, 0.05])
refresh_button = Button(refresh_ax, 'Refresh')

def on_refresh(event):
    process_and_plot(axes)

refresh_button.on_clicked(on_refresh)

# Initial plot
process_and_plot(axes)
plt.show()
