import h5py


################### It is imperative that this code is not run by mistake, it will overide the current database at create a new one with blank data! #######################



database = h5py.File("../database.hdf5","w")
database.close()

database_path = "../database.hdf5"

with h5py.File(database_path, "a") as hdf5_file:
    # Create a group named "my_group"
    hdf5_file.create_group("seen_data")
    hdf5_file.create_group("unseen_data")





