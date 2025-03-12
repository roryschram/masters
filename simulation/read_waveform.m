importH5;


I_Q_scaled = (I_data + j*Q_data);
##plot(real(I_Q_scaled))




matched = conv(I_Q_scaled,sig); % perform "matched filtering"
figure(1) % plot output of matched filter
magnitude = sqrt( imag(matched).^2 + real(matched.^2) ); % get magnitude of complexsignal
plot(magnitude(length(sig):length(magnitude))) % ignore last bit (overlap of convolution)
hold on
