import numpy as np
import joblib

# Load everything
model_name = "nothing_then_standing_then_standing_arms_out"

bundle = joblib.load("final_testing/classification_testing/models/"+model_name+".pkl")
svm = bundle["svm"]
scaler = bundle["scaler"]
pca = bundle["pca"]
int_to_label = bundle["int_to_label"]


def predict(channel_est):
    unseen = channel_est
    # Preprocess (same as training)
    unseen_scaled = scaler.transform(unseen)
    unseen_pca = pca.transform(unseen_scaled)

    # Predict
    prediction = svm.predict(unseen_pca)
    # print("Predicted class (int):", prediction[0])
    # print(int_to_label)
    for i in prediction:
        print(int_to_label[i])


channel_ests = []

for i in range(901,951):
    # Example: load unseen channel estimation
    # print("Unseen: "+str(i))
    est = np.abs(np.load("../masters_large_data/final_testing/classification_testing/channel_ests/channel_est"+str(i)+".npy"))
    channel_ests.append(est)

predict(channel_ests)


    
