import numpy as np
import matplotlib.pyplot as plt

def chirp(fs_Hz, rep_Hz, f0_Hz, f1_Hz, periods=1, phase_rad=0):
    T_s = 1 / rep_Hz  # Period of chirp in seconds
    c = (f1_Hz - f0_Hz) / T_s  # Chirp rate in Hz/s
    n = int(fs_Hz / rep_Hz)    # Samples per repetition
    t_s = np.linspace(0, T_s, n, endpoint=False)
    phi_Hz = (c * t_s**2) / 2 + (f0_Hz * t_s)
    phi_rad = 2 * np.pi * phi_Hz + phase_rad
    return np.exp(1j * phi_rad)

# --- Radar parameters ---
fs = 25e6
rep_Hz = 1000
sweep_signal = chirp(fs, rep_Hz, -1e6, 1e6)
samples_per_pulse = len(sweep_signal)
N_pulses = 64
c = 3e8

# Define echoes: (initial_range_m, amplitude, velocity_mps)
# Velocity here is just for updating range per pulse, not direct Doppler phase
echoes = [
    (200.0, 0.8,  5.0),   # moving away
    (400.0, 0.5, -3.0),   # approaching
    (800.0, 0.3,  0.0),   # stationary
]

# Build received data: pulses × samples
rx_data = np.zeros((N_pulses, samples_per_pulse), dtype=complex)

for p in range(N_pulses):
    pulse_return = np.zeros(samples_per_pulse, dtype=complex)
    for r0, amp, vel in echoes:
        # Update range based on velocity and pulse index
        range_m = r0 + vel * (p / rep_Hz)
        delay_s = 2 * range_m / c  # two-way travel time
        delay_samp = int(np.round(delay_s * fs))

        if delay_samp < samples_per_pulse:
            echo_sig = np.concatenate((
                np.zeros(delay_samp, dtype=complex),
                sweep_signal[:samples_per_pulse - delay_samp] * amp
            ))
            pulse_return += echo_sig
    rx_data[p, :] = pulse_return

# --- RANGE–DOPPLER PROCESSING ---
# 1. Range FFT (fast time)
range_profiles = np.fft.fft(rx_data, axis=1)

# 2. Doppler FFT (slow time)
rd_map = np.fft.fftshift(np.fft.fft(range_profiles, axis=0), axes=0)

# Axes for plotting
lambda_radar = c / 10e9  # Assume 10 GHz carrier
doppler_axis = np.fft.fftshift(np.fft.fftfreq(N_pulses, d=1/rep_Hz)) * (lambda_radar / 2)
range_axis = np.arange(samples_per_pulse) * (c / (2 * fs))

# --- PLOT ---
plt.figure(figsize=(10,6))
plt.imshow(
    20*np.log10(np.abs(rd_map.T) + 1e-6),
    extent=[doppler_axis[0], doppler_axis[-1], range_axis[-1], range_axis[0]],
    aspect='auto',
    cmap='jet'
)
plt.colorbar(label='Magnitude (dB)')
plt.xlabel('Velocity (m/s)')
plt.ylabel('Range (m)')
plt.title('Simulated Range–Doppler Map (velocity from motion)')
plt.show()
