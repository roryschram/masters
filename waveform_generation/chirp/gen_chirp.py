import numpy as np
import matplotlib.pyplot as plt

import os

if not os.path.exists("../masters_large_data"):
    os.makedirs("../masters_large_data/")

if not os.path.exists("../masters_large_data/transmitted_data"):
    os.makedirs("../masters_large_data/transmitted_data/")

if not os.path.exists("../masters_large_data/received_data"):
    os.makedirs("../masters_large_data/received_data/")



# chirp
#
# Generate a frequency sweep from low to high over time.
# Waveform description is based on number of samples.
#
# Inputs
#  fs_Hz: float, sample rate of chirp signal.
#  rep_Hz: float, repetitions per second of chirp.
#  f0_Hz: float, start (lower) frequency in Hz of chirp.
#  f1_Hz: float, stop (upper) frequency in Hz of chirp.
#  phase_rad: float, phase in radians at waveform start, default is 0.
#
# Output
#  Time domain chirp waveform of length numnSamples.

def chirp(fs_Hz, rep_Hz, f0_Hz, f1_Hz, periods=1, phase_rad=0):

    T_s = 1 / rep_Hz # Period of chirp in seconds.
    c = (f1_Hz - f0_Hz) / T_s # Chirp rate in Hz/s.
    n = int(fs_Hz / rep_Hz) # Samples per repetition.
    t_s = np.linspace(0, T_s, n) # Chirp sample times.

    # Phase, phi_Hz, is integral of frequency, f(t) = ct + f0.
    phi_Hz = (c * t_s**2) / 2 + (f0_Hz * t_s) # Instantaneous phase.
    phi_rad = 2 * np.pi * phi_Hz # Convert to radians.
    phi_rad += phase_rad # Offset by user-specified initial phase.
    return np.tile(np.exp(1j * phi_rad), periods) # Complex I/Q.

sweep_signal = chirp(5e6,100,-2.5e6,2.5e6)


padded_sweep_signal = np.pad(sweep_signal, pad_width=(5000,1000), mode="constant", constant_values=0+0j)
#padded_sweep_signal = sweep_signal


# Plot the generated sweep signal (showing only a portion for clarity)
plt.plot(np.real(padded_sweep_signal),label="Real Part")  # Adjust the portion as needed
plt.plot(np.imag(padded_sweep_signal),label="Imag Part") 
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.title("Sweep signal")
plt.show()


freqs = np.fft.fftshift(np.fft.fftfreq(len(padded_sweep_signal),1/12.5e6))

# Plot the generated sweep signal (showing only a portion for clarity)
plt.plot(freqs,np.fft.fftshift(np.abs(np.fft.fft(padded_sweep_signal))/len(padded_sweep_signal))) # Adjust the portion as needed
plt.xlabel("Freq (Hz)")
plt.ylabel("|padded_sweep_signal|")
plt.title("FFT of sweep signal")
plt.show()



# Open a .dat file in binary write mode
with open("../masters_large_data/transmitted_data/transmit.dat", 'wb') as f:
    for sample in sweep_signal:
        # Write the real part (I) as 64-bit double
        f.write(np.double(sample.real).tobytes())
        # Write the imaginary part (Q) as 64-bit double
        f.write(np.double(sample.imag).tobytes())


np.save("../masters_large_data/transmitted_data/sweep_signal.npy",sweep_signal)
np.save("../masters_large_data/transmitted_data/padded_sweep_signal.npy",padded_sweep_signal)

print("RAW Chrip Signal Length: "+str(len(sweep_signal)))


