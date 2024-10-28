import numpy as np
import matplotlib.pyplot as plt


# Read the binary data
with open("received_data/receive.dat", 'rb') as f:
    data = f.read()
    
    # Convert the binary data to an array of 32-bit floats
    double_data = np.frombuffer(data, dtype=np.double)
    
    # Reshape the data into pairs of (I, Q) values
    complex_data = double_data[0::2] + 1j * double_data[1::2]


plt.plot(np.real(complex_data),label="Real Part")
plt.plot(np.imag(complex_data),label="Imag Part")
plt.legend()
plt.show()

sweep_signal = np.load("chirp_toolchain/sweep_signal.npy")

corrolation = 20*np.log(np.abs(np.correlate(complex_data,sweep_signal)))

pos_start_frame = np.argmax(np.abs(corrolation))


plt.plot(corrolation)
plt.plot(pos_start_frame,np.abs(corrolation[pos_start_frame]),"ro")
plt.annotate("Corrolation peak. Pos: "+str(pos_start_frame),xy=(pos_start_frame,np.abs(corrolation[pos_start_frame])),xytext=(pos_start_frame+5,np.abs(corrolation[pos_start_frame])))
plt.show()

