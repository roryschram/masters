function [DataHEven, DataHOdd,FC_HEven,FC_HOdd] = DataFreqIntPermutation(NFFT,DVBT2)
%Description: Give Permutation vector for frequency interleaving
%References: Implementation guidelines

%Start
CData = length(find(DVBT2.DataMap(1,:)));

CPS= DVBT2.C_PS;
FCDataMap = zeros(1,CPS);
FCDataMap(DVBT2.FCTRLoc)=1;
FCDataMap(DVBT2.FCPLoc)=1;
FCDataMap = ~FCDataMap;
NFC = length(find(FCDataMap)); %Number of data carriers in FC symbol

%Bit Permuatations - Table 53
switch NFFT
    case 1024
        mMax=NFFT; nR=log2(mMax); nMax=CData;

        % R_prime matrix definition
        rP = zeros(mMax,nR-1);
        rP(3,1) = 1;

        for k=3:mMax-1
          rP(k+1,(0:1:nR-3)+1) = rP(k,(1:1:nR-2)+1); % Shift LFSR
          rP(k+1,8+1) = xor(rP(k,1),rP(k,5));        % xor bit 4 and bit 0
        end

        % R = R_prime permutation
        rEven = zeros(mMax,nR-1);
        rOdd = zeros(mMax,nR-1);

        permutationRP = [8 7 6 5 4 3 2 1 0];
        permutationREven  = [4 3 2 1 0 5 6 7 8];
        permutationROdd   = [3 2 5 0 1 4 7 8 6];

        rEven(:,permutationREven+1) = rP(:,permutationRP+1);    
        rOdd(:,permutationROdd+1) = rP(:,permutationRP+1);
        
    case 2048
        mMax=NFFT; nR=log2(mMax); nMax=CData;
      
        % R_prime matrix definition
        rP = zeros(mMax,nR-1);
        rP(3,1) = 1;

        for k=3:mMax-1
          rP(k+1,(0:1:nR-3)+1) = rP(k,(1:1:nR-2)+1); % Shift LFSR
          rP(k+1,9+1) = xor(rP(k,1),rP(k,4));        % xor bit 3 and bit 0
        end

        % R = R_prime permutation
        r = zeros(mMax,nR-1);

        permutationRP = [9 8 7 6 5 4 3 2 1 0];
        permutationREven  = [0 7 5 1 8 2 6 9 3 4];
        permutationROdd  = [3 2 7 0 1 5 8 4 9 6];

        rEven(:,permutationREven+1) = rP(:,permutationRP+1);    
        rOdd(:,permutationROdd+1) = rP(:,permutationRP+1);    

    case 4096
        mMax = NFFT; nR=log2(mMax); nMax=CData;
      
        % R_prime matrix definition
        rP = zeros(mMax,nR-1);
        rP(3,1) = 1;

        for k=3:mMax-1
          rP(k+1,(0:1:nR-3)+1) = rP(k,(1:1:nR-2)+1); % Shift LFSR
          rP(k+1,10+1) = xor(rP(k,1),rP(k,3));       % xor bit 2 and bit 0
        end

        % R = R_prime permutation
        r = zeros(mMax,nR-1);

        permutationRP = [10 9 8 7 6 5 4 3 2 1 0];
        permutationREven  = [7 10 5 8 1 2 4 9 0 3 6];
        permutationROdd  = [6 2 7 10 8 0 3 4 1 9 5];

        rEven(:,permutationREven+1) = rP(:,permutationRP+1);    
        rOdd(:,permutationROdd+1) = rP(:,permutationRP+1);
        
    case 8192
        mMax=NFFT; nR=log2(mMax); nMax=CData;
    
        % R_prime matrix definition
        rP=zeros(mMax,nR-1);
        rP(3,1)=1;

        for k=3:mMax-1
          rP(k+1,(0:1:nR-3)+1) = rP(k,(1:1:nR-2)+1); %Shift LFSR

          alfa = xor(rP(k,1),rP(k,2));              %xor bit 0 and bit 1
          beta = xor(rP(k,5),rP(k,7));              %xor bit 4 and bit 6
          rP(k+1,12) = xor(alfa,beta);
        end

        % R = R prime permutation
        r=zeros(mMax,nR-1);

        permutationRP = [11 10 9 8  7 6 5 4 3 2 1 0];
        permutationREven  = [ 5 11 3 0 10 8 6 9 2 4 1 7];
        permutationROdd  = [ 8 10 7 6 0 5 2 1 3 9 4 11];

        rEven(:,permutationREven+1) = rP(:,permutationRP+1);    
        rOdd(:,permutationROdd+1) = rP(:,permutationRP+1);
        
    case 16384
        mMax=NFFT; nR=log2(mMax); nMax=CData;
    
        % R_prime matrix definition
        rP=zeros(mMax,nR-1);
        rP(3,1)=1;

        for k=3:mMax-1
          rP(k+1,(0:1:nR-3)+1) = rP(k,(1:1:nR-2)+1); %Shift LFSR

          alfa  = xor(rP(k,1),rP(k,2));              %xor bit 0 and bit 1
          beta  = xor(rP(k,5),rP(k,6));              %xor bit 4 and bit 5
          gamma = xor(rP(k,10),rP(k,12));            %xor bit 9 and bit 11
          rP(k+1,13) = xor(xor(alfa,beta), gamma);
        end

        % R = R prime permutation
        r=zeros(mMax,nR-1);

        permutationRP = [12 11 10 9 8 7  6  5  4 3 2 1 0];
        permutationREven  = [ 8 4 3 2 0 11 1 5 12 10 6 7 9 ];
        permutationROdd  = [ 7 9 5 3 11 1 4 0 2 12 10 8 6 ];

        rEven(:,permutationREven+1) = rP(:,permutationRP+1);    
        rOdd(:,permutationROdd+1) = rP(:,permutationRP+1); 
        
    case 32768
            mMax=NFFT; nR=log2(mMax); nMax=CData;
    
    % R_prime matrix definition
    rP=zeros(mMax,nR-1);
    rP(3,1)=1;
    
    for k=3:mMax-1
      rP(k+1,(0:1:nR-3)+1) = rP(k,(1:1:nR-2)+1); %Shift LFSR
      
      alfa = xor(rP(k,1),rP(k,2));             %xor bit 0 and bit 1
      beta = xor(rP(k,3),rP(k,13));            %xor bit 2 and bit 12
      rP(k+1,14) = xor(alfa,beta);
    end
    
    % R = R prime permutation
    r=zeros(mMax,nR-1);
    
    permutationRP = [13 12 11 10  9  8 7  6  5 4 3 2 1  0];
    permutationR  = [ 6  5  0 10  8  1 11 12 2 9 4 3 13 7];
    
    r(:,permutationR+1)= rP(:,permutationRP+1);
end

%Permutation function

DataHOdd = zeros(1,nMax);
DataHEven  = zeros(1,nMax);

FC_HOdd = zeros(1,NFC);
FC_HEven = zeros(1,NFC);

p = 1;
p_FC = 1;
if NFFT==32768
    for i = 0:mMax-1
        DataHOdd(1,p) = (mod(i,2))*2^(nR-1)+ sum(r(i+1,:).*2.^(0:1:(nR-2)));
        if (DataHOdd(1,p)<CData); p=p+1;end
    end
    if DVBT2.L_FC
        for i = 0:mMax-1
            FC_HOdd(1,p_FC) = (mod(i,2))*2^(nR-1)+ sum(r(i+1,:).*2.^(0:1:(nR-2)));
            if (FC_HOdd(1,p_FC)<NFC); p_FC=p_FC+1;end
        end
        FC_HOdd = FC_HOdd+1;
        FC_HEven = FC_HOdd;
        [~,FC_HEven] = sort(FC_HEven); % Get indices to inverse map for 32k case
    else
        FC_HEven = [];
        FC_HOdd = [];
    end
    
	DataHEven = DataHOdd;
	[~,DataHEven] = sort(DataHEven); % Get indices to inverse map for 32k case
    DataHOdd = DataHOdd+1;
else
    for i = 0:mMax-1
        DataHOdd(1,p) = (mod(i,2))*2^(nR-1)+ sum(rOdd(i+1,:).*2.^(0:1:(nR-2)));
        if (DataHOdd(1,p)<CData); p=p+1;end
    end
    DataHOdd = DataHOdd+1;
    p = 1;

    for i = 0:mMax-1
        DataHEven(1,p) = (mod(i,2))*2^(nR-1)+ sum(rEven(i+1,:).*2.^(0:1:(nR-2)));
        if (DataHEven(1,p)<CData); p=p+1;end
    end
    DataHEven = DataHEven+1;
    if DVBT2.L_FC
        for i = 0:mMax-1
            FC_HOdd(1,p_FC) = (mod(i,2))*2^(nR-1)+ sum(rOdd(i+1,:).*2.^(0:1:(nR-2)));
            if (FC_HOdd(1,p_FC)<NFC); p_FC=p_FC+1;end
        end
        FC_HOdd = FC_HOdd+1;
        p_FC = 1;
        
        for i = 0:mMax-1
            FC_HEven(1,p_FC) = (mod(i,2))*2^(nR-1)+ sum(rEven(i+1,:).*2.^(0:1:(nR-2)));
            if (FC_HEven(1,p_FC)<NFC); p_FC=p_FC+1;end
        end
        FC_HEven=FC_HEven+1;
    else
        FC_HEven = [];
        FC_HOdd = [];
    end
end

end