import numpy as np
import matplotlib.pyplot as plt


# map ofdm symbols to QPSK constellation

# here is an example short sequence 
# where 0 is Q1, 1 Q2, 2 Q3 and 3 Q4

symmap = {0: 1 + 1j,
        3 : 1 - 1j,
        2 : -1 - 1j,
        1 : -1 + 1j}


tx_symb = [0,1,2,3,2,1,2,1,3,2,1,2,3,2,1,0,2,0,2,0,2,1,2,3,1,1,1,1,2,3,2,1,2,0,0,0,2,1,2,0]

# inverse FFT for tx sequence

txfft = [symmap[i] for i in tx_symb]

plt.scatter(np.real(txfft),np.imag(txfft))
plt.show()

tx = np.fft.ifft(txfft)

plt.plot((tx))
plt.show()

# recovering rx in the receiver

rx1 = np.fft.fft((tx))


plt.scatter(np.real(rx1),np.imag(rx1))
plt.show()
