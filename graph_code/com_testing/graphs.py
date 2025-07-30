import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


df = pd.read_csv("graph_code/com_testing/loopback.csv")


plt.plot(df["Attenuation"],df["avg_BER"])
plt.scatter(df["Attenuation"][::2],df["avg_BER"][::2])


plt.xlabel("Attenuation (dB)")
plt.gca().invert_xaxis()


plt.ylabel("BER (%)")
plt.show()