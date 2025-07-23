import numpy as np



transmit_gain_dB = 0
receive_gain_dB = 0
attenuator = 50

transmit_signal = np.load("../masters_large_data/final_testing/com_testing/ofdm_symbol_time.npy")


digital_power = np.mean(np.abs(transmit_signal)**2)
digital_power_dB = 10 * np.log10(digital_power)
transmit_power_dBm = digital_power_dB + transmit_gain_dB -11.5
receive_power_dBm = transmit_power_dBm - attenuator + receive_gain_dB





print(f"The digital power is: {digital_power:.5f} au")
print(f"The digital power in dBFS is: {digital_power_dB:.5f} dBFS")
print(f"The transmit power in dBm is: {transmit_power_dBm:.5f} dBm")
print(f"The receive power in dBm is: {receive_power_dBm:.5f} dBm")