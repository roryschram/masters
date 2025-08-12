import numpy as np
import matplotlib.pyplot as plt

def chirp(fs_Hz, rep_Hz, f0_Hz, f1_Hz, periods=1, phase_rad=0):
    T_s = 1 / rep_Hz  # Period of chirp in seconds.
    c = (f1_Hz - f0_Hz) / T_s  # Chirp rate in Hz/s.
    n = int(fs_Hz / rep_Hz)  # Samples per repetition.
    t_s = np.linspace(0, T_s, n, endpoint=False)  # Chirp sample times.

    # Instantaneous phase.
    phi_Hz = (c * t_s**2) / 2 + (f0_Hz * t_s)
    phi_rad = 2 * np.pi * phi_Hz + phase_rad
    return np.tile(np.exp(1j * phi_rad), periods)

# Original transmit signal
sweep_signal = chirp(25e6, 1000, -1e6, 1e6)
# Plot
plt.plot(np.real(sweep_signal), label="Real")
plt.plot(np.imag(sweep_signal), label="Imag")
plt.legend()
plt.show()


freqs = np.fft.fftfreq(len(sweep_signal),1/25e6)

# Plot
plt.plot(freqs,np.abs(np.fft.fft(sweep_signal)))
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude")
plt.legend()
plt.show()


# Parameters for simulated echo
delay_samples = 2000    # Number of samples delay
echo_amplitude = 0.5    # Echo strength (attenuation)

# Create delayed echo (zero padding at start)
echo_signal = np.concatenate((
    np.zeros(delay_samples, dtype=complex),
    sweep_signal[:len(sweep_signal)-delay_samples] * echo_amplitude
))

# Add echo to transmit
combined_signal = sweep_signal + echo_signal

# Plot
plt.plot(np.real(combined_signal), label="Real")
plt.plot(np.imag(combined_signal), label="Imag")
plt.legend()
plt.show()


corrolation = np.correlate(combined_signal,sweep_signal, mode="full")

# Plot
plt.plot(np.abs(corrolation))
plt.show()



# Parameters for simulated echo
delay_samples = 2000    # Number of samples delay
echo_amplitude = 0.5    # Echo strength (attenuation)

echoes = np.zeros((20, len(corrolation)),dtype=complex)

for i in range(20):
    # Create delayed echo (zero padding at start)
    echo = np.concatenate((
        np.zeros(delay_samples + 10*i, dtype=complex),
        sweep_signal[:len(sweep_signal)-(delay_samples+10*i)] * echo_amplitude
    ))

    corr = np.correlate(echo,sweep_signal, mode="full")

    echoes[i, :] = corr


# Assuming rx_data is your (10, 49999) complex array with correlation results
rx_data = echoes  # shape (10, 49999)



range_profiles = np.fft.fft(rx_data, axis=1)

# Optionally keep only positive freq bins (physical ranges)
N_fast = range_profiles.shape[1]
range_profiles = range_profiles[:, :N_fast // 2]

# Step 2: Doppler FFT (slow time)
rd_map = np.fft.fftshift(np.fft.fft(range_profiles, axis=0), axes=0)

# Plot Range-Doppler Map
plt.figure(figsize=(12, 6))
plt.imshow(
    20 * np.log10(np.abs(rd_map.T) + 1e-12),
    aspect='auto',
    cmap='jet',
    origin='lower'
)
plt.colorbar(label='Magnitude (dB)')
plt.xlabel('Doppler bin')
plt.ylabel('Range bin')
plt.title('Range-Doppler Map')
plt.show()

















# Take magnitude (absolute value)
magnitude_data = np.abs(rx_data)

# Optionally, convert to dB for better visualization
# magnitude_dB = 20 * np.log10(magnitude_data + 1e-12)
magnitude_dB = magnitude_data

plt.figure(figsize=(12, 6))
plt.imshow(
    magnitude_dB.T,
    aspect='auto',
    cmap='jet',
    origin='lower'
)
plt.colorbar(label='Magnitude (dB)')
plt.xlabel('Pulse number (Slow time)')
plt.ylabel('Range bin (Fast time)')
plt.title('Range-Time Intensity (RTI) Map')
plt.show()