import numpy as np
import matplotlib.pyplot as plt
import scipy


K = 400000 # number of OFDM subcarriers

# CP = K//4  # length of the cyclic prefix: 25% of the block

P = 100000 # number of pilot carriers per OFDM block
pilotValue = 3+3j # The known value each pilot transmits


allCarriers = np.arange(K)  # indices of all subcarriers ([0, 1, ... K-1])

pilotCarriers = allCarriers[::K//P] # Pilots is every (K/P)th carrier.

# For convenience of channel estimation, let's make the last carriers also be a pilot
pilotCarriers = np.hstack([pilotCarriers, np.array([allCarriers[-1]])])
P = P+1

# data carriers are all remaining carriers
dataCarriers = np.delete(allCarriers, pilotCarriers)

print ("allCarriers:   %s" % allCarriers)
print ("pilotCarriers: %s" % pilotCarriers)
print ("dataCarriers:  %s" % dataCarriers)
plt.plot(pilotCarriers, np.zeros_like(pilotCarriers), 'bo', label='pilot')
plt.plot(dataCarriers, np.zeros_like(dataCarriers), 'ro', label='data')

plt.title("Symbol Scheme for OFDM Signal")
plt.xlabel("Carrier Index")
plt.grid()
plt.tight_layout()
plt.legend()
plt.show()



mu = 4 # bits per symbol (i.e. 16QAM)
payloadBits_per_OFDM = len(dataCarriers)*mu  # number of payload bits per OFDM symbol

mapping_table = {
    (0,0,0,0) : -3-3j,
    (0,0,0,1) : -3-1j,
    (0,0,1,0) : -3+3j,
    (0,0,1,1) : -3+1j,
    (0,1,0,0) : -1-3j,
    (0,1,0,1) : -1-1j,
    (0,1,1,0) : -1+3j,
    (0,1,1,1) : -1+1j,
    (1,0,0,0) :  3-3j,
    (1,0,0,1) :  3-1j,
    (1,0,1,0) :  3+3j,
    (1,0,1,1) :  3+1j,
    (1,1,0,0) :  1-3j,
    (1,1,0,1) :  1-1j,
    (1,1,1,0) :  1+3j,
    (1,1,1,1) :  1+1j
}
for b3 in [0, 1]:
    for b2 in [0, 1]:
        for b1 in [0, 1]:
            for b0 in [0, 1]:
                B = (b3, b2, b1, b0)
                Q = mapping_table[B]
                plt.plot(Q.real, Q.imag, 'bo')
                plt.text(Q.real, Q.imag+0.2, "".join(str(x) for x in B), ha='center')


plt.title("16 QAM Constellation with Grey-Mapping")
plt.xlabel("Real Part (I)")
plt.ylabel("Imaginary Part (Q)")
plt.ylim(-4,4)
plt.xlim(-4,4)
plt.grid()
plt.show()

demapping_table = {v : k for k, v in mapping_table.items()}

channelResponse = np.array([1, 0, 0.3+0.3j])  # the impulse response of the wireless channel
H_exact = np.fft.fft(channelResponse, K)
#plt.plot(allCarriers, abs(H_exact))

SNRdb = 25  # signal to noise-ratio in dB at the receiver 

bits = np.random.binomial(n=1, p=0.5, size=(payloadBits_per_OFDM, ))


np.save("transmitted_data/bits.npy",bits)


print ("Bits count: ", len(bits))
print ("First 20 bits: ", bits[:20])
print ("Mean of bits (should be around 0.5): ", np.mean(bits))


def SP(bits):
    return bits.reshape((len(dataCarriers), mu))
bits_SP = SP(bits)
print ("First 5 bit groups")
print (bits_SP[:5,:])



def Mapping(bits):
    return np.array([mapping_table[tuple(b)] for b in bits])
QAM = Mapping(bits_SP)
print ("First 5 QAM symbols and bits:")
print (bits_SP[:5,:])
print (QAM[:5])


def OFDM_symbol(QAM_payload):
    symbol = np.zeros(K, dtype=complex) # the overall K subcarriers
    symbol[pilotCarriers] = pilotValue  # allocate the pilot subcarriers 
    symbol[dataCarriers] = QAM_payload  # allocate the pilot subcarriers
    return symbol
OFDM_data = OFDM_symbol(QAM)
print ("Number of OFDM carriers in frequency domain: ", len(OFDM_data))






plt.plot(np.abs(OFDM_data))
plt.title("OFDM Symbol in Discrete Freq. Domain")
plt.xlabel('Carrier Index')
plt.ylabel('$|X(w)|$')
plt.grid(True)
plt.show()







def IDFT(OFDM_data):
    return np.fft.ifft(OFDM_data)
OFDM_time = IDFT(OFDM_data)
print ("Number of OFDM samples in time-domain before CP: ", len(OFDM_time))




plt.plot(np.abs(OFDM_time))
plt.show()


# def addCP(OFDM_time):
#     cp = OFDM_time[-CP:]               # take the last CP samples ...
#     return np.hstack([cp, OFDM_time])  # ... and add them to the beginning
# OFDM_withCP = addCP(OFDM_time)
# print ("Number of OFDM samples in time domain with CP: ", len(OFDM_withCP))


np.save("transmitted_data/original_OFDM_pulse.npy",OFDM_time)


padded_OFDM_withCP = np.pad(OFDM_time, pad_width=(5000,1000), mode='constant', constant_values=0+0j)



# Plot the generated sweep signal (showing only a portion for clarity)
plt.plot(np.real(padded_OFDM_withCP),label="Real Part")  # Adjust the portion as needed
plt.plot(np.imag(padded_OFDM_withCP),label="Imag Part") 
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.title("Multi OFDM signal")
plt.legend()
plt.show()








np.save("transmitted_data/padded_OFDM_pulse.npy",padded_OFDM_withCP)

# # Open a .dat file in binary write mode
# with open('waveform_generation/generated_data/padded_OFDM_pulse.dat', 'wb') as f:
#     for sample in padded_OFDM_withCP:
#         # Write the real part (I) as 64-bit double
#         f.write(np.double(sample.real).tobytes())
#         # Write the imaginary part (Q) as 64-bit double
#         f.write(np.double(sample.imag).tobytes())


# Save .dat in build folder of cpp project
with open('transmitted_data/transmit.dat', 'wb') as f:
    for sample in padded_OFDM_withCP:
        # Write the real part (I) as 64-bit double
        f.write(np.double(sample.real).tobytes())
        # Write the imaginary part (Q) as 64-bit double
        f.write(np.double(sample.imag).tobytes())


