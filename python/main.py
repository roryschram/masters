import numpy as np
import matplotlib.pyplot as plt

def read_iq_data(file_path):
    with open(file_path, 'rb') as file:
        data = file.read()
        
    # Each sample is 128 bits (16 bytes): 64 bits (8 bytes) for I and 64 bits (8 bytes) for Q
    sample_size = 16  # bytes
    num_samples = len(data) // sample_size
    
    I_data = []
    Q_data = []
    
    for i in range(num_samples):
        start_idx = i * sample_size
        I_bytes = data[start_idx:start_idx + 8]
        Q_bytes = data[start_idx + 8:start_idx + 16]
        
        I_value = np.frombuffer(I_bytes, dtype=np.float64)[0]
        Q_value = np.frombuffer(Q_bytes, dtype=np.float64)[0]
        
        I_data.append(I_value)
        Q_data.append(Q_value)
    
    return np.array(I_data), np.array(Q_data)

# Usage example
file_path = 'data.dat'
I_data, Q_data = read_iq_data(file_path)

plt.plot(I_data)
plt.ylabel('some numbers')
plt.show()

