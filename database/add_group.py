import h5py

database_path = "../database.hdf5"

with h5py.File(database_path, "a") as hdf5_file:
    # Create a group named "my_group"
    hdf5_file.create_group("unseen_data")