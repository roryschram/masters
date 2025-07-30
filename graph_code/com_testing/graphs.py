import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


df = pd.read_csv("graph_code/com_testing/loopback.csv")

attenuation = df["Attenuation"].astype(float).to_numpy()
snr = df["avg_snr_dB"].astype(float).to_numpy()
ber = df["avg_BER"].astype(float).to_numpy()

print(plt.style.available)
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
plt.savefig("test.png",dpi=300)
plt.show()
