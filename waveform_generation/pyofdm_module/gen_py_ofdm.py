#	Copyright (C) 2020 Bernd Porr <mail@berndporr.me.uk>
#                 2021 David Hutchings <david.hutchings@glasgow.ac.uk>

#	This program is free software; you can redistribute it and/or modify
#	it under the terms of the GNU Lesser General Public License as published by
#	the Free Software Foundation; either version 2 of the License, or
#	(at your option) any later version.

#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.

#	You should have received a copy of the GNU Lesser General Public License
#	along with this program; if not, write to the Free Software
#	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# Transmitter and test receiver on the same data
# Transmits a test grey scale image. 

from PIL import Image
import numpy as np
import scipy.io.wavfile as wav
import pyofdm.codec
import pyofdm.nyquistmodem
import matplotlib.pyplot as plt

# load the image
tx_im = Image.open('waveform_generation/pyofdm_module/DC4_300x200.pgm')
Npixels = tx_im.size[0]*tx_im.size[1]
tx_enc = np.array(tx_im, dtype="uint8").flatten()

# We do DVB-T 2k
# https://www.etsi.org/deliver/etsi_en/300700_300799/300744/01.06.01_60/en_300744v010601p.pdf

# Number of total frequency camples
totalFreqSamples = 2048

# Number of useful data carriers / frequency samples
sym_slots = 1512

# QAM Order 
QAMorder = 2

# Total number of bytes per OFDM symbol
nbytes = sym_slots*QAMorder//8

# Distance of the evenly spaced pilots
distanceOfPilots = 12
pilotlist = pyofdm.codec.setpilotindex(nbytes,QAMorder,distanceOfPilots)

ofdm = pyofdm.codec.OFDM(pilotAmplitude = 16/9,
                         nData=nbytes,
                         pilotIndices = pilotlist,
                         mQAM = QAMorder,
                         nFreqSamples = totalFreqSamples)

# add zeros to make data a whole number of symbols
tx_enc = np.append(tx_enc,np.zeros((sym_slots-tx_enc.size)%sym_slots, dtype="uint8"))

complex_signal = np.array([ofdm.encode(tx_enc[i:i+nbytes]) for i in range(0,tx_enc.size,nbytes)])

# Let's add some random length dummy zero data to the start of the signal
complex_signal = np.concatenate((
    np.zeros(np.random.randint(low=1*ofdm.nIFFT,high=2*ofdm.nIFFT),dtype=complex), 
    complex_signal.ravel()))

plt.title("OFDM complex spectrum")
plt.xlabel("Normalised frequencies")
plt.ylabel("Frequency amplitudes")
plt.plot(np.linspace(0,1,len(complex_signal)),(1/len(complex_signal))*np.abs(np.fft.fft(complex_signal)))

base_signal = pyofdm.nyquistmodem.mod(complex_signal)


# save it as a wav file
with open('transmitted_data/transmit.dat', 'wb') as f:
    for sample in base_signal:
        # Write the real part (I) as 64-bit double
        f.write(np.double(sample.real).tobytes())
        # Write the imaginary part (Q) as 64-bit double
        f.write(np.double(sample.imag).tobytes())







plt.figure()
plt.title("OFDM baseband spectrum after Nyquist modulation")
plt.xlabel("Normalised frequencies")
plt.ylabel("Frequency amplitudes")
plt.plot(base_signal)
plt.show()

