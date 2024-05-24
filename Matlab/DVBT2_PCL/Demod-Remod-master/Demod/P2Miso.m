function MISOValues = P2Miso(Values, MISO, P2, ChannelEst)
%Description: Miso decoding of P2 symbols and extraction of data carriers in P2
%References: Implementation guidelines of DVB-T2
%            Modeling and performance evaluations of Alamouti technique in a single frequency network for DVB-T2
%Inputs: Values - IQ Data
%        MISO - MISO/SISO toggle
%        P2   - P2 Parameters
%        ChannelEst - Channel Estimate using P2 symbols

P2DataLoc = P2.D_Loc; %P2 Data Location Carriers
if MISO
    H1 = ChannelEst.H1; % Channel Estimate for all P2 symbols
    H1 = H1(:,P2DataLoc);
    H2 = ChannelEst.H2;
    H2 = H2(:,P2DataLoc);
    
    H1Even = H1(:,1:2:end);
    H2Even = H2(:,1:2:end);
    H1Odd = H1(:,2:2:end);
    H2Odd = H2(:,2:2:end);
    
    
    Values = Values(:,P2DataLoc); %Data Carriers of P2 symbols
    ValuesEven = Values(:,1:2:end);
    ValuesOdd = Values (:,2:2:end);
    ValuesOdd = conj(ValuesOdd);
    
    MISOValues = zeros(P2.N_P2, P2.C_P2);
    MISOValues = reshape(MISOValues,2,[]); % 2 rows, multiple columns
    for i2 = 1:P2.N_P2
        for i = 1:P2.C_P2/2
            Hmatrix = [conj(H1Odd(i2,i)),H2Even(i2,i); -1*conj(H2Odd(i2,i)),H1Even(i2,i)];
            Equalization = (H1Even(i2,i).*conj(H1Odd(i2,i)))+(conj(H2Odd(i2,i)).*H2Even(i2,i));
            Hmatrix = (1/(Equalization)).*Hmatrix;
            y = [ValuesEven(i2,i);ValuesOdd(i2,i)];
            
            Symbol_est = Hmatrix*y;
            MISOValues(:,((P2.C_P2*(i2-1))+i)) = Symbol_est;
        end
    end
    MISOValues = reshape(MISOValues,P2.C_P2,P2.N_P2);
    MISOValues = MISOValues.';
else
    MISOValues = Values(:,P2DataLoc);
end
end
