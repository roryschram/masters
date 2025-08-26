import matplotlib.pyplot as plt
import numpy as np
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC
from sklearn.metrics import classification_report, confusion_matrix
from mpl_toolkits.mplot3d import Axes3D
import joblib


# Settings for PCA

# Number of captures per target
captures_per_target = 250

# Lower and upper bound for ingest
lower, upper = 4001,5501

# Labels
labels_pre = ["1","2","3","4","5","6"]

model_name = "No_Target_Di-Hedral_Tri-Hedral_Cylinder_Metal Plate_Just Me_3m_250_Captures_Per_Object_Moving"

channel_ests = []


# fig = plt.subplot()

for i in range(lower,upper,1):
    input = np.load("../masters_large_data/final_testing/classification_testing/seminar_room/rotation_test/channel_ests/channel_est"+str(i)+".npy")
    channel_ests.append(np.abs(input))
    # plt.plot(np.abs(input))


# lower, upper = 6001,6251
# for i in range(lower,upper,1):
#     input = np.load("../masters_large_data/final_testing/classification_testing/seminar_room/3m_moving_target_test/channel_ests/channel_est"+str(i)+".npy")
#     channel_ests.append(np.abs(input))
#     # plt.plot(np.abs(input))


# lower, upper = 5751,6001
# for i in range(lower,upper,1):
#     input = np.load("../masters_large_data/final_testing/classification_testing/seminar_room/3m_moving_target_test/channel_ests/channel_est"+str(i)+".npy")
#     channel_ests.append(np.abs(input))
#     # plt.plot(np.abs(input))


# lower, upper = 6501,6751
# for i in range(lower,upper,1):
#     input = np.load("../masters_large_data/final_testing/classification_testing/seminar_room/3m_moving_target_test/channel_ests/channel_est"+str(i)+".npy")
#     channel_ests.append(np.abs(input))
#     # plt.plot(np.abs(input))






# channel_est_cutout = channel_ests[150:200]
# row_means = np.mean(channel_est_cutout, axis=1,keepdims=True)   # Step 1: Mean of each row
# overall_mean = np.mean(row_means)  # Step 2: Mean of the row means


# centered_arr = channel_est_cutout - row_means + overall_mean  # broadcasting handles dimensions
# # channel_ests[150:200] = centered_arr





labels = []
for i in labels_pre:
    for k in range(0,captures_per_target):
        labels.append(i)

# labels = (
#     ['1st'] * captures_per_target + 
#     ['2nd'] * captures_per_target +
#     ['3rd'] * captures_per_target
# )

label_to_int = {label: idx for idx, label in enumerate(labels_pre)}
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


# Build a dictionary with everything needed for inference
model_bundle = {
    "svm": svm,
    "scaler": scaler,
    "pca": pca,
    "label_to_int": label_to_int,
    "int_to_label": {v: k for k, v in label_to_int.items()}
}

# Save the bundle
joblib.dump(model_bundle, "final_testing/classification_testing/models/"+model_name+".pkl")

print("Model, scaler, PCA, and labels saved to "+model_name+".pkl")



print("Classification Report:")
print(classification_report(y_test, y_pred, target_names=label_to_int.keys()))
print("Confusion Matrix:")
print(confusion_matrix(y_test, y_pred))




# Plotting
fig = plt.figure()
ax = fig.add_subplot(projection='3d')

# Define a list of color codes (as many as you need)
colors = ['r', 'g', 'b', 'c', 'm', 'y', 'k']  # red, green, blue, cyan, magenta, yellow, black

# Get sorted unique labels (or just unique if you don’t care about order)
unique_labels = labels_pre

# Create the color map
color_map = {label: colors[idx] for idx, label in enumerate(unique_labels)}


for i in range(len(X_pca)):
    ax.scatter(X_pca[i, 0], X_pca[i, 1], X_pca[i, 2],
               color=color_map[labels[i]],
               label=labels[i] if i % captures_per_target == 0 else "")  # Avoid repeated labels

ax.set_xlabel('PC1')
ax.set_ylabel('PC2')
ax.set_zlabel('PC3')
ax.set_title("PCA Space")
# ax.view_init(elev=, azim=0)  # ← change perspective to top-down
ax.legend()
plt.show()
