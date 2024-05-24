function Remod_comment =  Comment(varargin)
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
    case 7
        L1pre = varargin{1} ;
        L1post = varargin{2} ;
        P2 = varargin{3};
        numP1 = varargin{4};
        i = varargin{5} ;
        Remod = varargin{6} ;
        name = varargin{7};
        
        filenameParameters = [name '_Parameters_' '.txt' ];
        
        if (exist('../OutputRCF'))
            filenameParameters = ['../OutputRCF/' filenameParameters];
        else
            mkdir '../OutputRCF'
            filenameParameters = ['../OutputRCF/' filenameParameters];
        end
        
        filenameParameters = fopen(filenameParameters,'a');
        
        fprintf(filenameParameters,'####Frame %u #### \r\n',i);
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
        
        Remod_comment = sprintf('FFT Size: %u ',L1pre.S2);
        Remod_comment = [Remod_comment sprintf('Number of Symbols: %u ',L1pre.numdatasymbols+P2.N_P2)];
        Remod_comment = [Remod_comment sprintf('Guard interval: %u ',L1pre.GI)];
        Remod_comment = [Remod_comment sprintf('Bandwidth Extended: %u ',L1pre.BW_EXT)];
        Remod_comment = [Remod_comment sprintf('L1 Post Modulation: %s',L1pre.L1mod)];
        for i = 1:L1post.config.Num_plp
            Remod_comment = [Remod_comment sprintf('PLP %u Modulation: %s \r\n',i,L1post.config.plp(i).plp_mod)];
        end
    case 2
        i = varargin{1};
        name = varargin{2};
        filenameParameters = [name '_Parameters_' '.txt' ];
        
        if (exist('../OutputRCF'))
            filenameParameters = ['../OutputRCF/' filenameParameters];
        else
            mkdir '../OutputRCF'
            filenameParameters = ['../OutputRCF/' filenameParameters];
            
        end
        
        filenameParameters = fopen(filenameParameters,'a');
        
        fprintf(filenameParameters,'####Frame %u #### \r\n',i);
        fprintf(filenameParameters,'Failure to decode L1 parameters: Moved to next frame \r\n')
        
    otherwise
        L1pre = varargin{1} ;
        L1post = varargin{2} ;
        P2 = varargin{3};
        numP1 = varargin{4};
        i = varargin{5} ;
        Remod = varargin{6} ;      
                
        Remod_comment = sprintf('FFT Size: %u ',L1pre.S2);
        Remod_comment = [Remod_comment sprintf('Number of Frames: %u ',numP1)];
        Remod_comment = [Remod_comment sprintf('Number of Symbols per frame: %u ',L1pre.numdatasymbols+P2.N_P2)];
        Remod_comment = [Remod_comment sprintf('Guard interval: %u ',L1pre.GI)];
        Remod_comment = [Remod_comment sprintf('Bandwidth Extended: %u ',L1pre.BW_EXT)];
        Remod_comment = [Remod_comment sprintf('L1 Post Modulation: %s ',L1pre.L1mod)];
        for i = L1post.config.Num_plp
            Remod_comment = [Remod_comment sprintf('PLP %u Modulation: %s ',i,L1post.config.plp(i).plp_mod)];
        end
        Remod_comment = [Remod_comment sprintf('Remodulation Pilots: %u ',Remod.PilotValue)];
        Remod_comment = [Remod_comment sprintf('Remodulation Guard: %u ',Remod.Guard)];
end
end