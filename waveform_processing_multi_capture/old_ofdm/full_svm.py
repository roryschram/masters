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
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score

from scipy.signal import decimate


arrays = []

for i in range(1,41):
    print("Reading channel estimation "+str(i))
    filename = "../masters_large_data/received_data/multi_receive/channel_estimations/channel_est"+str(i)+".npy"
    arr = np.fft.fftshift(np.abs(np.load(filename)))

    arr = arr[0:5000]
    sections = arr.reshape((1, 5000))  # 10 rows, each with 500 elements
    for k in sections:    
        arrays.append(k)

X = np.array(arrays)

print(X.shape)


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



# Define labels for each point
labels = (
    ['60 dB'] * 10 + 
    ['50 dB'] * 10 + 
    ['40 dB'] * 10 + 
    ['30 dB'] * 10
)

label_encoder = LabelEncoder()
y_encoded = label_encoder.fit_transform(labels)

print(y_encoded)

X_train, X_test, y_train, y_test = train_test_split(X_pca, y_encoded, test_size=0.20, random_state=None, stratify=y_encoded)


svm = SVC(kernel='rbf', C=1.0, gamma='scale')  # You can tune these hyperparameters
svm.fit(X_train, y_train)

y_pred = svm.predict(X_test)
print("Accuracy:", accuracy_score(y_test, y_pred))
print("Classification Report:\n", classification_report(y_test, y_pred, target_names=label_encoder.classes_))















colors = {'60 dB': 'red', '50 dB': 'blue', '40 dB': 'green', '30 dB': 'gray'}
fig = plt.figure(figsize=(10, 8))
ax = fig.add_subplot(111, projection='3d')

# Scatter actual data points
for i in range(len(X_pca)):
    ax.scatter(X_pca[i, 0], X_pca[i, 1], X_pca[i, 2],
               color=colors[labels[i]],
               label=labels[i] if i in [0, 10, 20, 30] else "")

ax.set_xlabel('PC1')
ax.set_ylabel('PC2')
ax.set_zlabel('PC3')
ax.set_title('PCA in 3D PCA Space')
ax.legend()
plt.tight_layout()
plt.show()
