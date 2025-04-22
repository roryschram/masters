import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('TkAgg')
import numpy as np



arrays = []

for i in range(1,21):
    print("Reading channel estimation "+str(i))
    filename = "../masters_large_data/received_data/multi_receive/channel_estimations/channel_est"+str(i)+".npy"
    arr = np.load(filename)
    arr = np.abs(arr)
    arrays.append(arr)

X = np.array(arrays)


for i in range(0,20):
    plt.plot(X[i])
    plt.text(np.argmax(X[i]), np.max(X[i]), str(i+1))
plt.show()