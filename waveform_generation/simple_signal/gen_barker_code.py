import numpy as np
import matplotlib.pyplot as plt

# Define 13-digit Barker code
barker_13 = np.array([1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1])

# Compute autocorrelation
autocorr = np.correlate(barker_13, barker_13, mode='full')

# X-axis lags
lags = np.arange(-len(barker_13)+1, len(barker_13))

# Plot
plt.figure(figsize=(10, 4))
plt.stem(lags, autocorr, basefmt=" ")
plt.title("Autocorrelation of 13-Digit Barker Code")
plt.xlabel("Lag")
plt.ylabel("Autocorrelation")
plt.grid(True)
plt.tight_layout()
plt.show()
