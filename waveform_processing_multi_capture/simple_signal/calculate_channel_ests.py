import numpy as np
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pylab as plt
from matplotlib.axes import Axes
import scipy
import scipy.signal
from concurrent.futures import ProcessPoolExecutor

# Import data
dBV_transmit = np.load("../masters_large_data/processing/simple_signal_dBV_transmit.npy")
frequencies = np.load("../masters_large_data/processing/simple_signal_frequencies.npy")


def process_calculate_channel_est(i):
    print(f"Processing capture {i}")
    dBV_receive = np.load(f"../masters_large_data/received_data/multi_receive/data_frames_dBV/data_frame_dBV{i}.npy")
    output_file = f"../masters_large_data/received_data/multi_receive/channel_estimations/channel_est{i}"

    # Work out channel est

    # Inputs
    Fs = 25e6                      # Sampling rate in Hz
    N = 1_000_000                  # FFT length
    fft_data = dBV_receive  # Make sure it's fftshifted

    # Convert frequencies to indices (fftshifted logic)
    indices = np.round((frequencies + Fs/2) / Fs * N).astype(int)

    # Clip to valid index range
    indices = np.clip(indices, 0, N - 1)

    # Extract values
    transmit_carrier_values = dBV_transmit[indices]
    receive_carrier_values = dBV_receive[indices]

    # print(indices)


    channel_est = receive_carrier_values / transmit_carrier_values
    np.save(output_file,channel_est)

    return f"Capture {i} processed."


# Main multiprocessing block
if __name__ == "__main__":
    with ProcessPoolExecutor(max_workers=16) as executor:
        results = list(executor.map(process_calculate_channel_est, range(1, 301)))

    # Print results
    for res in results:
        print(res)


