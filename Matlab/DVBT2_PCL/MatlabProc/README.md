# MatlabProc

For simulated reference data see: ftp://ftp.kw.bbc.co.uk/t2refs//

Takes in raw data, demodulates it and produces a range-Doppler map

Can be used to perform demod-remod on a DVB-T2 frame (see frame extraction code)

Can add simulated targets or perform basic pilot jamming

Can create ARD using either:
- Mismatched filtering with or without CGLS cancellation
- Inverse filtering with or without ECA-CD

ARD saved and can be viewed later