import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('TkAgg')
import numpy as np



arrays = []

for i in range(30,31):
    print("Reading raw data "+str(i))
    filename = "../masters_large_data/received_data/multi_receive/data_frames/data_frame"+str(i)+".npy"
    arr = np.load(filename)
    arrays.append(arr)

X = np.array(arrays)


for i in range(0,1):
    plt.plot(np.real(X[i]))
    plt.plot(np.imag(X[i]))
plt.show()