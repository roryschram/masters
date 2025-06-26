import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.axes import Axes
from scipy import signal



def read_complex_data_from_dat(filename):
    # Read the binary data
    with open(filename, 'rb') as f:
        data = f.read()

    # Convert the binary data to an array of 32-bit floats
    double_data = np.frombuffer(data, dtype=np.double)

    # Reshape the data into pairs of (I, Q) values
    complex_data = double_data[0::2] + 1j * double_data[1::2]

    return complex_data

# Get received usrp data
received_data = read_complex_data_from_dat("../masters_large_data/received_data/receive.dat")
transmitted_data = read_complex_data_from_dat("../masters_large_data/transmitted_data/transmit.dat")

# Get correlation
corr = signal.correlate(received_data,transmitted_data)
corr = np.abs(corr)

# Get maximum of correlation
pos_max = np.argmax(corr)
print("Position of maximum in correlation: "+str(pos_max))

# Extract frame

fig, axis = plt.subplots(2,1)

ax:Axes = axis[0]

ax.plot(np.real(received_data),label = "Real")
ax.plot(np.imag(received_data), label = "Imag")
ax.legend()
ax.set_title("Raw received signal")
ax.set_xlabel("Samples")
ax.set_ylabel("received")

ax = axis[1]
ax.plot(corr)
ax.set_title("Correlation of transmitted and received")
ax.set_xlabel("Samples")
ax.set_ylabel("|corr|")


plt.tight_layout()
plt.show()
