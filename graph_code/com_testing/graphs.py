import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


df = pd.read_csv("graph_code/com_testing/loopback.csv")

attenuation = df["Attenuation"].astype(float).to_numpy()
avg_snr_dB_computed = df["avg_snr_dB_computed"].astype(float).to_numpy()
avg_snr_extrapolated = df["avg_snr_extrapolated"].astype(float).to_numpy()
avg_BER = df["avg_BER"].astype(float).to_numpy()



# plt.plot(snr, ber)
# plt.show()

plt.style.use('seaborn-v0_8')  # or 'ggplot', 'classic', etc.
plt.figure(figsize=(10,6))
plt.plot(avg_snr_extrapolated,avg_BER)

plt.title("Graph showing the relationship between the SNR and BER of \nthe communication system",loc='center',fontsize=15)
plt.xlabel("SNR (dB)")
plt.ylabel("BER (%)")

plt.minorticks_on()  # Enable minor ticks
plt.tick_params(which='major', length=8, width=1)
plt.tick_params(which='minor', length=4, width=1)
plt.grid(True, which='both', alpha=0.3)

plt.tight_layout()
plt.show()

