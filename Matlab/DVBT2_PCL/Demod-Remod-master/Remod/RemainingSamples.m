function RemainingSamples(Remaining,i,filenameParameters,filenameIQ)

%Write Parameters
fprintf(filenameParameters,'####Frame %u #### \r\n',i);
fprintf(filenameParameters,'Number of extra samples: %u \r\n',length(Remaining));

%Write IQ
fprintf(filenameIQ,'####Frame %u #### \r\n',i);
fprintf(filenameIQ,'%+2.6f + j%+2.6f\r\n',[real(Remaining);imag(Remaining)]);
end