function L1_NBch_3240 = L1preLDPCdecoding(LLRChannel)
% Description: LDPC decoding of L1 pre LDPC frame of 16200 bits based on belief propagation using LLrs
% Inputs: LLRChannel - LLR symbols
% Ouputs:
% Reference:
%Parity Matrix, H, Generation

H = LDPCParityMatrix(1/5, 16200);

%Set up:
numberones = nnz(H); % Number of ones in parity matrix
[nCheck, nBit] = size(H);
[indexCheck, indexBit] = find(H); 
linearindex = find(H);

V2Cmessage = spalloc(nCheck,nBit,numberones); %Variable to Check communication
C2Vmessage = spalloc(nCheck,nBit,numberones); %Check to Variable communication
messagebit = LLRChannel;
messageCheck = zeros(1,nCheck);

NIterMax = 50; % Number of iteration, recommended to be 50 in literature

checkNode = struct('indexBitConnected', 0);
check = repmat(checkNode, nCheck, 1);
for iCheck = 1:nCheck
    check(iCheck).indexBitConnected = indexBit(indexCheck == iCheck); % Connections to check nodes
end % for iCheck

% Output
L1_NBch_3240  = zeros(1, nBit);

% ITERATIVE BELIEF PROPAGATION
for niteration = 1:NIterMax
    % Variable to Check messages
    
    
    V2Cmessage(linearindex) = messagebit(indexBit).' - C2Vmessage(linearindex);

    % Check to Variable messages
    V2Cmessagetanh = spfun(@tanh,V2Cmessage/2);
    for iCheck = 1:nCheck
        messageCheck(iCheck) = prod(V2Cmessagetanh(iCheck, check(iCheck).indexBitConnected)); % Connections to check nodes
    end % for iCheck
    C2Vmessage(linearindex) = 2*atanh(messageCheck(indexCheck).'./ V2Cmessagetanh(linearindex));
	
	% Bit messages
	messagebit = sum(C2Vmessage,1)+LLRChannel;
	
	%Decision 
	L1_NBch_3240(messagebit>=0) = 0;
	L1_NBch_3240(messagebit<0) = 1;
	if sum(mod((L1_NBch_3240*H.'),2))==0
		break;
	end
end
L1_NBch_3240 = L1_NBch_3240(1:3240);

disp('L1 Pre LDPC Decoding Completed')
disp(sprintf('Numer of Iterations: %d out of 50', niteration))

end
