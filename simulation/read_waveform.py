import h5py
import numpy as np
import matplotlib.pyplot as plt
import scipy
import scipy.signal

def load_chunks_from_h5(filename):
    # Open the HDF5 file
    with h5py.File(filename, 'r') as f:
        I_data = []  # List to store all I components
        Q_data = []  # List to store all Q components
        attrs = dict(f["/chunk_000000_I"].attrs)  # Get all attributes as a dictionary
        scale = attrs.get("fullscale")
        
        # Iterate through all keys in the file (which are chunk names)
        for chunk_name in f.keys():
            # Check if the chunk is I or Q
            if '_I' in chunk_name:
                I_data.append(f[chunk_name][:])  # Read I chunk data
            elif '_Q' in chunk_name:
                Q_data.append(f[chunk_name][:])  # Read Q chunk data
        
        # Convert the lists to numpy arrays (concatenate all chunks)
        I_array = np.concatenate(I_data) if I_data else np.array([])
        Q_array = np.concatenate(Q_data) if Q_data else np.array([])
        
    f.close()
    return I_array, Q_array, scale

# Example usage
filename = 'simulation/Monostatic.h5'  # Your HDF5 file
I_array, Q_array, scale= load_chunks_from_h5(filename)


sig = np.load("simulation/chirp_signal.npy")
received = (I_array + 1j*Q_array)*scale

print("Length of sig: "+str(len(sig)))
print("Length of received: "+str(len(received)))


matched_output = scipy.signal.correlate(sig,received)
# Plot the chirp signal
plt.plot(np.abs(matched_output))
# plt.xlabel('Time (s)')
# plt.ylabel('Amplitude')
plt.show()