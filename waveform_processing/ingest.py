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
received_data = read_complex_data_from_dat("waveform_processing/received_data/received.dat")


# Get the original pulse
transmitted_data = np.load("waveform_generation/generated_data/padded_OFDM_pulse.npy")

plt.plot(np.abs(transmitted_data))
plt.show()

corrolation = np.correlate(received_data,transmitted_data)

pos_start_frame = np.argmax(np.abs(corrolation))

print(pos_start_frame)

symbol = received_data[pos_start_frame:pos_start_frame+80]

plt.plot(np.abs(symbol))
plt.show()

np.save("waveform_processing/symbol.npy",symbol)

plt.plot(np.abs(corrolation))
plt.show()