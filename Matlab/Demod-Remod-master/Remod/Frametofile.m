function Frametofile(Values_remodulated,filenameIQ,filenameParameters,L1pre,L1post,P2,Frameindex,i)
%Description: Write parameters for resampled data in 'Filename_parameters',
%             IQ Data in 'Filename_IQ'
%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2)

%Write Parameters
fprintf(filenameParameters,'####Frame %u #### \r\n',i);
fprintf(filenameParameters,'Sampling Frequency = 64e6/7 Hz \r\n'); 
fprintf(filenameParameters,'Index (start of cyclic prefix for P2 symbol): %u\r\n',Frameindex); 
fprintf(filenameParameters,'FFT Size: %u \r\n',L1pre.S2);
fprintf(filenameParameters,'Number of Symbols: %u \r\n',L1pre.numdatasymbols+P2.N_P2);
fprintf(filenameParameters,'Guard interval: %u \r\n',L1pre.GI);
fprintf(filenameParameters,'Bandwidth Extended: %u \r\n',L1pre.BW_EXT);
fprintf(filenameParameters,'FFT Size: %u \r\n',L1pre.S2);
fprintf(filenameParameters,'\r\n');
fprintf(filenameParameters,'L1 Post Modulation: %s \r\n',L1pre.L1mod);
fprintf(filenameParameters,'\r\n');
for i = L1post.config.Num_plp
    fprintf(filenameParameters,'PLP 1 Modulation: %s \r\n',L1post.config.plp(i).plp_mod);
    fprintf(filenameParameters,'PLP 1 Rotation: %u \r\n',L1post.config.plp(i).plp_rotation);
end

fprintf(filenameParameters,'\r\n');

%Write IQ
fprintf(filenameIQ,'####Frame %u #### \r\n',i);
fprintf(filenameIQ,'%+2.6f+j%+2.6f\r\n',[real(Values_remodulated);imag(Values_remodulated)]);

end