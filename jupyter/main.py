import matplotlib.pyplot as plt
plt.rcParams['figure.figsize'] = (10, 4)
plt.rcParams['figure.dpi'] = 300

import numpy as np
import scipy
import h5py

from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from scipy.signal import decimate



# Read the NumPy array from the HDF5 file
with h5py.File("../database.hdf5", 'r') as hdf5_file:
    capture1 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["001"])))
    capture2 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["002"])))
    capture3 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["003"])))
    capture4 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["004"])))
    capture5 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["005"])))
    capture6 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["006"])))
    capture7 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["007"])))
    capture8 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["008"])))
    capture9 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["009"])))
    capture10 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["010"])))

    capture11 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["011"])))
    capture12 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["012"])))
    capture13 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["013"])))
    capture14 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["014"])))
    capture15 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["015"])))
    capture16 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["016"])))
    capture17 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["017"])))
    capture18 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["018"])))
    capture19 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["019"])))
    capture20 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["020"])))

    capture21 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["021"])))
    capture22 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["022"])))
    capture23 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["023"])))
    capture24 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["024"])))
    capture25 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["025"])))
    capture26 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["026"])))
    capture27 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["027"])))
    capture28 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["028"])))
    capture29 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["029"])))
    capture30 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["030"])))

    capture31 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["031"])))
    capture32 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["032"])))
    capture33 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["033"])))
    capture34 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["034"])))
    capture35 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["035"])))
    capture36 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["036"])))
    capture37 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["037"])))
    capture38 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["038"])))
    capture39 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["039"])))
    capture40 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["040"])))
hdf5_file.close()





# Parameters
num_captures = 40
window_size = 12500000  # We'll use the first 8192 samples of each
labels = (
    ['trihedral'] * 10 + 
    ['dihedral'] * 10 + 
    ['cylinder'] * 10 + 
    ['none'] * 10
)

X = []

# Extract FFT magnitude features from each variable
for i in range(1, num_captures + 1):
    capture = globals()[f"capture{i}"][:window_size]  # Access variable by name
    # Downsample to 12.5k samples
    downsample_factor = 25000
    capture_ds = decimate(capture, downsample_factor)

    X.append(capture_ds)

X = np.array(X)


# Standardize features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Apply PCA
pca = PCA(n_components=10)
X_pca = pca.fit_transform(X_scaled)

print(pca.explained_variance_ratio_)

# Plotting
fig = plt.figure(figsize=(10,4))
ax = fig.add_subplot(111,projection='3d')

color_map = {'trihedral': 'r', 'dihedral': 'g', 'cylinder': 'b', 'none': 'gray'}

for i in range(len(X_pca)):
    ax.scatter(X_pca[i, 0], X_pca[i, 1], X_pca[i, 2],
               color=color_map[labels[i]],
               label=labels[i] if i % 10 == 0 else "")  # Avoid repeated labels

ax.set_xlabel('PC1')
ax.set_ylabel('PC2')
ax.set_zlabel('PC3')
ax.set_title("PCA of Channel Estimations")
# ax.view_init(elev=, azim=0)  # ← change perspective to top-down
ax.legend()
ax.legend(loc='center left', bbox_to_anchor=(1.05, 0.5))
plt.show()