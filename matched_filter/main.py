import numpy as np
import matplotlib.pyplot as plt
import time




def main():
    # Parameters for the sine wave
    frequency = 1500  # Frequency in Hz
    sampling_rate = 40000  # Samples per second
    duration = 0.1  # Duration in seconds

    # Generate the sine wave
    t = np.linspace(0, duration, int(sampling_rate * duration), endpoint=False)
    sine_wave = np.sin(2 * np.pi * frequency * t)

    # Padding with zeros on both sides
    padding_length = 200000  # Adjust this to change the padding length
    padded_sine_wave = np.pad(sine_wave, (padding_length, padding_length), 'constant')




    # Adding AWGN
    mean = 0
    std_dev = 1

    # Generate white Gaussian noise
    noise = np.random.normal(mean, std_dev, padded_sine_wave.shape)

    # Add the noise to the signal
    noisy_padded_sine_wave = padded_sine_wave + noise


    # Trying to do some matched filtering
    matched_filter_output = np.correlate(sine_wave, noisy_padded_sine_wave)

    print("Actual position of sine wave: 20000")
    print("Position of sine wave from macthed filter: "+ str(np.argmax(matched_filter_output)))


    # Generate a new time axis to accommodate the padding
    t_padded = np.linspace(-padding_length/sampling_rate, duration + padding_length/sampling_rate, len(padded_sine_wave), endpoint=False)

    fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(12, 7))

    # Plot real and imaginary parts on the first axis (Received Data)
    ax1.plot(padded_sine_wave, label='Padded Sine Wave')
    ax1.set_xlabel('Time (s)')
    ax1.set_ylabel('Amplitude')
    ax1.set_title('Sine Wave with Zeros Padded on Either Side')
    ax1.legend()
    ax1.grid(True)

    # Plot real and imaginary parts on the first axis (Received Data)
    ax2.plot(noisy_padded_sine_wave, label='Padded Sine Wave')
    ax2.set_xlabel('Time (s)')
    ax2.set_ylabel('Amplitude')
    ax2.set_title('Sine Wave with Zeros Padded on Either Side with Noise')
    ax2.legend()
    ax2.grid(True)

    # Plot real and imaginary parts on the first axis (Received Data)
    ax3.plot(matched_filter_output, label='Padded Sine Wave')
    ax3.set_xlabel('Time (s)')
    ax3.set_ylabel('Amplitude')
    ax3.set_title('Matched Filter Output')
    ax3.legend()
    ax3.grid(True)

    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    main()
