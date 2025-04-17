import matplotlib.pyplot as plt
plt.rcParams['figure.figsize'] = (10, 4)
plt.rcParams['figure.dpi'] = 300

import numpy as np
import scipy
import h5py

import glob

from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from scipy.signal import decimate


arrays = []

for i in range(1,21):
    print("Reading channel estimation "+str(i))
    filename = "../masters_large_data/received_data/multi_receive/channel_estimations/channel_est"+str(i)+".npy"
    arr = np.load(filename)
    arr = np.abs(arr)
    arrays.append(arr)


# print(arrays)

# for i in range(0,20):
#     plt.plot(arrays[i])

# plt.show()



# Parameters
num_captures = 20
window_size = 12500000  # We'll use the first 8192 samples of each


# X = []

# # Extract FFT magnitude features from each variable
# for i in range(1, num_captures + 1):
#     capture = globals()[f"capture{i}"][:window_size]  # Access variable by name
#     # Downsample to 12.5k samples
#     downsample_factor = 25000
#     capture_ds = decimate(capture, downsample_factor)

#     X.append(capture_ds)

X = np.array(arrays)


# Standardize features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Apply PCA
pca = PCA(n_components=3)
X_pca = pca.fit_transform(X_scaled)

print(pca.explained_variance_ratio_)

# Plotting
fig = plt.figure(figsize=(10,4))
ax = fig.add_subplot(111,projection='3d')


for i in range(len(X_pca)):
    ax.scatter(X_pca[i, 0], X_pca[i, 1], X_pca[i, 2])  # Avoid repeated labels

ax.set_xlabel('PC1')
ax.set_ylabel('PC2')
ax.set_zlabel('PC3')
ax.set_title("PCA of Channel Estimations")
# ax.view_init(elev=, azim=0)  # ← change perspective to top-down
ax.legend()
ax.legend(loc='center left', bbox_to_anchor=(1.05, 0.5))
plt.show()