function Frame = PilotMapping(P2Symbols,DataSymbols,FCSymbol,P2_CPE,Data_CPE,FC_CPE,L1pre,DVBT2,P2,JamPilotSetting)
%Description: Mapping of pilots and Qam data to symbols
% Inputs  P2Symbols - QAM symbols related to PLP
%         DataSymbols - QAM symbols related to Frame Closing (FC) Symbol 
%         FCSymbol  - QAM symbol fc symbol
%         P2_CPE - Common Phase Error in P2 symbols
%         Data_CPE - Common Phase Error in Data symbols
%         FC_CPE - Common Phase Error in FC symbol
%         L1pre - L1 pre parameters
%         DVBT2 - Data symbol parameters
%         P2 - P2 Parameters
%         JamPilotSetting - Jammer Remodulation settings
% Ouput: Frame - DVBT2 Frame

%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2)

%Pilot Amplitudes
Asp = 1*JamPilotSetting.Sp;
Acp = (1/DVBT2.A_CP)*DVBT2.A_CP2*JamPilotSetting.Cp;
Ap2 = 1*JamPilotSetting.P2;

Frame = zeros(P2.N_P2+L1pre.numdatasymbols,DVBT2.C_PS);

%P2 Symbols
if L1pre.BW_EXT
    for i = 1:P2.N_P2
        Frame(i,:)=P2.ExtendedP2Map(i,:).*Ap2;
        Frame(i,P2.D_Loc+DVBT2.K_EXT) = P2Symbols(i,:);
%         Frame(i,:) = Frame(i,:).*exp(1i*P2_CPE(i));
    end
else
    for i = 1:P2.N_P2
        Frame(i,:)=P2.P2PilotMap(i,:).*Ap2;
        Frame(i,P2.D_Loc) = P2Symbols(i,:);
%         Frame(i,:) = Frame(i,:).*exp(1i*P2_CPE(i));
    end
end

%Data Symbol and FC Symbol
if DVBT2.L_FC
    for i = 1:(L1pre.numdatasymbols-1)
        SPLoc = DVBT2.SPLoc(i,:);
        SPLoc(SPLoc==0) =[];
        ExclCP = setdiff(DVBT2.CPLoc,SPLoc);
        Frame(i+P2.N_P2,:) = DVBT2.Scatteredpilotmap(i,:).*Asp +DVBT2.ToneReservedMap(i,:);
	    Frame(i+P2.N_P2,ExclCP) = DVBT2.Continualpilotmap(i,ExclCP).*Acp;
        Frame(i+P2.N_P2,DVBT2.DataMap(i,:)) = DataSymbols(i,:).*0;
%         Frame(i+P2.N_P2,:) = Frame(i+P2.N_P2,:).*exp(1i*Data_CPE(i));
    end
    Frame(end,:) = DVBT2.FCPilotMap.*Asp;
    Frame(end,DVBT2.DataMap(end,:)) = FCSymbol(1:length(find(DVBT2.DataMap(end,:))));
    Frame(end,DVBT2.FCTRLoc) = 1;
%     Frame(end,:) = Frame(end,:).*exp(1i*FC_CPE);
else
    for i = 1:(L1pre.numdatasymbols)
        SPLoc = DVBT2.SPLoc(i,:);
        SPLoc(SPLoc==0) =[];
        ExclCP = setdiff(DVBT2.CPLoc,SPLoc);
        Frame(i+P2.N_P2,:) = DVBT2.Scatteredpilotmap(i,:).*Asp +DVBT2.ToneReservedMap(i,:);
        Frame(i+P2.N_P2,ExclCP) = DVBT2.Continualpilotmap(i,ExclCP).*Acp;
        Frame(i+P2.N_P2,DVBT2.DataMap(i,:)) = DataSymbols(i,:).*0;
%         Frame(i+P2.N_P2,:) = Frame(i+P2.N_P2,:).*exp(1i*Data_CPE(i));
        Frame(i+P2.N_P2,:) = Frame(i+P2.N_P2,:);
    end
end
end