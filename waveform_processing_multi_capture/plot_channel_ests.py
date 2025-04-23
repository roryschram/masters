import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('TkAgg')
import numpy as np
from scipy.signal import decimate



arrays = []

for i in range(1,41):
    print("Reading channel estimation "+str(i))
    filename = "../masters_large_data/received_data/multi_receive/channel_estimations/channel_est"+str(i)+".npy"
    arr = np.load(filename)
    # downsample_factor = 2500
    # capture_ds = decimate(arr, downsample_factor)
    arrays.append(arr)

X = np.array(arrays)


for i in range(0,1):
    plt.plot(np.fft.fftshift(np.abs(X[i])))
plt.show()