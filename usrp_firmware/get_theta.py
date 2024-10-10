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

    # real_parts = real_parts - np.mean(real_parts)
    # imaginary_parts = imaginary_parts - np.mean(imaginary_parts)
    # complex_data = complex_data - np.mean(complex_data)

    return real_parts, imaginary_parts, complex_data

# Main script to read and plot the CSV data
if __name__ == "__main__":
    # File path to the CSV file
    filename = '/Users/roryschram/Documents/Work/masters/usrp_firmware/build/received.csv'

    # Read the CSV file
    real_parts, imaginary_parts, complex_data = read_complex_vector_from_csv(filename)

    theta = np.angle(complex_data)

    np.save("phase_rotation.npy",theta)
