import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.axes import Axes
from scipy import signal
from scipy import interpolate

# Input signal parameters here
fs = 25e6
fft_bins = 16384
allCarriers = np.arange(10000)
pilot_value = 3+3j





def read_complex_data_from_dat(filename):
    # Read the binary data
    with open(filename, 'rb') as f:
        data = f.read()

    # Convert the binary data to an array of 32-bit floats
    double_data = np.frombuffer(data, dtype=np.double)

    # Reshape the data into pairs of (I, Q) values
    complex_data = double_data[0::2] + 1j * double_data[1::2]

    return np.array(complex_data)

# Get received usrp data
received_data = read_complex_data_from_dat("../masters_large_data/received_data/receive.dat")
# received_data = read_complex_data_from_dat("../masters_large_data/transmitted_data/transmit.dat")
transmitted_data = read_complex_data_from_dat("../masters_large_data/transmitted_data/transmit.dat")



# Cut off first cool down period of capture
# received_data = received_data[1000000:]


# received_data = np.pad(received_data,(100000,100000),mode="constant",constant_values=0+0j)




# Get correlation
corr = signal.correlate(received_data,transmitted_data)
corr_abs = np.abs(corr)

# Get maximum of correlation
pos_max = np.argmax(corr_abs)

# Get corresponding lag value
print("Position of start of frame: "+str(pos_max))

# Extract rough frame
frame = np.array(received_data[pos_max-fft_bins:pos_max])


# === Compute FFT of the OFDM signal (with CP) ===
spectrum = np.fft.fftshift(np.fft.fft(frame, n=fft_bins))
spectrum_magnitude_db = 20 * np.log10(np.abs(spectrum) + 1e-12)  # avoid log(0)

# Frequency axis in MHz
freq_axis = np.linspace(-fs/2, fs/2, fft_bins) / 1e6


pilot_indices_shifted = np.load("../masters_large_data/final_testing/com_testing/pilot_indices_shifted.npy")


fig, axis = plt.subplots(2,1)
ax:Axes = axis[0]

ax.plot(spectrum_magnitude_db)
ax.set_title("FFT of data frame")
ax.set_xlabel("FFT bins")
ax.set_ylabel("Magnitude (dB)")
for bin_idx in pilot_indices_shifted:
    ax.axvline(x=bin_idx, color='red', linestyle='--', linewidth=0.8, alpha=0.7)


ax = axis[1]

ax.plot(np.abs(spectrum))
ax.set_title("Absolute of FFT of data frame")
ax.set_xlabel("FFT bins")
ax.set_ylabel("Magnitude")
for bin_idx in pilot_indices_shifted:
    ax.axvline(x=bin_idx, color='red', linestyle='--', linewidth=0.8, alpha=0.7)


plt.tight_layout()
plt.show()




fig, axis = plt.subplots(2,1)

axis = axis.flatten()
ax:Axes = axis[0]

ax.plot(np.real(received_data),label = "Real")
ax.plot(np.imag(received_data), label = "Imag")
ax.legend()
ax.set_title("Raw received signal")
ax.set_xlabel("Samples")
ax.set_ylabel("Amplitude")

ax = axis[1]
ax.plot(np.abs(corr))
ax.set_title("Correlation of transmitted and received")
ax.set_xlabel("Samples")
ax.set_ylabel("|corr|")

plt.tight_layout()
plt.show()


fig, axis = plt.subplots(2,1)

axis = axis.flatten()
ax:Axes = axis[0]

ax = axis[0]
ax.plot(np.real(frame),label = "Real")
ax.plot(np.imag(frame), label = "Imag")
ax.legend()
ax.set_title("Roughly extracted frame")
ax.set_xlabel("Samples")
ax.set_ylabel("Amplitude")

ax = axis[1]
ax.plot(spectrum_magnitude_db)
ax.set_title("FFt of roughly extracted frame")
ax.set_xlabel("Freq (Hz)")
ax.set_ylabel("Amplitude")

for bin_idx in pilot_indices_shifted:
    ax.axvline(x=bin_idx, color='red', linestyle='--', linewidth=0.5, alpha=0.7)

plt.tight_layout()
plt.show()

print(pilot_indices_shifted)



plt.plot(np.abs(spectrum))
plt.show()

print(allCarriers)

pilot_symbols = np.load("../masters_large_data/final_testing/com_testing/pilot_symbols.npy")
pilot_indices_shifted = np.load("../masters_large_data/final_testing/com_testing/pilot_indices_shifted.npy")
pilot_indices = np.load("../masters_large_data/final_testing/com_testing/pilot_indices.npy")

print(pilot_indices)
print(pilot_indices_shifted)

plt.plot(spectrum)
plt.show()

print(str(len(pilot_indices)))
print(str(len(pilot_symbols)))

print(pilot_symbols)
def channelEstimate(OFDM_demod):
    pilots = OFDM_demod[pilot_indices]  # extract the pilot values from the RX signal
    Hest_at_pilots = pilots / pilot_symbols # divide by the transmitted pilot values
    
    # Perform interpolation between the pilot carriers to get an estimate
    # of the channel in the data carriers. Here, we interpolate absolute value and phase 
    # separately
    Hest_abs = interpolate.interp1d(pilot_indices, np.abs(Hest_at_pilots),kind="cubic")(allCarriers)
    Hest_phase = interpolate.interp1d(pilot_indices, np.angle(Hest_at_pilots),kind="cubic")(allCarriers)
    Hest = Hest_abs * np.exp(1j*Hest_phase)
    
    # plt.stem(pilotCarriers, np.fft.fftshift(abs(Hest_at_pilots)), label='Pilot estimates')
    plt.plot(allCarriers, np.abs(Hest), label='Estimated channel via interpolation')
    plt.title("Channel estimation based on pilots")
    plt.grid(True); plt.xlabel('Carrier index'); plt.ylabel('$|H(f)|$')
    plt.show()
    
    return Hest

all_carriers_shifted = np.load("../masters_large_data/final_testing/com_testing/all_carriers_shifted.npy")

temp = spectrum[all_carriers_shifted]
Hest = channelEstimate(temp)



plt.plot(spectrum)
plt.show()

def equalize(OFDM_demod, Hest):
    return OFDM_demod / Hest
    # return OFDM_demod   

equalized_Hest = equalize(spectrum[all_carriers_shifted], Hest)


plt.plot(np.abs(equalized_Hest))
plt.title("Equalised Carriers Absoluted")
plt.xlabel("Samples")
plt.ylabel("|H(f)|")
plt.tight_layout()
plt.show()


print(allCarriers)
print((pilot_indices_shifted))

data_indices = np.setdiff1d(allCarriers, pilot_indices)

print(data_indices[:20])


def get_payload(equalized):
    return equalized[data_indices]
QAM_est = get_payload(equalized_Hest)




# 16 QAM mapping table
mapping_table = {
    (0,0) : -1-1j,
    (0,1) :  1-1j,
    (1,0) : -1+1j,
    (1,1) :  1+1j,
}

constellation_points = np.array(list(mapping_table.values()))


plt.plot(QAM_est.real, QAM_est.imag, 'bo')
plt.plot(constellation_points.real, constellation_points.imag, 'ro')
plt.title("Received Constelation")
plt.xlabel("Real Part (I)")
plt.ylabel("Imaginary Part (Q)")
plt.show()





demapping_table = {v : k for k, v in mapping_table.items()}

print(demapping_table)

def Demapping(QAM):
    # array of possible constellation points
    constellation = np.array([x for x in demapping_table.keys()])
    
    # calculate distance of each RX point to each possible point
    dists = abs(QAM.reshape((-1,1)) - constellation.reshape((1,-1)))
    
    # for each element in QAM, choose the index in constellation 
    # that belongs to the nearest constellation point
    const_index = dists.argmin(axis=1)
    
    # get back the real constellation point
    hardDecision = constellation[const_index]
    
    # transform the constellation point into the bit groups
    return np.vstack([demapping_table[C] for C in hardDecision]), hardDecision

PS_est, hardDecision = Demapping(QAM_est)

print(str(len(PS_est)))


# for qam, hard in zip(QAM_est, hardDecision):
#     plt.plot([qam.real, hard.real], [qam.imag, hard.imag], 'b-o')
#     plt.plot(hardDecision.real, hardDecision.imag, 'ro')
# plt.title("Hard Decision Mapping")
# plt.xlabel("Real Part (I)")
# plt.ylabel("Imaginary Part (Q)")
# plt.show()


# Removed the bit error calc because ti took lots of compute

bits = np.load("../masters_large_data/final_testing/com_testing/bits.npy")



def PS(bits):
    return bits.reshape((-1,))

bits_est = PS(PS_est)
print ("Obtained Bit error rate: ", (np.sum(bits != bits_est)/len(bits)*100))


sent = bits
recv = bits_est

print("Sent: ", ''.join(str(b) for b in sent))
print("Recv: ", ''.join(str(b) if b == s else f"\033[91m{b}\033[0m"
                     for b, s in zip(recv, sent)))  # red highlight


