import matplotlib.pyplot as plt
import numpy as np
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC
from sklearn.metrics import classification_report, confusion_matrix
from mpl_toolkits.mplot3d import Axes3D

channel_ests = []

fig, axs = plt.subplots()

for i in range(41,441,1):
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
    ['tri-hedral'] * 100 + 
    ['di-hedral'] * 100 +
    ['cylinder'] * 100 +
    ['sheet'] * 100
)

label_to_int = {'tri-hedral': 0, 'di-hedral': 1, 'cylinder': 2, 'sheet': 3}
int_labels = np.array([label_to_int[label] for label in labels])

X = []
X = np.array(channel_ests)


# Standardize features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Apply PCA
pca = PCA(n_components=10)
X_pca = pca.fit_transform(X_scaled)

print(pca.explained_variance_ratio_)




# Split into train/test sets
X_train, X_test, y_train, y_test = train_test_split(X_pca, int_labels, test_size=0.2, stratify=int_labels)

# Train SVM classifier
svm = SVC(kernel='rbf', C=1.0, gamma='scale')
svm.fit(X_train, y_train)

# Predict and evaluate
y_pred = svm.predict(X_test)


print("Classification Report:")
print(classification_report(y_test, y_pred, target_names=label_to_int.keys()))
print("Confusion Matrix:")
print(confusion_matrix(y_test, y_pred))




# Plotting
fig = plt.figure()
ax = fig.add_subplot(projection='3d')

color_map = {'tri-hedral': 'r', 'di-hedral': 'g','cylinder': 'b','sheet': 'y'}

for i in range(len(X_pca)):
    ax.scatter(X_pca[i, 0], X_pca[i, 1], X_pca[i, 2],
               color=color_map[labels[i]],
               label=labels[i] if i % 100 == 0 else "")  # Avoid repeated labels

ax.set_xlabel('PC1')
ax.set_ylabel('PC2')
ax.set_zlabel('PC3')
ax.set_title("PCA Space")
# ax.view_init(elev=, azim=0)  # ← change perspective to top-down
ax.legend()
plt.show()
