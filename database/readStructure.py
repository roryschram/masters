import h5py

database = h5py.File("../database.hdf5","r")

print(database.name)
print(list(database.keys()))
