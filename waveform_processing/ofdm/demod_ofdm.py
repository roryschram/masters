import numpy as np
import matplotlib.pyplot as plt
import scipy
import scipy.interpolate

K = 50000 # number of OFDM subcarriers

CP = K//4  # length of the cyclic prefix: 25% of the block

P = 5000 # number of pilot carriers per OFDM block
pilotValue = 3+3j # The known value each pilot transmits

allCarriers = np.arange(K)  # indices of all subcarriers ([0, 1, ... K-1])

pilotCarriers = allCarriers[::K//P] # Pilots is every (K/P)th carrier.

print(pilotCarriers)

# For convenience of channel estimation, let's make the last carriers also be a pilot
pilotCarriers = np.hstack([pilotCarriers, np.array([allCarriers[-1]])])
P = P+1

# data carriers are all remaining carriers
dataCarriers = np.delete(allCarriers, pilotCarriers)

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

demapping_table = {v : k for k, v in mapping_table.items()}



OFDM_RX = np.load("waveform_processing/ofdm/data_frame.npy")

OFDM_RX = OFDM_RX - np.mean(OFDM_RX)

# plt.plot(OFDM_RX)
# plt.show()

OFDM_RX_noCP = OFDM_RX


def DFT(OFDM_RX):
    return np.fft.fft(OFDM_RX)
OFDM_demod = DFT(OFDM_RX_noCP)


def channelEstimate(OFDM_demod):
    pilots = OFDM_demod[pilotCarriers]  # extract the pilot values from the RX signal
    Hest_at_pilots = pilots / pilotValue # divide by the transmitted pilot values
    
    # Perform interpolation between the pilot carriers to get an estimate
    # of the channel in the data carriers. Here, we interpolate absolute value and phase 
    # separately
    Hest_abs = scipy.interpolate.interp1d(pilotCarriers, abs(Hest_at_pilots), kind='linear')(allCarriers)
    Hest_phase = scipy.interpolate.interp1d(pilotCarriers, np.angle(Hest_at_pilots), kind='linear')(allCarriers)
    Hest = Hest_abs * np.exp(1j*Hest_phase)
    
    plt.stem(pilotCarriers, abs(Hest_at_pilots), label='Pilot estimates')
    plt.plot(allCarriers, abs(Hest), label='Estimated channel via interpolation')
    plt.title("Channel estimation based on pilots")
    plt.grid(True); plt.xlabel('Carrier index'); plt.ylabel('$|H(f)|$'); plt.legend(fontsize=10)
    plt.show()
    
    return Hest
Hest = channelEstimate(OFDM_demod)

#np.save("waveform_processing/channel_estimations/loopback_channel_est.npy",Hest)


def equalize(OFDM_demod, Hest):
    return OFDM_demod / Hest
    #return OFDM_demod   
equalized_Hest = equalize(OFDM_demod, Hest)


def get_payload(equalized):
    return equalized[dataCarriers]
QAM_est = get_payload(equalized_Hest)
# plt.plot(QAM_est.real, QAM_est.imag, 'bo')
# plt.title("Received Constelation")
# plt.xlabel("Real Part (I)")
# plt.ylabel("Imaginary Part (Q)")
# plt.show()



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


# for qam, hard in zip(QAM_est, hardDecision):
#     plt.plot([qam.real, hard.real], [qam.imag, hard.imag], 'b-o')
#     plt.plot(hardDecision.real, hardDecision.imag, 'ro')
# plt.title("Hard Decision Mapping")
# plt.xlabel("Real Part (I)")
# plt.ylabel("Imaginary Part (Q)")
# plt.show()


bits = np.load("transmitted_data/bits.npy")


def PS(bits):
    return bits.reshape((-1,))
bits_est = PS(PS_est)
print ("Obtained Bit error rate: ", np.sum(abs(bits-bits_est))/len(bits))




