import matplotlib.pyplot as plt
import numpy as np 


arr = np.load("../masters_large_data/transmitted_data/original_OFDM_pulse.npy")

fft = np.fft.fftshift(np.fft.fft(arr))

plt.plot(np.abs(fft))
plt.show()