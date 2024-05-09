import numpy as np
import wave

# Load the WAV file
wav_file = wave.open('data.wav', 'r')

# Read the number of frames
num_frames = wav_file.getnframes()

# Read the raw data
raw_data = wav_file.readframes(num_frames)

# Close the WAV file
wav_file.close()

# Convert raw data to numpy array
raw_data = np.frombuffer(raw_data, dtype=np.int16)

# Separate I and Q components (assuming interleaved I/Q format)
i_data = raw_data[::2]
q_data = raw_data[1::2]

# Calculate the envelope of the signal
envelope = np.abs(i_data + 1j * q_data)

# Modulate the envelope to generate AM signal
modulated_signal = envelope * np.sin(np.linspace(0, 2 * np.pi * 1000, len(envelope)))

# Scale the modulated signal to fit within the range of a 16-bit integer
modulated_signal *= 32767 / np.max(np.abs(modulated_signal))

# Convert to 16-bit integer
modulated_signal = modulated_signal.astype(np.int16)

# Create a new WAV file and write the modulated signal to it
with wave.open('am_signal.wav', 'w') as wav_out:
    wav_out.setnchannels(1)  # Mono
    wav_out.setsampwidth(2)   # 2 bytes (16 bits) per sample
    wav_out.setframerate(44100)  # Sample rate (adjust as needed)
    wav_out.writeframes(modulated_signal.tobytes())
