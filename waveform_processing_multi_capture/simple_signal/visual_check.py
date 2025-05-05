import numpy as np
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pyplot as plt
from matplotlib.axis import Axis


fig, axs = plt.subplots(1,1)

for i in range(1,51,1):
    input = np.load("../masters_large_data/received_data/multi_receive/channel_estimations/channel_est"+str(i)+".npy")
    axs.plot(input)
plt.show()
