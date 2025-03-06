import h5py
import numpy as np
import matplotlib.pyplot as plt
import os
from datetime import datetime, timezone, timedelta
import shutil
import gc


# These are the variables that allow for the user to use previoyusly entered metadata for a captured channel estimation
###################################################################################### 
prev_sample_rate = ""
prev_centre_freq = ""
prev_transmit_gain = ""
prev_receive_gain = ""
prev_target = ""
prev_target_distance = ""
prev_scene_description = ""
has_appened_happened = False
###################################################################################### 


def append_channel_est(path):
    database_path = path
    # Here we read in the saved Numpy array from the latest channel estimation that has been done
    latest_channel_est = np.load("../masters_large_data/received_data/channel_est.npy")
    with open("../masters_large_data/received_data/latest_capture_timestamp.txt","r") as timestamp_file:
        latest_capture_timestamp = int(timestamp_file.readline().strip())

    utc_plus_2 = timezone(timedelta(hours=2))
    dt = datetime.fromtimestamp(latest_capture_timestamp, tz=utc_plus_2)
    timestamp = dt.strftime("%d-%m-%Y %H:%M:%S")


    with h5py.File(database_path, 'r') as hf:
        print(hf)
        h5_tree(hf)
    hf.close()

    print("\n^^^This is the current file structure of the database ^^^")


    input_group = input("\nEnter the group which you would like to enter the data into ('/' for root): ")
    if input_group == "exit":
        return
    
    centre_freq = ""
    sample_rate = ""
    transmit_gain = ""
    receive_gain = ""
    target = ""
    target_distance = ""
    scene_description = ""
    dataset_count = 0

    global prev_centre_freq
    global prev_sample_rate
    global prev_transmit_gain
    global prev_receive_gain
    global prev_target
    global prev_target_distance 
    global prev_scene_description
    global has_appened_happened


    if has_appened_happened == False:
        try:
            with h5py.File(database_path, 'r') as database:
                group = database[input_group]
                dataset_count = sum(1 for name in group if isinstance(group[name], h5py.Dataset))
                print("Epic, the group '"+input_group+"' exists! There are "+str(dataset_count)+" datasets. Therefore if you add another, the name will be "+str(dataset_count+1)+"\n")
                print("The timestamp of the latest channel estimation is: ",timestamp)
            database.close()  
                
                
            selection_happy = ""
            while selection_happy != "y":
                centre_freq = ""
                sample_rate = ""
                transmit_gain = ""
                receive_gain = ""
                target = ""
                target_distance = ""
                scene_description = ""


                while centre_freq == "":
                    centre_freq = input("Enter the centre frequency of the transmit in GHz: ")
                    if centre_freq == "exit":
                        return

                while sample_rate == "":
                    sample_rate = input("Enter the sample rate of the signal in MHz: ")
                    if sample_rate == "exit":
                        return
                
                while transmit_gain == "":
                    transmit_gain = input("Enter the transmit gain: ")
                    if transmit_gain == "exit":
                        return
                

                while receive_gain == "":
                    receive_gain = input("Enter the receive gain: ")
                    if receive_gain == "exit":
                        return
                

                while target == "":
                    target = input("Enter the target type: ")
                    if target == "exit":
                        return
                

                while target_distance == "":
                    target_distance = input("Enter the target distance: ")
                    if target_distance == "exit":
                        return
                

                while scene_description == "":
                    scene_description = input("Enter the scene description: ")
                    if scene_description == "exit":
                        return
                

                selection_happy = input("\n\nYou have chosen the following as metadata for this capture:\ncentre_freq: %s\nsample_rate: %s\ntransmit_gain: %s\nreceive_gain: %s\ntarget: %s\ntarget_distance: %s\nscene_description: %s\n\nIf you are happy with this metadata, then enter 'y' and hit enter. If you don't enter 'y', then the program will request you to enter scene information again: "%(centre_freq,sample_rate,transmit_gain,receive_gain,target,target_distance,scene_description))
                if selection_happy == "exit":
                    return
                    



            with h5py.File(database_path, 'a') as database:
                group = database[input_group]
                name = dataset_count + 1
                d = group.create_dataset(f"{name:03d}", data=latest_channel_est)
                
                # (centre_freq,sample_rate,transmit_gain,receive_gain,target,target_distance,scene_description)
                d.attrs.create("centre_freq",centre_freq)
                d.attrs.create("sample_rate",sample_rate)
                d.attrs.create("transmit_gain",transmit_gain)
                d.attrs.create("receive_gain",receive_gain)
                d.attrs.create("target",target)
                d.attrs.create("target_distance",target_distance)
                d.attrs.create("scene_description",scene_description)
                d.attrs.create("timestamp",timestamp)
                print("Channel estimation succesfully added to the database!")
                
                
                prev_centre_freq = centre_freq
                prev_sample_rate = sample_rate
                prev_transmit_gain = transmit_gain
                prev_receive_gain = receive_gain
                prev_target = target
                prev_target_distance = target_distance
                prev_scene_description = scene_description
                has_appened_happened = True

            database.close()




        except Exception as e:
            print(f"Exception thrown: {e}")
    
    elif has_appened_happened == True:

            with h5py.File(database_path, 'r') as database:
                group = database[input_group]
                dataset_count = sum(1 for name in group if isinstance(group[name], h5py.Dataset))
                print("Epic, the group '"+input_group+"' exists! There are "+str(dataset_count)+" datasets. Therefore if you add another, the name will be "+str(dataset_count+1)+"\n")
            database.close()


            print("\n\nI noticed that you have used the following for the previous capture:\ncentre_freq: %s\nsample_rate: %s\ntransmit_gain: %s\nreceive_gain: %s\ntarget: %s\ntarget_distance: %s\nscene_description: %s\n"%(prev_centre_freq,prev_sample_rate,prev_transmit_gain,prev_receive_gain,prev_target,prev_target_distance,prev_scene_description))
            should_use_same_metadata = input("Enter 'y' if you would like to use this previous capture's metadata for this new capture: ")
            
            if should_use_same_metadata == 'y':
                test123 = 1

            else:    
                selection_happy = ""
                while selection_happy != "y":
                    centre_freq = ""
                    sample_rate = ""
                    transmit_gain = ""
                    receive_gain = ""
                    target = ""
                    target_distance = ""
                    scene_description = ""


                    while centre_freq == "":
                        centre_freq = input("Enter the centre frequency of the transmit in GHz: ")
                        if centre_freq == "exit":
                            return

                    while sample_rate == "":
                        sample_rate = input("Enter the sample rate of the signal in MHz: ")
                        if sample_rate == "exit":
                            return
                    
                    while transmit_gain == "":
                        transmit_gain = input("Enter the transmit gain: ")
                        if transmit_gain == "exit":
                            return
                    

                    while receive_gain == "":
                        receive_gain = input("Enter the receive gain: ")
                        if receive_gain == "exit":
                            return
                    

                    while target == "":
                        target = input("Enter the target type: ")
                        if target == "exit":
                            return
                    

                    while target_distance == "":
                        target_distance = input("Enter the target distance: ")
                        if target_distance == "exit":
                            return
                    

                    while scene_description == "":
                        scene_description = input("Enter the scene description: ")
                        if scene_description == "exit":
                            return
                    

                    selection_happy = input("\n\nYou have chosen the following as metadata for this capture:\ncentre_freq: %s\nsample_rate: %s\ntransmit_gain: %s\nreceive_gain: %s\ntarget: %s\ntarget_distance: %s\nscene_description: %s\n\nIf you are happy with this metadata, then enter 'y' and hit enter. If you don't enter 'y', then the program will request you to enter scene information again: "%(centre_freq,sample_rate,transmit_gain,receive_gain,target,target_distance,scene_description))
                    if selection_happy == "exit":
                        return
                    


            with h5py.File(database_path, 'a') as database:
                group = database[input_group]
                name = dataset_count + 1
                d = group.create_dataset(f"{name:03d}", data=latest_channel_est)
                
                # (centre_freq,sample_rate,transmit_gain,receive_gain,target,target_distance,scene_description)
                d.attrs.create("centre_freq",centre_freq)
                d.attrs.create("sample_rate",sample_rate)
                d.attrs.create("transmit_gain",transmit_gain)
                d.attrs.create("receive_gain",receive_gain)
                d.attrs.create("target",target)
                d.attrs.create("target_distance",target_distance)
                d.attrs.create("scene_description",scene_description)
                d.attrs.create("timestamp",timestamp)
                print("Channel estimation succesfully added to the database!")
                
                
                prev_centre_freq = centre_freq
                prev_sample_rate = sample_rate
                prev_transmit_gain = transmit_gain
                prev_receive_gain = receive_gain
                prev_target = target
                prev_target_distance = target_distance
                prev_scene_description = scene_description
                has_appened_happened = True

            database.close()




def delete_dataset(path):
    database_path = path

    with h5py.File(database_path, 'r') as hf:
        print(hf)
        h5_tree(hf)
    hf.close()

    print("\n^^^This is the current file structure of the database ^^^")

    input_group = input("\nEnter the group which you would like to delete the dataset from ('/' for root): ")


    try:
        with h5py.File(database_path, 'r') as database:
            group = database[input_group]
            dataset_count = sum(1 for name in group if isinstance(group[name], h5py.Dataset))
            print("Epic, the group '"+input_group+"' exists! There are "+str(dataset_count)+" datasets.\n")
            
        database.close()

        with h5py.File(database_path, 'a') as database:
            group = database[input_group]
            dataset_to_delete = input("Enter the name of the dataset that you would like to delete in the '"+input_group+"' group: ")
            user_happy = input("The dataset you entered is %s. If you are sure you want to delete this, enter 'y': "%(dataset_to_delete))

            if user_happy == "y":
                del group[dataset_to_delete]
                print("Dataset %s deleted from group %s"%(dataset_to_delete,input_group))
            else:
                print("User not happy")

        database.close()




    except Exception as e:
        print(f"Exception thrown: {e}")

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
    gc.collect()
    database_path = "../database.hdf5"
    terminal_width = shutil.get_terminal_size().columns




    while True:
        os.system('cls' if os.name == 'nt' else 'clear')
        text = "### Welcome to my HDF5 database program! ###"
        print(text.center(terminal_width))
        
        text = "### Welcome to my HDF5 database program! ###"
        print("Options:\n'exit' - Use to exit program at any point\n't' - ToString, used to display structure of database\n'a' - Appened latest channel estimation\n'd' - Delete a dataset\n")
        user_input = input("Choose an option: ")

        if user_input.lower() == 'exit':
            print("Goodbye!")
            break  # Exit the loop
        elif user_input.lower() == 't':
            os.system('cls' if os.name == 'nt' else 'clear')
            print("You entered 't' which means you want to print/explore the structure of the database\n")
            with h5py.File(database_path, 'r') as hf:
                print(hf)
                h5_tree(hf)
                print("\n^^^This is the current file structure of the database ^^^")
            hf.close()
            input("\nPress enter to return to menu")
        elif user_input.lower() == 'a':
            os.system('cls' if os.name == 'nt' else 'clear')
            print("You entered 'a' which means you want to append the latest channel estimation to the database\n")
            append_channel_est(database_path)
            input("\nPress enter to return to menu")
        elif user_input.lower() == 'd':
            os.system('cls' if os.name == 'nt' else 'clear')
            print("You entered 'd' which means that you want to delete a dataset\n")
            delete_dataset(database_path)
            input("\nPress enter to return to menu")
            




if __name__=="__main__":
    main()


