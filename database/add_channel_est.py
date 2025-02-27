import h5py
import numpy as np
import matplotlib.pyplot as plt


# # First we must make sure that we really want to add the latest recorded 





# # Path to the hdf5 file
# database_path = "../database.hdf5"


# # Here we read in the saved Numpy array from the latest channel estimation that has been done
# print("...Reading in Numpy array...")
# latest_channel_est = np.load("../masters_large_data/received_data/channel_est.npy")
# print("...Done...")


# # Save the NumPy array to an HDF5 file
# print("...Saving the latest channel estimation to the database...")
# with h5py.File(database_path, 'w') as database:
#     d = database.create_dataset('1', data=latest_channel_est)
#     d.attrs.create("Centre Frequency","2790000000")
#     d.attrs.create("Sample Rate","12500000")
#     d.attrs.create("Transmit Gain","10")
#     d.attrs.create("Receive Gain","30")
#     d.attrs.create("Target","Corner Reflector")
#     d.attrs.create("Target Distance","3")

#     print(d.attrs.keys())

# database.close()
# print("...Done...")


# # Read the NumPy array from the HDF5 file
# print("...Reading the latest channel estimation to the database...")
# with h5py.File(database_path, 'r') as hdf5_file:
#     loaded_array = hdf5_file['1'][:]
# database.close()
# print("...Done...")

# # plt.plot(np.abs(np.fft.fftshift(loaded_array)))
# # plt.show()


# def h5_tree(val, pre=''):
#     items = len(val)
#     for key, val in val.items():
#         items -= 1
#         if items == 0:
#             # the last item
#             if type(val) == h5py._hl.group.Group:
#                 print(pre + '└── ' + key)
#                 h5_tree(val, pre+'    ')
#             else:
#                 try:
#                     print(pre + '└── ' + key + ' (%d)' % len(val))
#                 except TypeError:
#                     print(pre + '└── ' + key + ' (scalar)')
#         else:
#             if type(val) == h5py._hl.group.Group:
#                 print(pre + '├── ' + key)
#                 h5_tree(val, pre+'│   ')
#             else:
#                 try:
#                     print(pre + '├── ' + key + ' (%d)' % len(val))
#                 except TypeError:
#                     print(pre + '├── ' + key + ' (scalar)')

# with h5py.File(database_path, 'r') as hf:
#     print(hf)
#     h5_tree(hf)




# Python main function
def main():
    print("hey there")


if __name__=="__main__":
    main()


