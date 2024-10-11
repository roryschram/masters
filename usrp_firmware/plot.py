import csv
import matplotlib.pyplot as plt
import numpy as np

# Function to read the complex numbers from a CSV file
def read_complex_vector_from_csv(filename):
    real_parts = []
    imaginary_parts = []
    complex_data = []

    with open(filename, mode='r') as file:
        reader = csv.DictReader(file)
        
        # Read the real and imaginary parts from each row
        for row in reader:
            real_parts.append(float(row['Real']))
            imaginary_parts.append(float(row['Imaginary']))
            complex_data.append(float(row['Real']) + 1j*float(row['Imaginary']))

    return real_parts, imaginary_parts, complex_data

# Function to plot the complex numbers
def plot_complex_vector(real_parts, imaginary_parts, complex_data):
    # Plot real part

    plt.figure(figsize=(10, 5))

    plt.subplot(3, 1, 1)
    plt.title("Received Data")
    plt.plot(real_parts, label='Real Part', color='blue')
    plt.ylabel('Real Part')
    plt.xlabel('Sample Index')

    # Plot imaginary part
    plt.subplot(3, 1, 2)
    plt.plot(imaginary_parts, label='Imaginary Part', color='red')
    plt.ylabel('Imaginary Part')
    plt.xlabel('Sample Index')

    # Compute the frequency bins
    n = len(complex_data)  # Number of samples
    freq = np.fft.fftshift(np.fft.fftfreq(n, 1/12500000)) # Generate frequency bins


    # Plot FFT
    plt.subplot(3, 1, 3)
    plt.plot(freq,np.abs(np.fft.fftshift(np.fft.fft(complex_data))), label='FFT', color='orange')
    plt.ylabel('Magnitude')
    plt.xlabel('Sample Index')


    plt.tight_layout()
    plt.show()

    #corrected = complex_data * np.exp(-1j*theta)




# Main script to read and plot the CSV data
if __name__ == "__main__":
    # File path to the CSV file
    filename = '/Users/roryschram/Documents/Work/masters/usrp_firmware/build/received.csv'

    # Read the CSV file
    real_parts, imaginary_parts, complex_data = read_complex_vector_from_csv(filename)

    # Plot the real and imaginary parts
    plot_complex_vector(real_parts, imaginary_parts, complex_data)
