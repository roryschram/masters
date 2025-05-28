import matplotlib.pyplot as plt
# plt.rcParams['figure.figsize'] = (10, 4)
# plt.rcParams['figure.dpi'] = 300

import numpy as np
import scipy
import h5py

from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from scipy.signal import decimate

channel_ests = []

fig, axs = plt.subplots()

for i in range(1,251,1):
    input = np.load("../masters_large_data/received_data/multi_receive/channel_estimations/channel_est"+str(i)+".npy")
    channel_ests.append(input)
    axs.plot(input,color='orange')

axs.set_ybound(0.0,1.1)
axs.set_title("100 Channel Estimations")
axs.set_xlabel("Channels")
axs.set_ylabel("Channel Est")
plt.show()


# Parameters
num_captures = 250
window_size =  320 # We'll use the first 8192 samples of each
labels = (
    ['First'] * 50 + 
    ['Second'] * 50 +
    ['Third'] * 50 +
    ['Fourth'] * 50 +
    ['Fifth'] * 50
)

X = []

# # Extract FFT magnitude features from each variable
# for i in range(1, num_captures + 1):
#     capture = globals()[f"capture{i}"][:window_size]  # Access variable by name
#     # Downsample to 12.5k samples
#     downsample_factor = 12500
#     capture_ds = decimate(capture, downsample_factor)
#     X.append(capture_ds)


X = np.array(channel_ests)


# Standardize features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Apply PCA
pca = PCA(n_components=3)
X_pca = pca.fit_transform(X_scaled)

print(pca.explained_variance_ratio_)

# Plotting
fig = plt.figure()
ax = fig.add_subplot(projection='3d')

color_map = {'First': 'r', 'Second': 'g','Third': 'b','Fourth': 'y','Fifth': 'c'}

for i in range(len(X_pca)):
    ax.scatter(X_pca[i, 0], X_pca[i, 1], X_pca[i, 2],
               color=color_map[labels[i]],
               label=labels[i] if i % 50 == 0 else "")  # Avoid repeated labels

ax.set_xlabel('PC1')
ax.set_ylabel('PC2')
ax.set_zlabel('PC3')
ax.set_title("PCA of Channel Estimations")
# ax.view_init(elev=, azim=0)  # ← change perspective to top-down
ax.legend()
plt.show()
