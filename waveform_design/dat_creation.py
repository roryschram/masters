import numpy as np

# Create a short complex array
complex_array = np.array([1+2j, 3+4j, 5+6j], dtype=np.complex64)

# Open a .dat file in binary write mode
with open('waveform_design/test_complex_data.dat', 'wb') as f:
    for sample in complex_array:
        # Write the real part (I) as 32-bit float
        f.write(np.float32(sample.real).tobytes())
        # Write the imaginary part (Q) as 32-bit float
        f.write(np.float32(sample.imag).tobytes())

print("Data has been written to test_complex_data.dat")
