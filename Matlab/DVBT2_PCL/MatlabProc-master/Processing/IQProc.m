function [oOutputRCF_Lat CGLSAlpha_Lat] = ProcLat(oInputRCFLat, cancellationMaxRange_m, cancellationMaxDoppler_Hz, txToRefRxDistance_m, nSegments, nIterations, initialAlpha,nCPIs)

%% Usage: oOutputRCF = CGLS_Cancellation(oInputRCF, cancellationMaxRange_m, cancellationMaxDoppler_Hz, txToRefRxDistance_m)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters:
% The follow specify over what range the cancellation should be applied
% oInputRCF The RCF object on which cancellation is to be applied
% cancellationMaxRange_m: (in m <- Note this is bistatic range) The range
%       up to which to perform cancellation
% cancellationMaxDopppler_Hz: (in Hz <- Note that the cancellation will be
%       applied from negative to positive of this value
% txToRefRxDinstance_m: The distance from the tx antenna to the reference
%       antenna used to calculate bistatic range in m
% nSegments: The number of segments to split the the specific RCF object
%       into for doing cancellation.
% nIterations: The number of iterations to perform in the CGLS algorithm
%initialAlpha: A starting point for the filter weight. Previously
%       determined filter weights can be used here as an advance starting point to
%       improve convergence times.
%Returned:
%oOutputRCF: A new RCF object with cancelled surveillance channel
%alpha: The weighting of the filter that was applied for cancellation. This
%       is returned so that it can be used to initialised subsequent calls for
%       CGLS cancellation

%%%%%%%%%%%%%%%%%%Data that's been changed from objects%%%%%%%%%%%%%%%%%%%%
%oInputRCF.getNSamples() - this gets the number of samples for a CPI
%oInputRCF.getFs_Hz() - this gets the sampling frequency rate
%oInputRCF.m_fvReferenceData - this is the recorded IQ data from Reference
%signal
%oInputRCF.m_fvSurveillanceData - this is recorded IQ data for
%surveillance. This is also the b matrix in b - Ax
%Initial Alpha is usually zero.

%To get this to work then IQ data needs to be imported for both reference and
%Surveillance. Sampling rate used needs to be defined. Alpha needs to be
%initialized to zero unless previous alpha values are available. 
%This filter needs to loop for number of xCPI samples
%that can be obtained from recordings. e.g. if 2.56e6 samples are recorded
%and CPI is 640e3 samples then the number of loops for cancellation is 4.

% This code is derived from work by Michael Saunders (http://www.stanford.edu/group/SOL/software/cgls.html)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Import the IQ data here.
m_Reference_data = oInputRCFLat.m_fvReferenceData;
m_Surveillance_data = oInputRCFLat.m_fvSurveillanceData;
%define sampling rate
FS = 200000;
%Initialize Alpha usually a value of 0
initialAlpha_m = initialAlpha;
%define cancellation for range and doppler
cancellationMaxRange = cancellationMaxRange_m;
cancellationMaxDoppler= cancellationMaxDoppler_Hz;

%define baseline in meters
txToRefRxDistance = txToRefRxDistance_m;

%define CPI in Seconds
CPI = 4;

%Number of Samples per CPI
CPISize_nSamp = FS*CPI;

%Calculate the number of Loops per CPI for cancellation
%commented code was for non-RCF data 
%nCPIs = nCPIs; %floor(length(m_Reference_data)/(CPISize_nSamp)); 
CPIStartSampleNumber = 0;

%define factor that CPI should be segmented into here.
Segments = nSegments;

%number of iterations CGLS should run for
Iterations = nIterations;

%for CPINo=1:nCPIs

%start reading samples of a specific channel from position ... of data 
CPIStartSampleNumber = CPIStartSampleNumber+CPISize_nSamp;

%Read CPI samples to be cancelled
%define the vector size of the CPI
c_m_Reference_data= m_Reference_data(CPIStartSampleNumber+1:CPISize_nSamp...
    *CPINo);
c_m_Surveillance_data = m_Surveillance_data(CPIStartSampleNumber+1:nCPI_Samples...
    *CPINo);

% fprintf('Processing CPI %i of %i:\n',CPINo+1, nCPIs);

%The number of samples per segment
segmentSize_nSamp = floor(CPISize_nSamp/Segments);%nSegments is the factor at which the
%should be divided by for processing. FM system used 8. This is just to
%reduce the memory usage.

%The number of range and Doppler bins over which cancellation will be
%applied
nRangeBins = ceil((cancellationMaxRange - txToRefRxDistance)/(3e8/FS));
nDopplerBinds = ceil(cancellationMaxDoppler/(FS/segmentSize_nSamp)) * 2 + 1;

%The delay in seconds to each sample from the begining of the CPI
sampleTimes_s = 0:1/FS:(segmentSize_nSamp - 1)/FS;

%Note use of copy constructor here.
%You can't just use '=' because cRCF derives handle and it would result in
%pointer type behavior.
%FOR OWN NON-RCF Data comment this section out
oOutputRCF_Lat = cRCF(oInputRCFLat);%figure out this section of Code and why it's necessary

alpha = initialAlpha;

for segmentNo = 0:Segments - 1
    
    fprintf('\t\t* CGLS: Starting cancellation on segment %i of %i:\n', segmentNo, Segments)
    fprintf('\t\t* Range:   %g to %g m, %g bins\n', txToRefRxDistance, cancellationMaxRange_m, nRangeBins)
    fprintf('\t\t* Doppler: %g to %g Hz, %g bins\n', -cancellationMaxDoppler, cancellationMaxDoppler, nDopplerBinds)
    tic
    
    %Start and end sample numbers for this segment
    segStartSampleNo = segmentNo * segmentSize_nSamp + 1;
    segStopSampleNo = segStartSampleNo + segmentSize_nSamp - 1;
    
    %A matrix (As in Ax = b) with only the zero Doppler rows
    ZeroDopplerA=zeros(segmentSize_nSamp, nRangeBins, 'single');    
    
    %Create ZeroDoppler A matrix from RCF object.
    %Each row is the surveillance channel left zero padded
    for i=1:nRangeBins
        ZeroDopplerA(i:segmentSize_nSamp, i)=c_m_Reference_data((segStartSampleNo:segStopSampleNo - (i - 1)));
    end
    
    %The complete A matrix
    A = zeros(segmentSize_nSamp, nRangeBins * nDopplerBinds, 'single');
    K = nRangeBins;
    Pos = 0;
    
    %Create Doppler shifted versions of ZeroDopplerA in  A
    for i=-floor(nDopplerBinds / 2):floor(nDopplerBinds / 2)
        for l=1:K
            A(:,l+Pos)=ZeroDopplerA(:,l).* exp(i * 1j * 2 * pi * sampleTimes_s');
        end
        Pos = Pos + K;
    end
    
    clear ZeroDopplerA
    
    %% Initialize CGLS values
    [m, n] = size(A);
    b    = c_m_Surveillance_data(segStartSampleNo:segStopSampleNo);
    x    = alpha;
    
    %Check for a intial alpha value of zero. 
    %Make sure its a vector of the correct dimension.
    if(mean(x) == 0)
        x = zeros(n, 1, 'single');
    end
    
    
    r    = b - A*x;
    s    = A'*r;     %  s = A'b
    norms0 = norm(s);
    gamma = norms0^2;
    
    p    = s;
    xmax = 0;             normx  = 0;
    k    = 0;             info   = 0;
    
    form = '%5.0f %16.10g %16.10g %9.2g %12.5g %12.8f';
    disp('  ');   disp('    k       x(1)             x(n)           normx        resNE     norm(r)');
    disp( sprintf(form, k,x(1),x(n),normx,1, norm(r)) )
    
    indefinite = 0;
    unstable   = 0;
    
    %---------------------------------------------------------------------------
    %% Main CGLS loop
    %---------------------------------------------------------------------------
    for iterationNo = 1:Iterations
        
        k     = k+1;
        q     = A*p;                % q = A p
        
        delta = norm(q)^2;
        if delta <= 0, indefinite = 1;   end
        if delta == 0, delta      = eps; end
        alpha = gamma / delta;
        
        x     = x + alpha*p;
        if(mod(k,50))
            r     = r - alpha*q;
        else
            r    = b - A*x; %this line recorrects for floating point error every 50 cycles.
        end
        s     = A'*r;    % s = A'r
        
        norms = norm(s);
        gamma1= gamma;
        gamma = norms^2;
        beta  = gamma / gamma1;
        p     = s + beta*p;
        
        %% Convergence
        normx = norm(x);
        xmax  = max( xmax, normx );
        
        %% Output
        resNE = norms / norms0;
        disp( sprintf(form, k,x(1),x(n),normx,resNE,norm(r)) );
    end %while
    
    %save alpha
    alpha = x;
    
    %Data output change variables for own needs except A*alpha
    %Gives output in IQ data
    oOutputLat.m_fvSurveillanceData(segStartSampleNo:segStopSampleNo) = ...
        c_m_Surveillance_data(segStartSampleNo:segStopSampleNo) - (A * alpha);
   
    clear A
    
    fprintf('\t\tCompleted. ')
    toc
    fprintf('\n')  
    
end

clear sampleTimes_s
%end

