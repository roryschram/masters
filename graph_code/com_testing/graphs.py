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
plt.figure(figsize=(10, 6))
plt.plot(attenuation,avg_BER)
plt.scatter(attenuation[::1],avg_BER[::1])


plt.tight_layout()
plt.show()

