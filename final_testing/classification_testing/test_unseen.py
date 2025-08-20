import numpy as np
import joblib

# Load everything
bundle = joblib.load("final_testing/classification_testing/model/svm_bundle.pkl")
svm = bundle["svm"]
scaler = bundle["scaler"]
pca = bundle["pca"]
int_to_label = bundle["int_to_label"]


def predict(channel_est):
    unseen = channel_est
    # Preprocess (same as training)
    unseen = np.abs(unseen).reshape(1, -1)
    unseen_scaled = scaler.transform(unseen)
    unseen_pca = pca.transform(unseen_scaled)

    # Predict
    prediction = svm.predict(unseen_pca)
    print("Predicted class (int):", prediction[0])
    print("Predicted class (label):", int_to_label[prediction[0]])


for i in range(1,10):
    # Example: load unseen channel estimation
    est = np.load("../masters_large_data/final_testing/classification_testing/channel_ests/channel_est60"+str(i)+".npy")
    predict(est)
