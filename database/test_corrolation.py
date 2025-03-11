import numpy as np
import scipy
import matplotlib.pyplot as plt
import h5py



# Read the NumPy array from the HDF5 file
with h5py.File("../database.hdf5", 'r') as hdf5_file:
    capture1 = np.array(hdf5_file["seen_data"]["001"])
    capture2 = np.array(hdf5_file["seen_data"]["015"])
hdf5_file.close()

def similarity_percentage(x, y):
    # Compute cross-correlation
    correlation = scipy.signal.correlate(x, y)
    
    # Compute normalized cross-correlation (NCC)
    similarity = np.max(np.abs(correlation)) / np.sqrt(np.sum(np.abs(x) ** 2) * np.sum(np.abs(y) ** 2))
    
    return similarity * 100  # Convert to percentage

similarity_score = similarity_percentage(capture1, capture2)
print(f"Signal Similarity: {similarity_score:.5f}%")


# # Trying to compute corrolation power
# # Compute cross-correlation
# correlation = scipy.signal.correlate(capture1, capture2)

# # Compute power of the correlation (sum of squared values)
# correlation_power = np.sum(correlation**2)

# # Alternatively, normalize by signal length for average power
# normalized_power = np.mean(correlation**2)

# print(f"Correlation Power: {correlation_power}")
# print(f"Normalized Correlation Power: {normalized_power}")


# MSE = np.mean(np.abs(capture1-capture2) ** 2)
# print("Mean Squared Error: ",MSE)


# frequencies, MSC_values = scipy.signal.coherence(capture1,capture2)

# MSC_score = np.mean(MSC_values)
# print("Overall MSC similarity: ",MSC_score)



# matched_filter_output = scipy.signal.correlate(capture1,capture2)

# norm_capture1 = scipy.linalg.norm(capture1)
# norm_capture2 = scipy.linalg.norm(capture2)

# normalized_corrolation = np.abs(matched_filter_output) / (norm_capture1*norm_capture2)

# lags = np.arange(-len(capture1)+1,len(capture2))
# plt.plot(lags,normalized_corrolation)
# # plt.plot(matched_filter_output)
# plt.title("Normalized crosscorrolation")
# plt.xlabel("Lag (freq shift)")
# plt.ylabel("corrolation magnitude")
# plt.show()
