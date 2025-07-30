import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.axes import Axes
from scipy import signal
from scipy import interpolate
from concurrent.futures import ProcessPoolExecutor



# Input signal parameters here
fs = 25e6
fft_bins = 32768
allCarriers = np.arange(24000)
pilot_value = 3+3j

graphs = True



def read_complex_data_from_dat(filename):
    # Read the binary data
    with open(filename, 'rb') as f:
        data = f.read()

    # Convert the binary data to an array of 32-bit floats
    double_data = np.frombuffer(data, dtype=np.double)

    # Reshape the data into pairs of (I, Q) values
    complex_data = double_data[0::2] + 1j * double_data[1::2]

    return np.array(complex_data)




def process_ingest(i):
    print(f"Processing capture {i}")


    # Get received usrp data
    received_data = read_complex_data_from_dat("../masters_large_data/final_testing/com_testing/raw_captures/receive"+str(i)+".dat")
    # received_data = read_complex_data_from_dat("../masters_large_data/transmitted_data/transmit.dat")
    transmitted_data = read_complex_data_from_dat("../masters_large_data/transmitted_data/transmit.dat")


    received_data = received_data[1000000:]



    # Get correlation
    corr = signal.correlate(received_data,transmitted_data)
    corr_abs = np.abs(corr)

    # Get maximum of correlation
    pos_max = np.argmax(corr_abs)

    # Get corresponding lag value
    # print("Position of start of frame: "+str(pos_max))

    # Extract rough frame
    frame = np.array(received_data[pos_max-fft_bins:pos_max])

    frame = frame - np.mean(frame)


    # === Compute FFT of the OFDM signal (with CP) ===
    spectrum = np.fft.fftshift(np.fft.fft(frame, n=fft_bins))

    # spectrum[16384] = spectrum[16384 + 5]
    # spectrum[len(spectrum)//2] = 0.0001+0.0001j

    spectrum_magnitude_db = 20 * np.log10(np.abs(spectrum)/len(spectrum))  # avoid log(0)

    # Frequency axis in MHz
    freq_axis = np.linspace(-fs/2, fs/2, fft_bins) / 1e6


    pilot_indices_shifted = np.load("../masters_large_data/final_testing/com_testing/pilot_indices_shifted.npy")


    # print(pilot_indices_shifted)


    # print(allCarriers)

    pilot_symbols = np.load("../masters_large_data/final_testing/com_testing/pilot_symbols.npy")
    pilot_indices_shifted = np.load("../masters_large_data/final_testing/com_testing/pilot_indices_shifted.npy")
    pilot_indices = np.load("../masters_large_data/final_testing/com_testing/pilot_indices.npy")

    # print(pilot_indices)
    # print(pilot_indices_shifted)

    # print(str(len(pilot_indices)))
    # print(str(len(pilot_symbols)))

    # print(pilot_symbols)
    def channelEstimate(OFDM_demod):
        pilots = OFDM_demod[pilot_indices]  # extract the pilot values from the RX signal
        Hest_at_pilots = pilots / pilot_symbols # divide by the transmitted pilot values
        
        # Perform interpolation between the pilot carriers to get an estimate
        # of the channel in the data carriers. Here, we interpolate absolute value and phase 
        # separately
        Hest_real = interpolate.interp1d(pilot_indices, np.real(Hest_at_pilots),kind="linear")(allCarriers)
        Hest_imag = interpolate.interp1d(pilot_indices, np.imag(Hest_at_pilots),kind="linear")(allCarriers)
        
        
        Hest_phase = interpolate.interp1d(pilot_indices, np.angle(Hest_at_pilots),kind="linear")(allCarriers)
        Hest = Hest_real + 1j*Hest_imag
        
        # plt.stem(pilotCarriers, np.fft.fftshift(abs(Hest_at_pilots)), label='Pilot estimates')
        # plt.plot(allCarriers, np.abs(Hest), label='Estimated channel via interpolation')
        # plt.title("Channel estimation based on pilots")
        # plt.grid(True); plt.xlabel('Carrier index'); plt.ylabel('$|H(f)|$')
        # plt.show()
        
        return Hest

    all_carriers_shifted = np.load("../masters_large_data/final_testing/com_testing/all_carriers_shifted.npy")


    temp = spectrum[all_carriers_shifted]
    Hest = channelEstimate(temp)


    def equalize(OFDM_demod, Hest):
        return OFDM_demod / Hest
        # return OFDM_demod

    equalized_Hest = equalize(spectrum[all_carriers_shifted], Hest)

    # print(all_carriers_shifted)




    # Noise section
    a = all_carriers_shifted# values to exclude
    b = np.arange(fft_bins)           # full array
    zero_padding_indices = np.setdiff1d(b, a)

    # print(zero_padding_indices)

    # print()

    received_signal_avg_dBV = np.mean(spectrum_magnitude_db[all_carriers_shifted])
    received_noise_avd_dBV = np.mean(spectrum_magnitude_db[zero_padding_indices])
    snr_dB = received_signal_avg_dBV - received_noise_avd_dBV
    snr_linear = 10**(snr_dB/20)

    # print(f"received_signal_avg_dBV: {received_signal_avg_dBV}")
    # print(f"received_noise_avd_dBV: {received_noise_avd_dBV}")

    # print()

    # print(f"snr_dB: {snr_dB:.3f}")
    # print(f"snr_linear: {snr_linear}")




    data_indices = np.setdiff1d(allCarriers, pilot_indices)

    # equalized_Hest_removed_dc_carrier = np.delete(equalized_Hest,len(equalized_Hest)//2)

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


    demapping_table = {v : k for k, v in mapping_table.items()}


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

    QAM_est = np.delete(QAM_est, len(QAM_est)//2)



    # for qam, hard in zip(QAM_est, hardDecision):
    #     plt.plot([qam.real, hard.real], [qam.imag, hard.imag], 'b-o')
    #     plt.plot(hardDecision.real, hardDecision.imag, 'ro')
    # plt.title("Hard Decision Mapping")
    # plt.xlabel("Real Part (I)")
    # plt.ylabel("Imaginary Part (Q)")
    # plt.show()


    # Removed the bit error calc because ti took lots of compute

    bits = np.load("../masters_large_data/final_testing/com_testing/bits.npy")

    temp = bits.reshape((-1,2))
    temp = np.delete(temp, len(temp)//2, axis=0)
    temp = temp.reshape((-1,))
    bits = temp

    PS_est = np.delete(PS_est, len(PS_est)//2, axis=0)


    def PS(bits):
        return bits.reshape((-1,))
    bits_est = PS(PS_est)



    BER = np.sum(bits != bits_est)/len(bits)*100

    # print ("Obtained Bit error rate: " + str(np.sum(bits != bits_est)/len(bits)*100) + "%")

    sent = bits
    recv = bits_est

    # print("Sent: ", ''.join(str(b) for b in sent))
    # print("Recv: ", ''.join(str(b) if b == s else f"\033[91m{b}\033[0m"
    #                      for b, s in zip(recv, sent)))  # red highlight




    return f"{snr_dB:.3f},{BER:.3f},"


# Main multiprocessing block
if __name__ == "__main__":
    with ProcessPoolExecutor(max_workers=16) as executor:
        results = list(executor.map(process_ingest, range(1, 51)))

    # Print results
    out = ""
    for res in results:
        out += res
    print(out)

