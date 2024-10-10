import csv
import matplotlib.pyplot as plt

# Function to read the complex numbers from a CSV file
def read_complex_vector_from_csv(filename):
    real_parts = []
    imaginary_parts = []

    with open(filename, mode='r') as file:
        reader = csv.DictReader(file)
        
        # Read the real and imaginary parts from each row
        for row in reader:
            real_parts.append(float(row['Real']))
            imaginary_parts.append(float(row['Imaginary']))

    return real_parts, imaginary_parts

# Function to plot the complex numbers
def plot_complex_vector(real_parts, imaginary_parts):
    # Plot real part
    plt.figure(figsize=(10, 5))
    
    plt.subplot(2, 1, 1)
    plt.plot(real_parts, label='Real Part', color='blue')
    plt.title('Real and Imaginary Parts of Complex Vector')
    plt.ylabel('Real Part')
    plt.grid(True)
    plt.legend()

    # Plot imaginary part
    plt.subplot(2, 1, 2)
    plt.plot(imaginary_parts, label='Imaginary Part', color='red')
    plt.ylabel('Imaginary Part')
    plt.grid(True)
    plt.legend()

    plt.xlabel('Sample Index')
    plt.tight_layout()
    plt.show()

# Main script to read and plot the CSV data
if __name__ == "__main__":
    # File path to the CSV file
    filename = '/Users/roryschram/Documents/Work/masters/usrp_firmware/build/received.csv'

    # Read the CSV file
    real_parts, imaginary_parts = read_complex_vector_from_csv(filename)

    # Plot the real and imaginary parts
    plot_complex_vector(real_parts, imaginary_parts)
