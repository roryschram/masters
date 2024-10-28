import h5py
import numpy as np


with h5py.File("database/database.h5", "a") as f:
    group = f["group"]

    randomData = np.random.rand(1000000)

    group.create_dataset("random_data1", data=randomData)




