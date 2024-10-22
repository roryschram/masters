import h5py
import numpy as np


with h5py.File("database/database.hdf5", "r") as f:
    print(f.keys())

    # dset = f['mydataset']
    
    # for i in dset:
    #     print(i)
