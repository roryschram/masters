import numpy as np
import matplotlib.pyplot as plt
import scipy
import scipy.interpolate
import time

import scipy.signal




channel_est1 = np.load("../masters_large_data/received_data/channel_est.npy")
channel_est2 = channel_est1
print("Channel estimations loaded!")


start_time = time.time()
matched_output1 = scipy.signal.correlate(channel_est1,channel_est2)
print("\nTime to corrolate using NumPy:\n--- %s seconds ---\n" % (time.time() - start_time))


start_time = time.time()
matched_output2 = scipy.signal.correlate(channel_est1,channel_est2)
print("\nTime to corrolate using SciPy:\n--- %s seconds ---\n" % (time.time() - start_time))


f1 = plt.figure(1)
plt.plot(matched_output1)

f2 = plt.figure(2)
plt.plot(matched_output2)

plt.show()