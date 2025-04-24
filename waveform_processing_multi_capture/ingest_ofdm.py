import numpy as np
import matplotlib.pylab as plt
import scipy
import scipy.signal
from concurrent.futures import ProcessPoolExecutor

def read_complex_data_from_dat(filename):
    # Read the binary data
    with open(filename, 'rb') as f:
        data = f.read()

    # Convert the binary data to an array of 32-bit floats
    double_data = np.frombuffer(data, dtype=np.double)

    # Reshape the data into pairs of (I, Q) values
    complex_data = double_data[0::2] + 1j * double_data[1::2]

    return complex_data


# Get the original pulse
transmitted_data = np.load("../masters_large_data/transmitted_data/original_OFDM_pulse.npy")


def process_capture(i):
    print(f"Processing capture {i}")

    input_file = f"../masters_large_data/received_data/multi_receive/raw_captures/receive{i}.dat"
    output_file = f"../masters_large_data/received_data/multi_receive/data_frames/data_frame{i}.npy"

    # Read raw data
    received_data = read_complex_data_from_dat(input_file)

    # Cross-correlation
    correlation = scipy.signal.correlate(received_data, transmitted_data)
    correlation_abs = np.abs(correlation)
    first_max = np.argmax(correlation_abs)

    # Extract aligned frame
    start_index = max(0, first_max - 5000000)  # Avoid negative indexing
    data_frame = received_data[start_index:first_max]

    # Save to file
    np.save(output_file, data_frame)

    return f"Capture {i} processed."

# Main multiprocessing block
if __name__ == "__main__":
    with ProcessPoolExecutor(max_workers=4) as executor:
        results = list(executor.map(process_capture, range(1, 3)))

    # Print results
    for res in results:
        print(res)
