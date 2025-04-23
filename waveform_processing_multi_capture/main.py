import matplotlib.pyplot as plt
# plt.rcParams['figure.figsize'] = (10, 4)
# plt.rcParams['figure.dpi'] = 300
import matplotlib
matplotlib.use('TkAgg')

import numpy as np
import scipy
import h5py

import glob

from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from scipy.signal import decimate
from sklearn.svm import SVC
from sklearn.preprocessing import LabelEncoder

from scipy.signal import decimate


arrays = []

for i in range(1,41):
    print("Reading channel estimation "+str(i))
    filename = "../masters_large_data/received_data/multi_receive/channel_estimations/channel_est"+str(i)+".npy"
    arr = np.fft.fftshift(np.abs(np.load(filename)))
    # downsample_factor = 2500
    # capture_ds = decimate(arr, downsample_factor)
    arrays.append(arr)


X = np.array(arrays)


# Standardize features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Apply PCA
pca = PCA(n_components=10)
X_pca = pca.fit_transform(X_scaled)


rTotalVariance = 0
for i in pca.explained_variance_ratio_:
    rTotalVariance += i
    print(i)
print("Total variance ratio addition: "+str(rTotalVariance))


# Plotting

# # # Define labels for each point
# # labels = ['30 dB'] * 10 + ['40 dB'] * 10
# # colors = {'30 dB': 'red', '40 dB': 'blue'}


# Define labels for each point
labels = (
    ['60 dB'] * 10 + 
    ['50 dB'] * 10 + 
    ['40 dB'] * 10 + 
    ['30 dB'] * 10
)
colors = {'60 dB': 'red', '50 dB': 'blue', '40 dB': 'green', '30 dB': 'gray'}



fig = plt.figure(figsize=(10, 8))
ax = fig.add_subplot(111, projection='3d')

# Scatter actual data points
for i in range(len(X_pca)):
    ax.scatter(X_pca[i, 0], X_pca[i, 1], X_pca[i, 2],
               color=colors[labels[i]],
               label=labels[i] if i in [0, 10, 20, 30] else "")
    ax.text(X_pca[i, 0], X_pca[i, 1], X_pca[i, 2], str(i + 1), fontsize=8)

ax.set_xlabel('PC1')
ax.set_ylabel('PC2')
ax.set_zlabel('PC3')
ax.set_title('PCA in 3D PCA Space')
ax.legend()
plt.tight_layout()
plt.show()












# le = LabelEncoder()
# y_encoded = le.fit_transform(labels)  # 40 dB = 0, 30 dB = 1
# print(y_encoded)

# # Train SVM
# svm = SVC(kernel='rbf', gamma='scale', C=1.0)
# svm.fit(X_pca[:, :3], y_encoded)  # Use first 10 PCs



# # Create 3D grid
# grid_size = 30  # finer = slower
# x_min, x_max = X_pca[:, 0].min() - 1, X_pca[:, 0].max() + 1
# y_min, y_max = X_pca[:, 1].min() - 1, X_pca[:, 1].max() + 1
# z_min, z_max = X_pca[:, 2].min() - 1, X_pca[:, 2].max() + 1

# xx, yy, zz = np.meshgrid(
#     np.linspace(x_min, x_max, grid_size),
#     np.linspace(y_min, y_max, grid_size),
#     np.linspace(z_min, z_max, grid_size)
# )

# grid = np.c_[xx.ravel(), yy.ravel(), zz.ravel()]
# decision = svm.decision_function(grid)
# decision = decision.reshape(xx.shape)

# slice_idx = grid_size // 2  # middle slice along z-axis

# fig = plt.figure(figsize=(10, 8))
# ax = fig.add_subplot(111, projection='3d')

# # # Plot decision boundary on a Z slice
# # ax.contour(xx[:, :, slice_idx], yy[:, :, slice_idx], decision[:, :, slice_idx],
# #            levels=[0], colors='gray', linewidths=2)

# # Scatter actual data points
# for i in range(len(X_pca)):
#     ax.scatter(X_pca[i, 0], X_pca[i, 1], X_pca[i, 2],
#                color=colors[labels[i]],
#                label=labels[i] if i in [0, 10] else "")
#     ax.text(X_pca[i, 0], X_pca[i, 1], X_pca[i, 2], str(i + 1), fontsize=8)

# ax.set_xlabel('PC1')
# ax.set_ylabel('PC2')
# ax.set_zlabel('PC3')
# ax.set_title('SVM Decision Boundary (Z-slice) in 3D PCA Space')
# ax.legend()
# plt.tight_layout()
# plt.show()
