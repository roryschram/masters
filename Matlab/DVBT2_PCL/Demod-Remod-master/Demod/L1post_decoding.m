function L1post = L1post_decoding(LLRChannel,L1pre)
%Description:Remove Zero Padding, Descramble and Decode
% Inputs: LLRChannel - L1post bits
%         P2 - P2 Parameters
%         L1pre - L1 pre parameters
% Ouputs: L1post - L1 post parameters
% Reference:

%1. L1 post decoding
%Configurable
L1post.config.Sub_slices_per_frame = LLRChannel(1:15);
L1post.config.Sub_slices_per_frame = bi2de(L1post.config.Sub_slices_per_frame,'left-msb');%Number of subslices per T2 Frame
L1post.config.Num_plp = LLRChannel(16:23);
L1post.config.Num_plp = bi2de(L1post.config.Num_plp,'left-msb'); %Number of PLPs
L1post.config.Num_Aux = bi2de(LLRChannel(24:27),'left-msb'); %Number of auxilliary streams
L1post.config.Aux_config_rfu = LLRChannel(28:35);%Reserved for future use
L1post.config.Aux_config_rfu = 'Reserved for Future Use';
index = 36;

numrf= bi2de(L1pre.numrf.','left-msb');
for i = 1:numrf
    L1post.config.rf(i).rf_idx = bi2de(LLRChannel(index:index+2),'left-msb'); % RF index (between 0 and NUMRF-1)
    index=index+3;
    L1post.config.rf(i).frequency = bi2de(LLRChannel(index:index+31),'left-msb'); % Frequency in Hz
    index=index+32;
end

if L1pre.FEF==1
    L1post.config.fef_type = bi2de(LLRChannel(index:index+3),'left-msb');
    L1post.config.fef_type = 'Reserved for Future Use';
    index=index+4;
    L1post.config.fef_length = bi2de(LLRChannel(index:index+21),'left-msb'); % length of FEF in samples (Fs = 1/T)
    index=index+22;
    L1post.config.fef_interval = bi2de(LLRChannel(index:index+7),'left-msb'); % Number of T2 Frames between two FEF parts
    index=index+8;
end

for i = 1:L1post.config.Num_plp
    L1post.config.plp(i).plp_id = bi2de(LLRChannel(index:index+7),'left-msb');
    index = index+8;
    L1post.config.plp(i).plp_type = LLRChannel(index:index+2);
    index=index+3;
    if isequal(L1post.config.plp(i).plp_type,[0 0 0])
        L1post.config.plp(i).plp_type = 'Common PLP';
    elseif isequal(L1post.config.plp(i).plp_type,[0 0 1])
        L1post.config.plp(i).plp_type = 'Type 1 PLP';
    elseif isequal(L1post.config.plp(i).plp_type,[0 1 0])
        L1post.config.plp(i).plp_type = 'Type 2 PLP';
    else
        L1post.config.plp(i).plp_type = 'Undefined';
    end
    
    L1post.config.plp(i).payload_type = LLRChannel(index:index+4);
    index=index+5;
    if isequal(L1post.config.plp(i).payload_type,[0 0 0 0 0])
        L1post.config.plp(i).payload_type = 'GFPS';
    elseif isequal(L1post.config.plp(i).payload_type,[0 0 0 0 1])
        L1post.config.plp(i).payload_type = 'GCS';
    elseif isequal(L1post.config.plp(i).payload_type,[0 0 0 1 0])
        L1post.config.plp(i).payload_type = 'GSE';
    elseif isequal(L1post.config.plp(i).payload_type,[0 0 0 1 1])
        L1post.config.plp(i).payload_type = 'TS';
    else
        L1post.config.plp(i).payload_type = 'Undefined';
    end
    
    L1post.config.plp(i).ff_flag = LLRChannel(index);
    index=index+1;
    L1post.config.plp(i).first_rf_idx = LLRChannel(index:index+2);
    index=index+3;
    L1post.config.plp(i).first_frame_idx = bi2de(LLRChannel(index:index+7),'left-msb'); % indicates first frame in which PLP appears
    index=index+8;
    L1post.config.plp(i).plp_group_id = LLRChannel(index:index+7);
    index=index+8;
    L1post.config.plp(i).plp_cod = LLRChannel(index:index+2);
    index=index+3;
    
    if isequal(L1post.config.plp(i).plp_cod,[0 0 0])
         L1post.config.plp(i).plp_cod = 1/2;
    elseif isequal(L1post.config.plp(i).plp_cod,[0 0 1])
         L1post.config.plp(i).plp_cod = 3/5;
    elseif isequal(L1post.config.plp(i).plp_cod,[0 1 0])
         L1post.config.plp(i).plp_cod = 2/3;
    elseif isequal(L1post.config.plp(i).plp_cod,[0 1 1])
         L1post.config.plp(i).plp_cod = 3/4;
    elseif isequal(L1post.config.plp(i).plp_cod,[1 0 0])
        L1post.config.plp(i).plp_cod = 4/5;
    elseif isequal(L1post.config.plp(i).plp_cod,[1 0 1])
         L1post.config.plp(i).plp_cod = 5/6;
    else
        L1post.config.plp(i).plp_cod = 'Undefined';
    end
    
    L1post.config.plp(i).plp_mod = LLRChannel(index:index+2); % defines modulation on plp
    index=index+3;
    
    if isequal(L1post.config.plp(i).plp_mod, [0 0 0])
        L1post.config.plp(i).plp_mod = 'QPSK';
        L1post.config.plp(i).plp_Cpoints =  [1+1i 1-1i -1+1i -1-1i]; % Constellation points
        L1post.config.plp(i).plp_C = sqrt(2);                 % Normalization factor
        L1post.config.plp(i).plp_V = 2;                       % Bits per cell       
    elseif isequal(L1post.config.plp(i).plp_mod, [0 0 1])
        L1post.config.plp(i).plp_mod = '16-QAM';
        L1post.config.plp(i).plp_Cpoints = [3+3i 3+1i 1+3i 1+1i 3-3i 3-1i 1-3i 1-1i -3+3i -3+1i -1+3i ...
                                            -1+1i -3-3i -3-1i -1-3i -1-1i];
        L1post.config.plp(i).plp_C = sqrt(10);
        L1post.config.plp(i).plp_V = 4;                           
    elseif isequal(L1post.config.plp(i).plp_mod, [0 1 0])
        L1post.config.plp(i).plp_mod = '64-QAM';
        L1post.config.plp(i).plp_Cpoints = [7+7i 7+5i 5+7i 5+5i 7+1i 7+3i 5+1i 5+3i 1+7i 1+5i 3+7i ...
                                            3+5i 1+1i 1+3i 3+1i 3+3i 7-7i 7-5i 5-7i 5-5i 7-1i 7-3i ...
                                            5-1i 5-3i 1-7i 1-5i 3-7i 3-5i 1-1i 1-3i 3-1i 3-3i -7+7i ...
                                            -7+5i -5+7i -5+5i -7+1i -7+3i -5+1i -5+3i -1+7i -1+5i ... 
                                            -3+7i -3+5i -1+1i -1+3i -3+1i -3+3i -7-7i -7-5i -5-7i ...
                                            -5-5i -7-1i -7-3i -5-1i -5-3i -1-7i -1-5i -3-7i -3-5i ...
                                            -1-1i -1-3i -3-1i -3-3i];
        L1post.config.plp(i).plp_C = sqrt(42);
        L1post.config.plp(i).plp_V = 6;     
    elseif isequal(L1post.config.plp(i).plp_mod, [0 1 1])
        L1post.config.plp(i).plp_mod = '256-QAM';
        L1post.config.plp(i).plp_Cpoints = [ +15+15i, +15+13i, +13+15i, +13+13i, +15+9i, +15+11i, +13+9i, +13+11i, ...
                                         +9+15i, +9+13i, +11+15i, +11+13i, +9+9i, +9+11i, +11+9i, +11+11i, ...
                                         +15+1i, +15+3i, +13+1i, +13+3i, +15+7i, +15+5i, +13+7i, +13+5i, ...
                                         +9+1i, +9+3i, +11+1i, +11+3i, +9+7i, +9+5i, +11+7i, +11+5i, ...
                                         +1+15i, +1+13i, +3+15i, +3+13i, +1+9i, +1+11i, +3+9i, +3+11i, ...
                                         +7+15i, +7+13i, +5+15i, +5+13i, +7+9i, +7+11i, +5+9i, +5+11i, ...
                                         +1+1i, +1+3i, +3+1i, +3+3i, +1+7i, +1+5i, +3+7i, +3+5i, ...
                                         +7+1i, +7+3i, +5+1i, +5+3i, +7+7i, +7+5i, +5+7i, +5+5i, ...
                                         +15-15i, +15-13i, +13-15i, +13-13i, +15-9i, +15-11i, +13-9i, +13-11i, ...
                                         +9-15i, +9-13i, +11-15i, +11-13i, +9-9i, +9-11i, +11-9i, +11-11i, ...
                                         +15-1i, +15-3i, +13-1i, +13-3i, +15-7i, +15-5i, +13-7i, +13-5i, ...
                                         +9-1i, +9-3i, +11-1i, +11-3i, +9-7i, +9-5i, +11-7i, +11-5i, ...
                                         +1-15i, +1-13i, +3-15i, +3-13i, +1-9i, +1-11i, +3-9i, +3-11i, ...
                                         +7-15i, +7-13i, +5-15i, +5-13i, +7-9i, +7-11i, +5-9i, +5-11i, ...
                                         +1-1i, +1-3i, +3-1i, +3-3i, +1-7i, +1-5i, +3-7i, +3-5i, ...
                                         +7-1i, +7-3i, +5-1i, +5-3i, +7-7i, +7-5i, +5-7i, +5-5i, ...
                                         -15+15i, -15+13i, -13+15i, -13+13i, -15+9i, -15+11i, -13+9i, -13+11i, ...
                                         -9+15i, -9+13i, -11+15i, -11+13i, -9+9i, -9+11i, -11+9i, -11+11i, ...
                                         -15+1i, -15+3i, -13+1i, -13+3i, -15+7i, -15+5i, -13+7i, -13+5i, ...
                                         -9+1i, -9+3i, -11+1i, -11+3i, -9+7i, -9+5i, -11+7i, -11+5i, ...
                                         -1+15i, -1+13i, -3+15i, -3+13i, -1+9i, -1+11i, -3+9i, -3+11i, ...
                                         -7+15i, -7+13i, -5+15i, -5+13i, -7+9i, -7+11i, -5+9i, -5+11i, ...
                                         -1+1i, -1+3i, -3+1i, -3+3i, -1+7i, -1+5i, -3+7i, -3+5i, ...
                                         -7+1i, -7+3i, -5+1i, -5+3i, -7+7i, -7+5i, -5+7i, -5+5i, ...
                                         -15-15i, -15-13i, -13-15i, -13-13i, -15-9i, -15-11i, -13-9i, -13-11i, ...
                                         -9-15i, -9-13i, -11-15i, -11-13i, -9-9i, -9-11i, -11-9i, -11-11i, ...
                                         -15-1i, -15-3i, -13-1i, -13-3i, -15-7i, -15-5i, -13-7i, -13-5i, ...
                                         -9-1i, -9-3i, -11-1i, -11-3i, -9-7i, -9-5i, -11-7i, -11-5i, ...
                                         -1-15i, -1-13i, -3-15i, -3-13i, -1-9i, -1-11i, -3-9i, -3-11i, ...
                                         -7-15i, -7-13i, -5-15i, -5-13i, -7-9i, -7-11i, -5-9i, -5-11i, ...
                                         -1-1i, -1-3i, -3-1i, -3-3i, -1-7i, -1-5i, -3-7i, -3-5i, ...
                                         -7-1i, -7-3i, -5-1i, -5-3i, -7-7i, -7-5i, ...
                                         -5-7i, -5-5i ];
        L1post.config.plp(i).plp_C = sqrt(170);
        L1post.config.plp(i).plp_V = 8;        
    else 
        L1post.config.plp(i).plp_mod = 'Undefined';
    end
    
    L1post.config.plp(i).plp_rotation = LLRChannel(index);
    switch L1post.config.plp(i).plp_mod
        case 'QPSK'
            L1post.config.plp(i).rot_angle = 2*pi*(29.0/360);
        case '16-QAM'
            L1post.config.plp(i).rot_angle = 2*pi*(16.8/360);
        case '64-QAM'
            L1post.config.plp(i).rot_angle = 2*pi*(8.6/360);
        case '256-QAM'
            L1post.config.plp(i).rot_angle = 2*pi*(atand(1/16)/360);
    end
    index=index+1;
    
    L1post.config.plp(i).plp_fec_type = LLRChannel(index:index+1);
    index=index+2;
    
    if isequal(L1post.config.plp(i).plp_fec_type,[0 0])
        L1post.config.plp(i).plp_fec_type = 16200;
    elseif isequal(L1post.config.plp(i).plp_fec_type,[0 1])
        L1post.config.plp(i).plp_fec_type = 64800;
    else
        L1post.config.plp(i).plp_fec_type = 'Undefined';
    end
    
    L1post.config.plp(i).plp_num_blocks_max = bi2de(LLRChannel(index:index+9),'left-msb');
    index=index+10;
    L1post.config.plp(i).frame_interval = bi2de(LLRChannel(index:index+7),'left-msb');
    index=index+8;
    L1post.config.plp(i).time_il_length = bi2de(LLRChannel(index:index+7),'left-msb');
    index=index+8;
    L1post.config.plp(i).time_il_type = bi2de(LLRChannel(index),'left-msb');
    index = index+1;
    L1post.config.plp(i).in_band_a_flag = LLRChannel(index);
    index=index+1;
    L1post.config.plp(i).in_band_b_flag = LLRChannel(index);
    index=index+1;
    L1post.config.plp(i).reserved = LLRChannel(index:index+10);
    index=index+11;
    L1post.config.plp(i).plp_mode = LLRChannel(index:index+1);
    index=index+2;
    L1post.config.plp(i).static_flag = LLRChannel(index);
    index=index+1;
    L1post.config.plp(i).static_padding_flag = LLRChannel(index);
    index=index+1;
end
    
L1post.config.fef_length_msb = LLRChannel(index:index+1);
index=index+2;
L1post.config.reserved_2 = LLRChannel(index:index+29);
index= index+30;

for i =1:(L1post.config.Num_Aux) 
    L1post.config.Aux(i).aux_stream_type = LLRChannel(index:index+3);
    index= index+4;
    L1post.config.Aux(i).aux_private_conf = LLRChannel(index:index+27);
    index= index+28;
end

%Dynamic
if (L1pre.repetition_flag)
    dynamic_sections = 2;
else
    dynamic_sections = 1;
end

for i = 1:dynamic_sections
    L1post.dynamic(i).frame_idx = bi2de(LLRChannel(index:index+7),'left-msb'); % Frame index within super frame 0+
    index = index+8;
    L1post.dynamic(i).subslice_interval = bi2de(LLRChannel(index:index+21),'left-msb');
    index = index+22;
    L1post.dynamic(i).type2_start = bi2de(LLRChannel(index:index+21),'left-msb');
    index = index+22;
    L1post.dynamic(i).L1changecounter = bi2de(LLRChannel(index:index+7),'left-msb');
    index = index+8;
    L1post.dynamic(i).start_rf_idx = LLRChannel(index:index+2);
    index = index+3;
    L1post.dynamic(i).reserved_1 = LLRChannel(index:index+7);
    index = index+8;
    
    for i1=1:L1post.config.Num_plp
        L1post.dynamic(i).plp(i1).plp_id = bi2de(LLRChannel(index:index+7),'left-msb');
        index = index+8;
        L1post.dynamic(i).plp(i1).plp_start = bi2de(LLRChannel(index:index+21),'left-msb');
        index = index+22;
        L1post.dynamic(i).plp(i1).plp_numblocks = bi2de(LLRChannel(index:index+9),'left-msb');
        index = index+10;
        L1post.dynamic(i).plp(i1).reserved_2 = LLRChannel(index:index+7);
        index = index+8;
    end
    
    L1post.dynamic(i).reserved_3 = LLRChannel(index:index+7);
    index = index+8;
    for i1=1:(L1post.config.Num_Aux) 
%         L1post.dynamic(i).Aux(i1).aux_private_dyn = LLRChannel(index:index+47);
        index = index+48;
    end
end
%L1 post extension
if (L1pre.L1postextension)
    %NOT NECESSARY FOR DECODING. CONTAINS NO USEFUL INFORMATION
end
end