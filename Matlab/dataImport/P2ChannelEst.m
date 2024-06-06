function [Cheq_Values, Channel_estCPS,P2_CPE] = P2ChannelEst(Values, P2, DVBT2)
%Description: Determine Common Phase Error, Channel Estimate and Channel equalization
%Inputs: Values - FFT Symbols
%        P2 - P2 Parameters
%        DVBT2 - FFT Size and MISO/SISO
%Outputs: Cheq_Values - Channel equalization FFT symbols
%         Channel_estCPS - Channel Estimate (can either be 1 channel or 2 channel
PilotMap = P2.P2PilotMap;
P2PLoc = P2.P2PLoc;
MISO = DVBT2.miso; 
CPS = P2.C_PS;

%% 1. Common Phase Error Correction
PhaseEst = angle(Values(:,P2PLoc).*conj(PilotMap(:,P2PLoc)));
P2_CPE = zeros(1,P2.N_P2);
for i = 1:P2.N_P2
    PhaseEst1 = mean(PhaseEst(i,:)); % Estimate of Common Phase Error
    P2_CPE(i) = PhaseEst1;
    Values(i,:) = Values(i,:).*exp(-1i*PhaseEst1); %Phase Error Correction
end

%% 2. Channel Estimate
RxPilots = Values; % Received Pilot tones
Channel_est = RxPilots(P2.P2PLoc)./PilotMap(P2.P2PLoc);
Channel_est(Channel_est==Inf)=0;

%Interpolate
if (MISO) %MISO Case
   
    diffindex = P2PLoc-1;
    diffindex = diffindex/3;
    diffindex = mod(diffindex,2); %Tells if odd or even multples of 3, 1==odd
    diffindex([2 3 end-1 end-2]) = 0; %These are sum indexes 
    logicaldiffindex = logical(diffindex);
    
    diffindex = P2PLoc(logicaldiffindex);
    
    sumindex = P2PLoc(~logicaldiffindex);

    SumChannelCPS = zeros(P2.N_P2,CPS);
    DiffChannelCPS = zeros(P2.N_P2,CPS);
    Channel_est = RxPilots./PilotMap;
    for i = 1:P2.N_P2;
        SumChannel = Channel_est(i,sumindex); %H1+H2
        DiffChannel = Channel_est(i,diffindex); %H1-H2  
        SumChannelCPS(i,:) = interp1(sumindex,SumChannel,1:CPS);
        DiffChannelCPS(i,:) = interp1(diffindex,DiffChannel,1:CPS,'linear','extrap');
    end
    Channel_estCPS.H1 = (SumChannelCPS-DiffChannelCPS)/2; %Channel Response over all P2 symbol(s) from Tx1
    Channel_estCPS.H2 = (SumChannelCPS+DiffChannelCPS)/2; %Channel Response over all P2 symbol(s) from Tx2
    Cheq_Values = Values;
else % SISO Case
    Channel_estCPS = zeros(P2.N_P2,CPS);
    for i = 1:P2.N_P2;
        Channel_estCPS(i,:) = interp1(P2.P2PLoc,Channel_est,1:CPS);
    end
    Cheq_Values = Values./Channel_estCPS; %Equalized values
%     Cheq_Values = Values; % not equalized
end

disp('P2 Channel Estimation Complete')
end