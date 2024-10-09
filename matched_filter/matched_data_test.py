import h5py
import numpy as np
import matplotlib.pyplot as plt

# Load the .h5 file
file_path = '/Users/roryschram/Documents/Work/masters/matched_filter/temp.h5'
with h5py.File(file_path, 'r') as file:
    # List all groups in the file
    print("Keys in the file:", list(file.keys()))
    
    # Access the datasets
    received_dataset_name = 'received'  # Replace with actual name
    transmitted_dataset_name = 'transmit'  # Replace with actual name
    
    # Extract data
    received_data = file[received_dataset_name][()]
    transmitted_data = file[transmitted_dataset_name][()]
    
    # Separate real and imaginary parts
    received_real_data = np.real(received_data)
    received_imag_data = np.imag(received_data)

    # Separate real and imaginary parts
    transmitted_real_data = np.real(transmitted_data)
    transmitted_imag_data = np.imag(transmitted_data)


interleaved_received = np.empty((received_real_data.size), dtype=np.complex128)

for i in range(0,received_real_data.size):
    interleaved_received[i] = received_real_data[i] + 1j*received_imag_data[i]


interleaved_transmitted = np.empty((transmitted_real_data.size),dtype=np.complex128)

for i in range(0,transmitted_real_data.size):
    interleaved_transmitted[i] = transmitted_real_data[i] + 1j*transmitted_imag_data[i]


padding = 50000

padded_interleaved_received = np.pad(interleaved_received, pad_width=(padding, padding), mode='constant', constant_values=0)
padded_interleaved_transmitted = np.pad(interleaved_transmitted, pad_width=(padding, padding), mode='constant', constant_values=0)


matched_filter_output = np.correlate(padded_interleaved_received, interleaved_transmitted)
pos_start_received = np.argmax(matched_filter_output)
received_frame = padded_interleaved_received[pos_start_received:pos_start_received+30000]


received_frame_fft = np.fft.fft(received_frame)/received_frame.size
received_frame_fft[:50] = 0 + 0j
received_frame_fft[-50:] = 0 + 0j
received_frame_fft = np.fft.fftshift(received_frame_fft)


fig, ((ax1, ax2),(ax3, ax4),(ax5, ax6),(ax7, ax8)) = plt.subplots(4, 2, figsize=(12, 7))

# Plot real and imaginary parts on the first axis (transmitted data)
ax1.plot(np.real(interleaved_transmitted), label='Real Part')
ax1.plot(np.imag(interleaved_transmitted), label='Imaginary Part')
ax1.set_xlabel('Sample Index')
ax1.set_ylabel('Amplitude')
ax1.set_title('Transmitted data: real and imaginary parts')
ax1.legend(loc='upper right')
ax1.grid(True)

# Plot real and imaginary parts on the first axis (received data)
ax2.plot(np.real(interleaved_received), label='Real Part')
ax2.plot(np.imag(interleaved_received), label='Imaginary Part')
ax2.set_xlabel('Sample Index')
ax2.set_ylabel('Amplitude')
ax2.set_title('Received data: real and imaginary parts')
ax2.legend(loc='upper right')
ax2.grid(True)

# Plot real and imaginary parts on the first axis (padded transmitted data)
ax3.plot(np.real(padded_interleaved_transmitted), label='Real Part')
ax3.plot(np.imag(padded_interleaved_transmitted), label='Imaginary Part')
ax3.set_xlabel('Sample Index')
ax3.set_ylabel('Amplitude')
ax3.set_title('Padded transmitted data: real and imaginary parts')
ax3.legend(loc='upper right')
ax3.grid(True)

# Plot real and imaginary parts on the first axis (padded received data)
ax4.plot(np.real(padded_interleaved_received), label='Real Part')
ax4.plot(np.imag(padded_interleaved_received), label='Imaginary Part')
ax4.set_xlabel('Sample Index')
ax4.set_ylabel('Amplitude')
ax4.set_title('Padded received data: real and imaginary parts')
ax4.legend(loc='upper right')
ax4.grid(True)

# Plot output of matched filtering between transmitted and received data
ax5.plot(np.abs(matched_filter_output))
ax5.set_xlabel('Sample Index')
ax5.set_ylabel('Amplitude')
ax5.set_title('Output of matched filtering process')
ax5.grid(True)

# Plot the supposed data frame based off of matched filtering
ax6.plot(np.real(received_frame), label='Real Part')
ax6.plot(np.imag(received_frame), label='Imaginary Part')
ax6.set_xlabel('Sample Index')
ax6.set_ylabel('Amplitude')
ax6.set_title('Plot of the supposed data frame based off of matched filtering')
ax6.legend(loc='upper right')
ax6.grid(True)

# Plot of fft of received signal with DC component removed
ax7.plot(np.abs(received_frame_fft))
ax7.set_xlabel('Sample Index')
ax7.set_ylabel('Amplitude')
ax7.set_title('FFT of received signal with DC component removed')
ax7.grid(True)

# Plot IQ constellation map of received data fft
ax8.scatter(np.real(received_frame_fft),np.imag(received_frame_fft))
ax8.set_xlabel('I')
ax8.set_ylabel('Q')
ax8.set_title('Plot of the IQ constellation map of received data fft')
ax8.grid(True)

plt.tight_layout()
plt.show()