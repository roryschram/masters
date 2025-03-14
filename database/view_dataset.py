import numpy as np
import scipy
import matplotlib.pyplot as plt
import h5py
import scipy.linalg
import scipy.signal


# Read the NumPy array from the HDF5 file
with h5py.File("../database.hdf5", 'r') as hdf5_file:
    capture1 = np.array(hdf5_file["seen_data"]["002"])
hdf5_file.close()


plt.plot(np.abs(np.fft.fftshift(capture1)))
plt.show()