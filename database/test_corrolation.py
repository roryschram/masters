import numpy as np
import scipy
import matplotlib.pyplot as plt
import h5py
import scipy.linalg
import scipy.signal


# Read the NumPy array from the HDF5 file
with h5py.File("../database.hdf5", 'r') as hdf5_file:
    capture1 = np.array(hdf5_file["seen_data"]["008"])
    capture2 = np.array(hdf5_file["seen_data"]["009"])
hdf5_file.close()



MSE = np.mean(np.abs(capture1-capture2) ** 2)
print("Mean Squared Error: ",MSE)


# frequencies, MSC_values = scipy.signal.coherence(capture1,capture2)

# MSC_score = np.mean(MSC_values)
# print("Overall MSC similarity: ",MSC_score)



# matched_filter_output = scipy.signal.correlate(capture1,capture2)

# norm_capture1 = scipy.linalg.norm(capture1)
# norm_capture2 = scipy.linalg.norm(capture2)

# normalized_corrolation = np.abs(matched_filter_output) / (norm_capture1*norm_capture2)

# lags = np.arange(-len(capture1)+1,len(capture2))
# # plt.plot(lags,normalized_corrolation)
# plt.plot(matched_filter_output)
# plt.title("Normalized crosscorrolation")
# plt.xlabel("Lag (freq shift)")
# plt.ylabel("corrolation magnitude")
# plt.show()
