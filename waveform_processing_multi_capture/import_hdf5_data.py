import matplotlib.pyplot as plt
plt.rcParams['figure.figsize'] = (10, 4)
plt.rcParams['figure.dpi'] = 300

import numpy as np
import scipy
import h5py

from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from scipy.signal import decimate



# Read the NumPy array from the HDF5 file
with h5py.File("../database.hdf5", 'r') as hdf5_file:
    capture1 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["001"])))
    capture2 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["002"])))
    capture3 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["003"])))
    capture4 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["004"])))
    capture5 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["005"])))
    capture6 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["006"])))
    capture7 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["007"])))
    capture8 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["008"])))
    capture9 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["009"])))
    capture10 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["010"])))

    capture11 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["011"])))
    capture12 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["012"])))
    capture13 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["013"])))
    capture14 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["014"])))
    capture15 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["015"])))
    capture16 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["016"])))
    capture17 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["017"])))
    capture18 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["018"])))
    capture19 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["019"])))
    capture20 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["020"])))

    capture21 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["021"])))
    capture22 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["022"])))
    capture23 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["023"])))
    capture24 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["024"])))
    capture25 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["025"])))
    capture26 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["026"])))
    capture27 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["027"])))
    capture28 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["028"])))
    capture29 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["029"])))
    capture30 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["030"])))

    capture31 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["031"])))
    capture32 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["032"])))
    capture33 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["033"])))
    capture34 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["034"])))
    capture35 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["035"])))
    capture36 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["036"])))
    capture37 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["037"])))
    capture38 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["038"])))
    capture39 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["039"])))
    capture40 = np.fft.fftshift(np.abs(np.array(hdf5_file["seen_data"]["040"])))
hdf5_file.close()


# Put them in a dictionary with names as keys
variables = {
    'channel_est1.npy': capture1,
    'channel_est2.npy': capture2,
    'channel_est3.npy': capture3,
    'channel_est4.npy': capture4,
    'channel_est5.npy': capture5,
    'channel_est6.npy': capture6,
    'channel_est7.npy': capture7,
    'channel_est8.npy': capture8,
    'channel_est9.npy': capture9,
    'channel_est10.npy': capture10,
    'channel_est11.npy': capture11,
    'channel_est12.npy': capture12,
    'channel_est13.npy': capture13,
    'channel_est14.npy': capture14,
    'channel_est15.npy': capture15,
    'channel_est16.npy': capture16,
    'channel_est17.npy': capture17,
    'channel_est18.npy': capture18,
    'channel_est19.npy': capture19,
    'channel_est20.npy': capture20,
    'channel_est21.npy': capture21,
    'channel_est22.npy': capture22,
    'channel_est23.npy': capture23,
    'channel_est24.npy': capture24,
    'channel_est25.npy': capture25,
    'channel_est26.npy': capture26,
    'channel_est27.npy': capture27,
    'channel_est28.npy': capture28,
    'channel_est29.npy': capture29,
    'channel_est30.npy': capture30,
    'channel_est31.npy': capture31,
    'channel_est32.npy': capture32,
    'channel_est33.npy': capture33,
    'channel_est34.npy': capture34,
    'channel_est35.npy': capture35,
    'channel_est36.npy': capture36,
    'channel_est37.npy': capture37,
    'channel_est38.npy': capture38,
    'channel_est39.npy': capture39,
    'channel_est40.npy': capture40
    
}


# Loop through and save each as a .npy file
for name, data in variables.items():
    np.save("../masters_large_data/received_data/multi_receive/channel_estimations/"+name, data)