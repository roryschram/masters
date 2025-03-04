import h5py
import numpy as np
import matplotlib.pyplot as plt
import os


def append_channel_est(path):
    database_path = path
    # Here we read in the saved Numpy array from the latest channel estimation that has been done
    latest_channel_est = np.load("../masters_large_data/received_data/channel_est.npy")

    with h5py.File(database_path, 'r') as hf:
        print(hf)
        h5_tree(hf)
    hf.close()

    print("\n^^^This is the current file structure of the database ^^^")

    input_group = input("\nEnter the group which you would like to enter the data into ('/' for root. Not reccomended): ")

    centre_freq = ""
    sample_rate = ""
    transmit_gain = ""
    receive_gain = ""
    target = ""
    target_distance = ""
    scene_description = ""

    try:
        with h5py.File(database_path, 'r') as database:
            group = database[input_group]
            dataset_count = sum(1 for name in group if isinstance(group[name], h5py.Dataset))
            print("Epic, the group '"+input_group+"' exists! There are "+str(dataset_count)+" datasets.\n")

            centre_freq = input("Enter the centre frequency of the transmit: ")
            sample_rate = input("Enter the sample rate of the signal: ")
            transmit_gain = input("Enter the transmit gain: ")
            receive_gain = input("Enter the receive gain: ")
            target = input("Enter the target type: ")
            target_distance = input("Enter the target distance: ")
            scene_description = input("Enter the scene description: ")


    except Exception as e:
        print(f"Exception thrown: {e}")
    


    database.close()






    # try:
    #     with h5py.File(database_path, 'a') as database:
    #         group = database["seen_data"]
    #         d = group.create_dataset('6', data=latest_channel_est)
    #         d.attrs.create("Centre Frequency","2790000000")
    #         d.attrs.create("Sample Rate","12500000")
    #         d.attrs.create("Transmit Gain","10")
    #         d.attrs.create("Receive Gain","30")
    #         d.attrs.create("Target","Corner Reflector")
    #         d.attrs.create("Target Distance","3")

    #         print(d.attrs.keys())

    # except Exception as e:
    #     print(f"Exception thrown: {e}")
    

    # database.close()
    print("...Done...")


# # Read the NumPy array from the HDF5 file
# print("...Reading the latest channel estimation to the database...")
# with h5py.File(database_path, 'r') as hdf5_file:
#     loaded_array = hdf5_file['1'][:]
# database.close()
# print("...Done...")

# # plt.plot(np.abs(np.fft.fftshift(loaded_array)))
# # plt.show()


def h5_tree(val, pre=''):
    items = len(val)
    for key, val in val.items():
        items -= 1
        if items == 0:
            # the last item
            if type(val) == h5py._hl.group.Group:
                print(pre + '└── ' + key)
                h5_tree(val, pre+'    ')
            else:
                try:
                    print(pre + '└── ' + key + ' (%d)' % len(val))
                except TypeError:
                    print(pre + '└── ' + key + ' (scalar)')
        else:
            if type(val) == h5py._hl.group.Group:
                print(pre + '├── ' + key)
                h5_tree(val, pre+'│   ')
            else:
                try:
                    print(pre + '├── ' + key + ' (%d)' % len(val))
                except TypeError:
                    print(pre + '├── ' + key + ' (scalar)')






# Python main function
def main():
    database_path = "../database.hdf5"




    while True:
        os.system('cls' if os.name == 'nt' else 'clear')
        user_input = input("Options (or type 'exit' to quit) - 't' = ToString (read/explore structure of database) - 'a' = Appened (append latest channel estimation to database) - 'd' = Delete (delete last appended channel estimation to database):")

        if user_input.lower() == 'exit':
            print("Goodbye!")
            break  # Exit the loop
        elif user_input.lower() == 't':
            os.system('cls' if os.name == 'nt' else 'clear')
            print("You entered 't' which means you want to print/explore the structure of the database\n")
            with h5py.File(database_path, 'r') as hf:
                print(hf)
                h5_tree(hf)
            hf.close()
            input("\nPress enter to return to menu")
        elif user_input.lower() == 'a':
            os.system('cls' if os.name == 'nt' else 'clear')
            print("You entered 'a' which means you want to append the latest channel estimation to the database\n")
            append_channel_est(database_path)
            input("\nPress enter to return to menu")
        elif user_input.lower() == 'd':
            os.system('cls' if os.name == 'nt' else 'clear')
            print("You entered 'd'")
            input()
            




if __name__=="__main__":
    main()


