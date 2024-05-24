function [DataMISOValues,FCDataMISOValues] = DataMiso(Values, MISO, L1pre,DVBT2, ChannelEst)
%Description: Miso decoding of P2 symbols
% Inputs  Values - QAM Data Symbols
%         MISO - MISO/SISO toggle
%         L1pre - L1 pre parameters
%         ChannelEst - Channel estimate on data symbols
%         DVBT2 - Data Symbol Parameters
% Ouputs: ioffset - interger freq offset estimated
%References: Implementation guidelines of DVB-T2
%            Modeling and performance evaluations of Alamouti technique in a single frequency network for DVB-T2

DataMap = DVBT2.DataMap; %Data Carrier over normal data symbols

% FC Data carriers
CPS= DVBT2.C_PS;
FCDataMap = zeros(1,CPS);
FCDataMap(DVBT2.FCTRLoc)=1;
FCDataMap(DVBT2.FCPLoc)=1;
FCDataMap = ~FCDataMap;

if MISO
    if DVBT2.L_FC
        %Extract data cells
        H1Data = ChannelEst.H1(1:L1pre.numdatasymbols-1,:); % Channel Estimate for all P2 symbols
        H1Data = H1Data(DataMap);
        H1Data = reshape(H1Data,L1pre.numdatasymbols-1,[]);
        H2Data = ChannelEst.H2(1:L1pre.numdatasymbols-1,:);
        H2Data = H2Data(DataMap);
        H2Data = reshape(H2Data,L1pre.numdatasymbols-1,[]);
        
        H1FCData = ChannelEst.H1(end,:);
        H1FCData = H1FCData(1,FCDataMap);
        H2FCData = ChannelEst.H2(end,:);
        H2FCData = H2FCData(1,FCDataMap);
        
        Data = Values(1:L1pre.numdatasymbols-1,:);
        Data = Data(DataMap);
        Data = reshape(Data,L1pre.numdatasymbols-1,[]);
        
        FCData = Values(end,:);
        FCData = FCData(1,FCDataMap);
        
        %split into MISO pairs
        H1DataEven = H1Data(:,1:2:end);
        H2DataEven = H2Data(:,1:2:end);
        H1DataOdd = H1Data(:,2:2:end);
        H2DataOdd = H2Data(:,2:2:end);
        
        H1FCDataEven = H1FCData(1:2:end);
        H2FCDataEven = H2FCData(1:2:end);
        H1FCDataOdd = H1FCData(2:2:end);
        H2FCDataOdd = H2FCData(2:2:end);
        
        DataEven = Data(:,1:2:end);
        DataOdd = Data(:,2:2:end);
        DataOdd = conj(DataOdd);
    
        FCDataEven = FCData(:,1:2:end);
        FCDataOdd = FCData(:,2:2:end);
        FCDataOdd = conj(FCDataOdd);
        
        DataMISOValues = zeross(L1pre.numdatasymbols-1,length(Data(1,:)));
        DataMISOValues = reshape(DataMISOValues,2,[]);
        FCDataMISOValues = zeros(1,length(FCData));
        FCDataMISOValues = reshape(FCDataMISOValues,2,[]);
        
        for i2 = 1:L1pre.numdatasymbols-1
            for i = 1:length(Data(1,:))/2
                Hmatrix = [conj(H1DataOdd(i2,i)),H2DataEven(i2,i); -1*conj(H2DataOdd(i2,i)),H1DataEven(i2,i)];
                Equalization = (H1DataEven(i2,i).*conj(H1DataOdd(i2,i)))+(conj(H2DataOdd(i2,i)).*H2DataEven(i2,i));
                Hmatrix = (1/(Equalization)).*Hmatrix;
                y = [DataEven(i2,i);DataOdd(i2,i)];
                
                Symbol_est = Hmatrix*y;
                DataMISOValues(:,((P2.C_P2*(i2-1))+i)) = Symbol_est;
            end
        end
        for i = 1:length(Data(1,:))/2
            Hmatrix = [conj(H1FCDataOdd(i)),H2FCDataEven(i); -1*conj(H2FCDataOdd(i)),H1FCDataEven(i)];
            Equalization = (H1FCDataEven(i).*conj(H1FCDataOdd(i)))+(conj(H2FCDataOdd(i)).*H2FCDataEven(i));
            Hmatrix = (1/(Equalization)).*Hmatrix;
            y = [FCDataEven(i);FCDataOdd(i)];
        
            Symbol_est = Hmatrix*y;
            FCDataMISOValues(:,i) = Symbol_est;
        end
        DataMISOValues = reshape(DataMISOValues,length(Data(1,:)),L1pre.numdatasymbols-1);
        DataMISOValues = DataMISOValues.';
        FCDataMISOValues = reshape(FCDataMISOValues,length(FCData),1);
        FCDataMISOValues = FCDataMISOValues.';
    else % NO Frame Closing Sybmol
        %Extract data cells
        H1Data = ChannelEst.H1(1:L1pre.numdatasymbols,:); % Channel Estimate for all P2 symbols
        H1Data = H1Data(DataMap);
        H1Data = reshape(H1Data,L1pre.numdatasymbols,[]);
        H2Data = ChannelEst.H2(1:L1pre.numdatasymbols,:);
        H2Data = H2Data(DataMap);
        H2Data = reshape(H2Data,L1pre.numdatasymbols,[]);  
        
        Data = Values(1:L1pre.numdatasymbols,:);
        Data = Data(DataMap);
        Data = reshape(Data,L1pre.numdatasymbols,[]);
        
        %split into MISO pairs
        H1DataEven = H1Data(:,1:2:end);
        H2DataEven = H2Data(:,1:2:end);
        H1DataOdd = H1Data(:,2:2:end);
        H2DataOdd = H2Data(:,2:2:end);
        
        DataEven = Data(:,1:2:end);
        DataOdd = Data(:,2:2:end);
        DataOdd = conj(DataOdd);
    
        DataMISOValues = zeross(L1pre.numdatasymbols,length(Data(1,:)));
        DataMISOValues = reshape(DataMISOValues,2,[]);
        
        for i2 = 1:L1pre.numdatasymbols
            for i = 1:length(Data(1,:))/2
                Hmatrix = [conj(H1DataOdd(i2,i)),H2DataEven(i2,i); -1*conj(H2DataOdd(i2,i)),H1DataEven(i2,i)];
                Equalization = (H1DataEven(i2,i).*conj(H1DataOdd(i2,i)))+(conj(H2DataOdd(i2,i)).*H2DataEven(i2,i));
                Hmatrix = (1/(Equalization)).*Hmatrix;
                y = [DataEven(i2,i);DataOdd(i2,i)];
                
                Symbol_est = Hmatrix*y;
                DataMISOValues(:,((P2.C_P2*(i2-1))+i)) = Symbol_est;
            end
        end
        DataMISOValues = reshape(DataMISOValues,length(Data(1,:)),L1pre.numdatasymbols);
        DataMISOValues = DataMISOValues.';
        FCDataMISOValues = [];
    end
else
    if DVBT2.L_FC
        DataMap = DataMap((1:(L1pre.numdatasymbols-1)),:).';
        DataMISOValues = Values(1:(L1pre.numdatasymbols-1),:).';
        DataMISOValues = DataMISOValues(DataMap);
        DataMISOValues = reshape(DataMISOValues,[],L1pre.numdatasymbols-1);
        DataMISOValues = DataMISOValues.';
        FCDataMISOValues = Values(end,FCDataMap);
    else
        DataMISOValues = Values(1:L1pre.numdatasymbols,:);
% 		DataMISOValues = DataMISOValues(DataMap);
        DataMap = DataMap.';
        DataMISOValues = DataMISOValues.';
        DataMISOValues = DataMISOValues(DataMap);
        DataMISOValues = reshape(DataMISOValues,[],L1pre.numdatasymbols);
        DataMISOValues = DataMISOValues.';
        FCDataMISOValues = [];
    end
end
end