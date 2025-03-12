function xx = chirp(start_freq, end_freq, time, samp_freq, amp)
%% generates a chirp signal that increases linearly from <start_freq> to <end_freq> over <time> seconds.
% <samp_freq> is the sampling frequency
% <amp> is the signal amplitude

 end_freq_comp = (end_freq - start_freq)/(2*time);
 dt =1/samp_freq; % set sampling interval
 tt=0:dt:time; % create vector of time samples
 xx=hilbert(amp*cos(2*pi*(start_freq*tt+end_freq_comp*tt.*tt))); % modulate signal
end
