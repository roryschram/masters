import matplotlib.pyplot as plt
import numpy as np

# Generate x values (independent variable)
x = np.linspace(-30, 30, 800)  # Start, stop, number of points

# Calculate y values (dependent variable)
y1 = ((np.sin(x))/x)

y2 = ((np.sin(x+np.pi*2))/(x+np.pi*2))

y3 = ((np.sin(x-np.pi*2))/(x-np.pi*2))

y4 = ((np.sin(x+np.pi*4))/(x+np.pi*4))

y5 = ((np.sin(x-np.pi*4))/(x-np.pi*4))

# Create the plot
plt.figure(figsize=(8, 6))  # Optional: set the figure size
plt.plot(x, y4, label='Carrier 1')  # Plot the function and add a label
plt.plot(x, y2, label='Carrier 2')  # Plot the function and add a label
plt.plot(x, y1, label='Carrier 3')  # Plot the function and add a label
plt.plot(x, y3, label='Carrier 4')  # Plot the function and add a label
plt.plot(x, y5, label='Carrier 5')  # Plot the function and add a label

# Add labels and title
plt.xlabel('Frequency Spectrum',size=16)
#plt.title('OFDM Waveform',fontsize=14)

# Remove x-axis numbering (tick labels)
plt.xticks([])

# # Show grid
# plt.grid(True)

# Add a legend
plt.legend(loc='upper right')

# Display the plot
plt.show()
