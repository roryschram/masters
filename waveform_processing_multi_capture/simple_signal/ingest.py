import numpy as np
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pylab as plt
from matplotlib.axes import Axes
import scipy
import scipy.signal
from concurrent.futures import ProcessPoolExecutor

# Function to read complex data from given filename
def read_complex_data_from_dat(filename):
    # Read the binary data
    with open(filename, 'rb') as f:
        data = f.read()

    # Convert the binary data to an array of 32-bit floats
    double_data = np.frombuffer(data, dtype=np.double)

    # Reshape the data into pairs of (I, Q) values
    complex_data = double_data[0::2] + 1j * double_data[1::2]

    return complex_data


# Get the original transmitted clean pulse
transmitted_data = np.array(read_complex_data_from_dat("../masters_large_data/transmitted_data/transmit.dat"))


def process_ingest(i):
    print(f"Processing capture {i}")

    input_file = f"../masters_large_data/received_data/multi_receive/raw_captures/receive{i}.dat"
    output_file_symbol = f"../masters_large_data/received_data/multi_receive/data_frames/data_frame{i}.npy"
    output_file_dBV = f"../masters_large_data/received_data/multi_receive/data_frames_dBV/data_frame_dBV{i}.npy"

    # Read raw data
    received_data = np.array(read_complex_data_from_dat(input_file))


    # Perform a correlation using scipy for fft correlation (speed)
    correlation = scipy.signal.correlate(received_data,transmitted_data,mode='same')
    correlation_abs = np.abs(correlation)

    # Save correlation
    np.save(f"../masters_large_data/received_data/multi_receive/correlations/correlation{i}.npy",correlation)

    # print(len(correlation))
    
    # Get the largest value of the correlation --> start of received data
    pos_start_frame = np.argmax(correlation_abs)
    start_frame_val = np.max(correlation_abs)
    start_frame_val_time = received_data[pos_start_frame]

    # print(str(pos_start_frame)+","+str(start_frame_val))
    
    # print(len(received_data))
    # print(pos_start_frame)

    # get the symbol
    symbol = np.array(received_data[pos_start_frame-500000:pos_start_frame+500000])

    # print(len(received_data))

    # Normalize to avoid clipping or excessive amplitude
    normalize_ratio = np.max(np.abs(symbol))
    symbol /= normalize_ratio

    # print("Normalization Ratio: "+str(round(normalize_ratio,20)))


    # Save the symbol for later processing
    np.save(output_file_symbol,symbol)

    fft_vals = np.fft.fft(symbol)
    fft_vals_abs = np.abs(fft_vals)
    dBV = np.fft.fftshift(20 * np.log10(fft_vals_abs + 1e-12))

    np.save(output_file_dBV,dBV)

    return f"Capture {i} processed."


# Main multiprocessing block
if __name__ == "__main__":
    with ProcessPoolExecutor(max_workers=16) as executor:
        results = list(executor.map(process_ingest, range(201, 251)))

    # Print results
    for res in results:
        print(res)

