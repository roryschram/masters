import h5py
import numpy as np

# Add a dataset
with h5py.File("database/database.hdf5", "w") as f:
    dset = f.create_dataset("test", (10,), dtype=np.double)