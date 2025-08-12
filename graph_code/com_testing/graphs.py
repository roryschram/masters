import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


df = pd.read_csv("graph_code/com_testing/loopback.csv")
df1 = pd.read_csv("graph_code/com_testing/loopback_snr_calced.csv")

attenuation = df["Attenuation"].astype(float).to_numpy()
snr = df["avg_snr_dB"].astype(float).to_numpy()
ber = df["avg_BER"].astype(float).to_numpy()

attenuation1 = df1["Attenuation"].astype(float).to_numpy()
snr1 = df1["avg_snr_dB"].astype(float).to_numpy()
ber1 = df1["avg_BER"].astype(float).to_numpy()


# plt.plot(snr, ber)
# plt.show()

plt.style.use('seaborn-v0_8')  # or 'ggplot', 'classic', etc.
plt.figure(figsize=(10, 6))
plt.plot(attenuation,ber)
plt.scatter(attenuation[::1],ber[::1])


for x,y,snr in zip(attenuation[::1],ber[::1],snr[::1]):
    plt.text(x,y,str(snr))


plt.xlabel("Attenuation (dB)")
plt.gca().invert_xaxis()


plt.ylabel("BER (%)")
plt.title("Graph: To show the relationship between attenuation of a communication signal\nand the bit error rate achived for a loopback test")

plt.tight_layout()
plt.show()





plt.style.use('seaborn-v0_8')  # or 'ggplot', 'classic', etc.
plt.figure(figsize=(10, 6))
plt.plot(snr1,ber1)


plt.xlabel("SNR (dB)")
# plt.gca().invert_xaxis()


plt.ylabel("BER (%)")
plt.title("Graph: To show the relationship between attenuation of a communication signal\nand the bit error rate achived for a loopback test")

plt.tight_layout()
plt.show()
