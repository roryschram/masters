import numpy as np
import matplotlib.pyplot as plt
import h5py

def generate_complex_chirp(start_freq, end_freq, sample_rate, duration):
    # Time array from 0 to duration with sample_rate samples per second
    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    
    # Chirp signal (linear frequency modulation)
    # Real part (I) of the chirp
    I_chirp = np.cos(2 * np.pi * (start_freq * t + (end_freq - start_freq) / (2 * duration) * t**2))
    
    # Imaginary part (Q) of the chirp
    Q_chirp = np.sin(2 * np.pi * (start_freq * t + (end_freq - start_freq) / (2 * duration) * t**2))
    
    # Combine I and Q into a complex chirp
    complex_chirp = I_chirp + 1j * Q_chirp
    
    return t, complex_chirp

def save_chirp_to_h5(filename, start_freq, end_freq, sample_rate, duration):
    # Generate chirp signal
    t, chirp_signal = generate_complex_chirp(start_freq, end_freq, sample_rate, duration)
    
    # Create the HDF5 file
    with h5py.File("simulation/"+filename, 'w') as f:
        # Create groups 'I' and 'Q'
        group_I = f.create_group('I')
        group_Q = f.create_group('Q')
        
        # Save the chirp signal as the 'value' dataset in both groups
        group_I.create_dataset('value', data=np.real(chirp_signal))  # Real part (I)
        group_Q.create_dataset('value', data=np.imag(chirp_signal))  # Imaginary part (Q), set to zero
    f.close()

    return t,chirp_signal


# Example parameters
start_freq = -6.25e6    # Start frequency in Hz
end_freq = 6.25e6      # End frequency in Hz
sample_rate = 12.5e6 # Sample rate in samples per second (Hz)
duration = 0.000001         # Duration of chirp in seconds


# Save the chirp signal to an HDF5 file
t,chirp_signal = save_chirp_to_h5('chirp.h5', start_freq, end_freq, sample_rate, duration)

np.save("simulation/chirp_signal.npy",chirp_signal)


# Plot the chirp signal
plt.plot(t, chirp_signal)
plt.title(f'Chirp Signal from {start_freq}Hz to {end_freq}Hz')
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.show()
