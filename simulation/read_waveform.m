[Iin Qin scale] = loadfersHDF5('Monostatic.h5');  
I_Q_scaled = (Iin + j*Qin)*scale; 
matched = conv(I_Q_scaled,sig); % perform "matched filtering"  
figure(1) %plot output of matched filter  
magnitude = sqrt( imag(matched).^2 + real(matched.^2) ); % get magnitude of complex signal  
plot(magnitude(length(sig):length(magnitude))) % ignore last bit (overlap of convolution)  
hold on 