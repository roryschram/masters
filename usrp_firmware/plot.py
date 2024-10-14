import matplotlib.pyplot as plt
import numpy as np

# Function to read the complex numbers from a CSV file
def read_complex_vector_from_csv(filename):
    # Read the CSV file using numpy, with "Real" and "Imaginary" as the two columns
    data = np.genfromtxt(filename, delimiter=',', names=['Real', 'Imaginary'],skip_header=True)

    # Create an array of complex numbers: Real + Imaginary * 1j
    complex_array = data['Real'] + 1j * data['Imaginary']

    return complex_array

# Function to plot the complex numbers
def plot_complex_vector(complex_data):
    
    complex_data = complex_data - np.mean(complex_data)
    #Plot real part
    print(complex_data)

    plt.figure(figsize=(10, 5))

    plt.subplot(4, 1, 1)
    plt.title("Received Data")
    plt.plot(np.real(complex_data), label='Real Part', color='blue')
    plt.ylabel('Real Part')
    plt.xlabel('Sample Index')

    # Plot imaginary part
    plt.subplot(4, 1, 2)
    plt.plot(np.imag(complex_data), label='Imaginary Part', color='red')
    plt.ylabel('Imaginary Part')
    plt.xlabel('Sample Index')

    # Compute the frequency bins
    n = len(complex_data) # Number of samples
    freq = np.fft.fftshift(np.fft.fftfreq(n, 1/6250000)) # Generate frequency bins


    # Plot FFT
    plt.subplot(4, 1, 3)
    plt.plot(freq,np.abs(np.fft.fftshift(np.fft.fft(complex_data))), label='FFT', color='orange')
    plt.ylabel('Magnitude')
    plt.xlabel('Sample Index')

    # Plot FFT
    plt.subplot(4, 1, 4)
    plt.plot(np.angle(complex_data))
    plt.ylabel('Magnitude')
    plt.xlabel('Sample Index')
    plt.tight_layout()


    complex_data = complex_data * np.exp(-1j*2*np.pi*0.429)


    plt.figure(figsize=(10, 5))

    plt.subplot(4, 1, 1)
    plt.title("Received Data Corrected")
    plt.plot(np.real(complex_data), label='Real Part', color='blue')
    plt.ylabel('Real Part')
    plt.xlabel('Sample Index')

    # Plot imaginary part
    plt.subplot(4, 1, 2)
    plt.plot(np.imag(complex_data), label='Imaginary Part', color='red')
    plt.ylabel('Imaginary Part')
    plt.xlabel('Sample Index')

    # Compute the frequency bins
    n = len(complex_data)  # Number of samples
    freq = np.fft.fftshift(np.fft.fftfreq(n, 1/6250000)) # Generate frequency bins


    # Plot FFT
    plt.subplot(4, 1, 3)
    plt.plot(freq,np.abs(np.fft.fftshift(np.fft.fft(complex_data))), label='FFT', color='orange')
    plt.ylabel('Magnitude')
    plt.xlabel('Sample Index')

    # Plot FFT
    plt.subplot(4, 1, 4)
    plt.plot(np.angle(complex_data))
    plt.ylabel('Magnitude')
    plt.xlabel('Sample Index')
    plt.tight_layout()


    plt.figure(figsize=(10, 5))

    fft = np.abs(np.fft.fftshift(np.fft.fft(complex_data)))

    for i in range(0,len(complex_data),1):
        if fft[i] < 40:
            complex_data[i] = 0+0j

    # Plot FFT
    plt.subplot(1, 1, 1)
    plt.scatter(np.real(complex_data),np.imag(complex_data))
    plt.ylabel('Magnitude')
    plt.xlabel('Sample Index')
    plt.tight_layout()

    
    
    plt.show()





# Main script to read and plot the CSV data
if __name__ == "__main__":
    # File path to the CSV file
    filename = '/Users/roryschram/Documents/Work/masters/usrp_firmware/build/received.csv'

    # Read the CSV file
    complex_data = read_complex_vector_from_csv(filename)

    # Plot the real and imaginary parts
    plot_complex_vector(complex_data)
