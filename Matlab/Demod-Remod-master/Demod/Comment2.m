function Comment2(varargin)
% Description: Write comments related to the remodulated DVBT2 frame in the
% Inputs:  L1pre  - IQ data to be written
%          L1post - Number of samples to be written
%          DVBT2     - Carrier Frequency
%          index     - Index of P1 symbol detections (start of main pa
%          Txtfile   - 
%          name      - output filename
%          toggle   - toggle to write header information or not
%          Nsample_location - Byte number where Nsamples is written in rcf file
% Outputs: Remod_comment - toggle to write header information or not
switch nargin
    case 8
        L1pre = varargin{1} ;
        L1post = varargin{2} ;
        P2 = varargin{3};
        i = varargin{4} ;
        Remod = varargin{5} ;
        ChunkNo = varargin{6} ;
        name = varargin{7};
        permission = varargin{8};
        filenameParameters = [name '_Parameters_' '.txt' ];
        
        if (exist('../OutputRCF'))
            filenameParameters = ['../OutputRCF/' filenameParameters];
        else
            mkdir '../OutputRCF'
            filenameParameters = ['../OutputRCF/' filenameParameters];
        end
        
        filenameParameters = fopen(filenameParameters,permission);
        
        fprintf(filenameParameters,'####Frame %u of Chunk number %u #### \r\n',i,ChunkNo);
        fprintf(filenameParameters,'Sampling Frequency = 64e6/7 Hz \r\n');
        fprintf(filenameParameters,'FFT Size: %u \r\n',L1pre.S2);
        fprintf(filenameParameters,'Number of Symbols: %u \r\n',L1pre.numdatasymbols+P2.N_P2);
        fprintf(filenameParameters,'Guard interval: %u \r\n',L1pre.GI);
        fprintf(filenameParameters,'Bandwidth Extended: %u \r\n',L1pre.BW_EXT);
        fprintf(filenameParameters,'Data Pilot Pattern: %s \r\n',L1pre.pilotpattern);
        fprintf(filenameParameters,'\r\n');
        fprintf(filenameParameters,'L1 Post Modulation: %s \r\n',L1pre.L1mod);
        fprintf(filenameParameters,'\r\n');
        fprintf(filenameParameters,'Remodulation Pilots: %u \r\n',Remod.PilotValue);
        fprintf(filenameParameters,'Remodulation Guard: %u \r\n',Remod.Guard);
        
        for i = 1:L1post.config.Num_plp
            
            fprintf(filenameParameters,'PLP %u Modulation: %s \r\n',i,L1post.config.plp(i).plp_mod);
        end
        
        fprintf(filenameParameters,'\r\n');
        fclose(filenameParameters);
    case 4
        i = varargin{1};
        ChunkNo = varargin{2};
        name = varargin{3};
        permission = varargin{4};
        filenameParameters = [name '_Parameters_' '.txt' ];
        
        if (exist('../OutputRCF'))
            filenameParameters = ['../OutputRCF/' filenameParameters];
        else
            mkdir '../OutputRCF'
            filenameParameters = ['../OutputRCF/' filenameParameters];
        end
        
        filenameParameters = fopen(filenameParameters,permission);
        
        fprintf(filenameParameters,'####Frame %u of Chunk number %u #### \r\n',i,ChunkNo);
        fprintf(filenameParameters,'Failure to decode L1 parameters: Moved to next frame \r\n')
end
end
