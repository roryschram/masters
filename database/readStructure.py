import h5py

# Function to recursively print the structure of the HDF5 file
def print_structure(name, obj):
    if isinstance(obj, h5py.Group):
        print(f"Group: {name}")
    elif isinstance(obj, h5py.Dataset):
        print(f"Dataset: {name}, Shape: {obj.shape}, DataType: {obj.dtype}")

# Open the HDF5 file in read mode
with h5py.File("database/database.h5", "r") as file:  # Replace 'example.h5' with your file
    # Use the 'visititems' method to visit all groups and datasets
    file.visititems(print_structure)
