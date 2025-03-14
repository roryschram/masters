sig = chirp(1000, 10000, 0.01, 20000, 1);  
I = real(sig);  
Q = imag(sig);  
hdf5write('chirp.h5', '/I/value', I, '/Q/value', Q);  
plot(sig)
