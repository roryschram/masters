import numpy as np
import matplotlib.pylab as plt

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
received_data = read_complex_data_from_dat("received_data/receive.dat")


plt.plot(np.real(received_data))
plt.plot(np.imag(received_data))
plt.title("Received signal")
plt.xlabel("Samples")
plt.ylabel("|received|")
plt.show()
