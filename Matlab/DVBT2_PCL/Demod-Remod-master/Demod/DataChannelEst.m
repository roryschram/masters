function [Cheq_Values, ChannelEst_CPS,Data_CPE,FC_CPE] = DataChannelEst(Values, L1pre,DVBT2)
%Description: Determine Common Phase Error, Channel Estimate and Channel equalization
%Inputs: Values - FFT Symbols
%        L1pre - L1 pre parameters
%        DVBT2 - Data Symbol paramters
%Outputs: Cheq_Values - Channel equalization FFT symbols
%         Channel_estCPS - Channel Estimate (can either be 1 channel or 2 channel)
%         Data_CPE - Data Symbol Common Phase Error Estimate
%         FC_CPE - Frame Cloding CPE
% References:
CPilotMap = DVBT2.Continualpilotmap;
CPLoc = DVBT2.CPLoc;
MISO = L1pre.S1;
CPS = DVBT2.C_PS;
%%
if DVBT2.L_FC
    %% 1. Common Phase Error Correction
    PhaseEst = angle(Values(1:L1pre.numdatasymbols-1,CPLoc).*conj(CPilotMap(1:L1pre.numdatasymbols-1,CPLoc)));
    Data_CPE = zeros(1,L1pre.numdatasymbols-1);
    for i = 1:L1pre.numdatasymbols-1
            PhaseEst1 = mean(PhaseEst(i,:)); % Estimate of Common Phase Error
            Data_CPE(i) = PhaseEst1;
            Values(i,:) = Values(i,:).*exp(-1i*PhaseEst1); %Phase Error Correction
    end
    PhaseEst = angle(Values(end,DVBT2.FCPLoc )./DVBT2.FCPilotMap(1,DVBT2.FCPLoc)); %FC 
    PhaseEst1 = mean(PhaseEst(1,:)); % Estimate of Common Phase Error
    FC_CPE = PhaseEst1;
    Values(end,:) = Values(end,:).*exp(-1i*PhaseEst1); %Phase Error Correction
    
    %% 2. Channel Estimate
    RxPilots = Values; % Received Pilot tones
    Channel_est = zeros(size(Values)); 
    for i = 1:L1pre.numdatasymbols-1
        SPLoc = find(DVBT2.Scatteredpilotmap(i,:));
        SPLoc(SPLoc==0)=[];
        Channel_est(i,SPLoc) = RxPilots(i,SPLoc)./DVBT2.Scatteredpilotmap(i,SPLoc);
    end
    
    Channel_est(end,DVBT2.FCPLoc) =  RxPilots(end,DVBT2.FCPLoc)./DVBT2.FCPilotMap(DVBT2.FCPLoc); % FC pilots channel estimate
    
    if (MISO) % MISO Case
        SumChannelMap = zeros(L1pre.numdatasymbols-1,CPS);
        DiffChannelMap = zeros(L1pre.numdatasymbols-1,CPS);
        SumChannelCPS = zeros(L1pre.numdatasymbols,CPS);
        DiffChannelCPS = zeros(L1pre.numdatasymbols,CPS);
        
        %Check SP location to see which is sum and difference symbol;
        k = (-1).^(0:CPS-1);
        for i = 1:L1pre.numdatasymbols-1
            SPLoc = find(DVBT2.Scatteredpilotmap(i,:));
            SPLoc(SPLoc==0)=[];
            if all(k(SPLoc-1)==1) % Test if any SP are inverted
                SumChannelMap(i,:)= Channel_est(i,:);
            else
                DiffChannelMap(i,:) = Channel_est(i,:);
            end
        end
                
        %interpolation in time across symbols in frame
        for i = 1:DVBT2.DY
            SPLoc = find(DVBT2.Scatteredpilotmap(i,:));
            SPLoc(SPLoc==0)=[];
            if SPLoc==find(SumChannelMap(i,:))
                for i1 = 1:length(SPLoc)
                SumChannelCPS(1:L1pre.numdatasymbols-1,SPLoc(i1)) = interp1(i:DVBT2.DY:L1pre.numdatasymbols-1,SumChannelMap(i:DVBT2.DY:L1pre.numdatasymbols-1,SPLoc(i1)),...
                                                    1:L1pre.numdatasymbols-1,'linear','extrap');
                end
            else
                for i1 = 1:length(SPLoc)
                DiffChannelCPS(1:L1pre.numdatasymbols-1,SPLoc(i1)) = interp1(i:DVBT2.DY:L1pre.numdatasymbols-1,DiffChannelMap(i:DVBT2.DY:L1pre.numdatasymbols-1,SPLoc(i1)),...
                                                    1:L1pre.numdatasymbols-1,'linear','extrap');
                end%for
            end%if
        end%for
        
        %interpolation in frequency across bins
        for i = 1:L1pre.numdatasymbols-1
            SumChannelCPS(i,:) = interp1(find(SumChannelCPS(i,:)),SumChannelCPS(i,find(SumChannelCPS(i,:))),1:CPS);
            DiffChannelCPS(i,:) = interp1(find(DiffChannelCPS(i,:)),DiffChannelCPS(i,find(DiffChannelCPS(i,:))),1:CPS);
        end
        
        %FC pilot
        diffindex = DVBT2.FCPLoc-1;
        diffindex = diffindex/DVBT2.DX;
        diffindex = mod(diffindex,2);
        logicaldiffindex = logical(diffindex);
        
        diffindex=DVBT2.FCPilotMap(logicaldiffindex);
        sumindex = DVBT2.FCPilotMap(~logicaldiffindex);
        
        SumChannelCPS(end,:) = interp1(sumindex,Channel_est(end,sumindex),1:CPS);
        DiffChannelCPS(end,:) = interp1(diffindex,Channel_est(end,diffindex),1:CPS);
        
        % H1 and H2
        ChannelEst_CPS.H1 = (SumChannelCPS-DiffChannelCPS)/2; %Channel Response over all P2 symbol(s) from Tx1
        ChannelEst_CPS.H2 = (SumChannelCPS+DiffChannelCPS)/2; %Channel Response over all P2 symbol(s) from Tx2
        Cheq_Values = Values;
        
    else % SISO Case
        ChannelEst_CPS = zeros(L1pre.numdatasymbols,CPS);
        %interpolation in time across symbols in frame
        for i = 1:DVBT2.DY
            SPLoc = find(DVBT2.Scatteredpilotmap(i,:));
            SPLoc(SPLoc==0)=[];
            for i1 = 1:length(SPLoc)
                ChannelEst_CPS(1:L1pre.numdatasymbols-1,SPLoc(i1)) = interp1(i:DVBT2.DY:L1pre.numdatasymbols-1,Channel_est(i:DVBT2.DY:L1pre.numdatasymbols-1,SPLoc(i1)),...
                    1:L1pre.numdatasymbols-1,'linear','extrap');
            end
        end
        
        %interpolation in frequency across bins
        for i = 1:L1pre.numdatasymbols-1
            ChannelEst_CPS(i,:) = interp1(find(ChannelEst_CPS(i,:)),ChannelEst_CPS(i,find(ChannelEst_CPS(i,:))),1:CPS,'linear','extrap');
        end
        
        %FC pilot
        ChannelEst_CPS(end,:) = interp1(DVBT2.FCPLoc,Channel_est(end,DVBT2.FCPLoc),1:CPS,'linear','extrap');
        
        Cheq_Values = Values./ChannelEst_CPS; %Equalized values
    end
%%
else
    %NO Frame Closing Symbol
    %% 1. Common Phase Error Correction
    PhaseEst = angle(Values(1:L1pre.numdatasymbols,CPLoc).*conj(CPilotMap(1:L1pre.numdatasymbols,CPLoc)));
    Data_CPE = zeros(1,L1pre.numdatasymbols);
    for i = 1:L1pre.numdatasymbols
            PhaseEst1 = mean(PhaseEst(i,:)); % Estimate of Common Phase Error
            Data_CPE(i)=PhaseEst1;
            Values(i,:) = Values(i,:).*exp(-1i*PhaseEst1); %Phase Error Correction
    end
    FC_CPE = [];
    %% 2. Channel Estimate
    RxPilots = Values; % Received Pilot tones
    Channel_est = zeros(size(Values)); 
    for i = 1:L1pre.numdatasymbols
        SPLoc = find(DVBT2.Scatteredpilotmap(i,:));
        SPLoc(SPLoc==0)=[];
        Channel_est(i,SPLoc) = RxPilots(i,SPLoc)./DVBT2.Scatteredpilotmap(i,SPLoc);
    end   
    if MISO
        SumChannelMap = zeros(L1pre.numdatasymbols,CPS);
        DiffChannelMap = zeros(L1pre.numdatasymbols,CPS);
        SumChannelCPS = zeros(L1pre.numdatasymbols,CPS);
        DiffChannelCPS = zeros(L1pre.numdatasymbols,CPS);
    
        %Check SP location to see which is sum and difference symbol;
        k = (-1).^(0:CPS-1);
        for i = 1:L1pre.numdatasymbols
            SPLoc = find(DVBT2.Scatteredpilotmap(i,:));
            SPLoc(SPLoc==0)=[];
            if all(k(SPLoc-1)==1) % Test if any SP are inverted
                SumChannelMap(i,:)= Channel_est(i,:);
            else
                DiffChannelMap(i,:) = Channel_est(i,:);
            end
        end
                
        %interpolation in time across symbols in frame
        for i = 1:DVBT2.DY
            SPLoc = find(DVBT2.Scatteredpilotmap(i,:));
            SPLoc(SPLoc==0)=[];
            if SPLoc==find(SumChannelMap(i,:))
                for i1 = 1:length(SPLoc)
                SumChannelCPS(:,SPLoc(i1)) = interp1(i:DVBT2.DY:L1pre.numdatasymbols,SumChannelMap(i:DVBT2.DY:L1pre.numdatasymbols,SPLoc(i1)),...
                                                    1:L1pre.numdatasymbols,'linear','extrap');
                end
            else
                for i1 = 1:length(SPLoc)
                DiffChannelCPS(:,SPLoc(i1)) = interp1(i:DVBT2.DY:L1pre.numdatasymbols,DiffChannelMap(i:DVBT2.DY:L1pre.numdatasymbols,SPLoc(i1)),...
                                                    1:L1pre.numdatasymbols,'linear','extrap');
                end%for
            end%if
        end%for
        
        %interpolation in frequency across bins
        for i = 1:L1pre.numdatasymbols
            SumChannelCPS(i,:) = interp1(find(SumChannelCPS(i,:)),SumChannelCPS(i,find(SumChannelCPS(i,:))),1:CPS);
            DiffChannelCPS(i,:) = interp1(find(DiffChannelCPS(i,:)),DiffChannelCPS(i,find(DiffChannelCPS(i,:))),1:CPS);
        end
        
        % H1 and H2
        ChannelEst_CPS.H1 = (SumChannelCPS-DiffChannelCPS)/2; %Channel Response over all P2 symbol(s) from Tx1
        ChannelEst_CPS.H2 = (SumChannelCPS+DiffChannelCPS)/2; %Channel Response over all P2 symbol(s) from Tx2
        Cheq_Values = Values;
        
    else %SISO
        ChannelEst_CPS = zeros(L1pre.numdatasymbols,CPS);
        %interpolation in time across symbols in frame
        for i = 1:DVBT2.DY
            SPLoc = find(DVBT2.Scatteredpilotmap(i,:));
            SPLoc(SPLoc==0)=[];
            for i1 = 1:length(SPLoc)
                ChannelEst_CPS(:,SPLoc(i1)) = interp1(i:DVBT2.DY:L1pre.numdatasymbols,Channel_est(i:DVBT2.DY:L1pre.numdatasymbols,SPLoc(i1)),...
                    1:L1pre.numdatasymbols,'linear','extrap');
            end
        end
        
        %interpolation in frequency across bins
        for i = 1:L1pre.numdatasymbols
            ChannelEst_CPS(i,:) = interp1(find(ChannelEst_CPS(i,:)),ChannelEst_CPS(i,find(ChannelEst_CPS(i,:))),1:CPS,'linear','extrap');
        end
        
        Cheq_Values = Values./ChannelEst_CPS; %Equalized values
    end

end
%%
end