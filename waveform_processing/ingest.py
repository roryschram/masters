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

#received_data = received_data[255:]

received_data = received_data - np.mean(received_data)

for i in range(0,199,1):
    received_data[i] = 0.0 + 0.0j




# Get the original pulse
transmitted_data = np.load("waveform_generation/generated_data/padded_OFDM_pulse.npy")
# transmitted_data = np.load("chirp_toolchain/sweep_signal.npy")

# plt.plot(np.abs(transmitted_data))
# plt.show()

corrolation = np.correlate(received_data,transmitted_data)

pos_start_frame = np.argmax(np.abs(corrolation))

print(pos_start_frame)

#received_data = received_data - np.mean(received_data)
symbol = received_data[pos_start_frame:pos_start_frame+512]


# plt.plot(np.abs(symbol))
# plt.show()

np.save("waveform_processing/symbol.npy",symbol)

plt.plot(20*np.log(np.abs(np.fft.fftshift(np.fft.fft(received_data)))))
plt.title("Received signal fft")
plt.xlabel("Samples")
plt.ylabel("|received|")
plt.show()


plt.plot(np.real(received_data))
plt.plot(np.imag(received_data))
plt.title("Received signal")
plt.xlabel("Samples")
plt.ylabel("|received|")
plt.show()

plt.plot(np.abs(corrolation))
plt.plot(pos_start_frame,np.abs(corrolation[pos_start_frame]),"ro")
plt.annotate("Corrolation peak. Pos: "+str(pos_start_frame),xy=(pos_start_frame,np.abs(corrolation[pos_start_frame])),xytext=(pos_start_frame+5,np.abs(corrolation[pos_start_frame])))
plt.title("Corrolation between received signal and original transmitted signal")
plt.xlabel("Samples")
plt.ylabel("$|\\rho(received data,original frame)|$")
plt.show()

