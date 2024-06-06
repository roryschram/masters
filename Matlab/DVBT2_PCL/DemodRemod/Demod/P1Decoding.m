function [MISO, NFFT, FEF, guardint] = P1Decoding(DVBT2)
%Description: Descrambling, Demapping and Decoding

%Reference: Implementation guidelines for a second genereation digital
%terrestrial television broadcasting system (DVB-T2), p161

%Inputs:  DVBT2 - 1024 FFT of P1 symbol
%Outputs: MISO - miso/siso
%         NFFT - FFT size
%         FEF - Future Extension Frame toggle
%		  guardint - possible guard intervals

%% 1. Extraction of active carriers in P1 symbol
ActiveCarrierIDx = [44 45 47 51 54 59 62 64 65 66 70 75 78 80 81 82 84 85 87 ...
              88 89 90 94 96 97 98 102 107 110 112 113 114 116 117 119 ...
              120 121 122 124 125 127 131 132 133 135 136 137 138 142 ...
              144 145 146 148 149 151 152 153 154 158 160 161 162 166 ...
              171 172 173 175 179 182 187 190 192 193 194 198 203 206 ...
              208 209 210 212 213 215 216 217 218 222 224 225 226 230 ...
              235 238 240 241 242 244 245 247 248 249 250 252 253 255 ...
              259 260 261 263 264 265 266 270 272 273 274 276 277 279 ...
              280 281 282 286 288 289 290 294 299 300 301 303 307 310 ...
              315 318 320 321 322 326 331 334 336 337 338 340 341 343 ...
              344 345 346 350 352 353 354 358 363 364 365 367 371 374 ...
              379 382 384 385 386 390 395 396 397 399 403 406 411 412 ...
              413 415 419 420 421 423 424 425 426 428 429 431 435 438 ...
              443 446 448 449 450 454 459 462 464 465 466 468 469 471 ...
              472 473 474 478 480 481 482 486 491 494 496 497 498 500 ...
              501 503 504 505 506 508 509 511 515 516 517 519 520 521 ...
              522 526 528 529 530 532 533 535 536 537 538 542 544 545 ...
              546 550 555 558 560 561 562 564 565 567 568 569 570 572 ...
              573 575 579 580 581 583 584 585 586 588 589 591 595 598 ...
              603 604 605 607 611 612 613 615 616 617 618 622 624 625 ...
              626 628 629 631 632 633 634 636 637 639 643 644 645 647 ...
              648 649 650 654 656 657 658 660 661 663 664 665 666 670 ...
              672 673 674 678 683 684 689 692 696 698 699 701 702 703 ...
              704 706 707 708 712 714 715 717 718 719 720 722 723 725 ...
              726 727 729 733 734 735 736 738 739 740 744 746 747 748 ...
              753 756 760 762 763 765 766 767 768 770 771 772 776 778 ...
              779 780 785 788 792 794 795 796 801 805 806 807 809];
 
C_PS = 853; % active carriers per symbol in 1024 symbol
NFFT = 1024; % 1K FFT size
C_LOC = NFFT/2-(C_PS-1)/2+1:NFFT/2+(C_PS-1)/2+1; % FFT bins for used carriers
DVBT2_AC = DVBT2(C_LOC); %Extract active carriers in 1K symbol
 
DVBT2_384 = DVBT2_AC(ActiveCarrierIDx+1); %384 Active Carriers in P1 symbol

%figure()
%plot(abs(DVBT2_384))
%title('P1 Decoding Active Carriers Before Hard Decision Mapping')

% Hard decision mapping all the + to 1 and all the - to -1
DVBT2_384(DVBT2_384>0) = 1;
DVBT2_384(DVBT2_384<0) = -1;

%figure()
%plot(DVBT2_384)
%title('P1 Decoding Active Carriers After Hard Decision Mapping')

dim = size(DVBT2_384);
if dim(1)==1
    DVBT2_384 = DVBT2_384.';
end
%% 2. Descrambling using pseudo random binary sequence (defined in DVBT2 standard)
% Scrambler PRBS generation
Prbs = zeros(1,384); % initialize output
x = [1 0 0 1 1 1 0 0 1 0 0 0 1 1 0];
for k = 1:384 
  xNext(1) = xor(x(14),x(15));  
  xNext(2:15) = x(1:14);      % PG (X)=1+X^14+X^15
  x = xNext;
  Prbs(k) = x(1);
end

Prbs = double(Prbs);
Prbs(Prbs==0) = -1;
Prbs = Prbs.*-1;
Prbs = Prbs.';

DescrambledDVB = DVBT2_384.*Prbs; %Descrambled
%% 3. DBPSK Demodulation
DemodDVB = vertcat(1,DescrambledDVB);
DemodDVB = (filter([1 1],1,DemodDVB)); %differential decoding
DemodDVB = (abs(DemodDVB(2:end)))==0; %Demodulated

%% 4. Extraction of Concatenated Signalling Sequences (CSS)
CSS1 = DemodDVB(1:64);
CSS12 = DemodDVB(321:384);
CSS2 = DemodDVB(65:320);

negCSS1 = CSS1;
negCSS1  =double(negCSS1);
negCSS1(negCSS1==0)=-1;

negCSS12 = CSS12;
negCSS12  =double(negCSS12);
negCSS12(negCSS12==0)=-1;

negCSS2 = CSS2;
negCSS2  =double(negCSS2);
negCSS2(negCSS2==0)=-1;
%% 5. Decsion of applied CSS using MSS sequence
%Orthogonal Codes related to the first three bytes of P1 code
MSS1_HEX = ['124721741D482E7B';  % 000
                '47127421481D7B2E';  % 001
                '217412472E7B1D48';  % 010
                '742147127B2E481D';  % 011
                '1D482E7B12472174';  % 100
                '481D7B2E47127421';  % 101
                '2E7B1D4821741247';  % 110
                '7B2E481D74214712']; % 111
%Orthogonal Codes related to the first three bytes of P1 code

MSS2_HEX = ['121D4748212E747B1D1248472E217B7412E247B721D174841DED48B82EDE7B8B';  % 0000
                '4748121D747B212E48471D127B742E2147B712E2748421D148B81DED7B8B2EDE';  % 0001
                '212E747B121D47482E217B741D12484721D1748412E247B72EDE7B8B1DED48B8';  % 0010
                '747B212E4748121D7B742E2148471D12748421D147B712E27B8B2EDE48B81DED';  % 0011
                '1D1248472E217B74121D4748212E747B1DED48B82EDE7B8B12E247B721D17484';  % 0100
                '48471D127B742E214748121D747B212E48B81DED7B8B2EDE47B712E2748421D1';  % 0101
                '2E217B741D124847212E747B121D47482EDE7B8B1DED48B821D1748412E247B7';  % 0110
                '7B742E2148471D12747B212E4748121D7B8B2EDE48B81DED748421D147B712E2';  % 0111
                '12E247B721D174841DED48B82EDE7B8B121D4748212E747B1D1248472E217B74';  % 1000
                '47B712E2748421D148B81DED7B8B2EDE4748121D747B212E48471D127B742E21';  % 1001
                '21D1748412E247B72EDE7B8B1DED48B8212E747B121D47482E217B741D124847';  % 1010
                '748421D147B712E27B8B2EDE48B81DED747B212E4748121D7B742E2148471D12';  % 1011
                '1DED48B82EDE7B8B12E247B721D174841D1248472E217B74121D4748212E747B';  % 1100
                '48B81DED7B8B2EDE47B712E2748421D148471D127B742E214748121D747B212E';  % 1101
                '2EDE7B8B1DED48B821D1748412E247B72E217B741D124847212E747B121D4748';  % 1110
                '7B8B2EDE48B81DED748421D147B712E27B742E2148471D12747B212E4748121D']; % 1111

%Check for which code is which CSS is it by exploiting code properties.
%Largest peak in PeakSoAC corresponds to that code.
PeakSoAC1 = zeros(1,8);
PeakSoAC12 = zeros(1,8);
PeakSoAC2 = zeros(1,16);

for k = 1:16
    mss2Hex = MSS2_HEX(k,:);
    mss2 = [];
    for k1=1:8:64
        mss2 = strcat(mss2,dec2bin(hex2dec(mss2Hex(k1:k1+7)),32));
    end
    mss2 = (mss2=='1');
    mss2 = double(mss2);
    mss2(mss2==0) = -1;
    mss2 = mss2.';
    
    cross = zeros(31,1);
    for j = 1:16
        cross = cross+xcorr(negCSS2(((j-1)*16+1):j*16),mss2(((j-1)*16+1):j*16));
    end
    PeakSoAC2(k) = max(cross);
end

for k = 1:8
    mss1Hex = MSS1_HEX(k,:);
    mss1 = [];
    mss1 = strcat(dec2bin(hex2dec(mss1Hex(1:8)),32),dec2bin(hex2dec(mss1Hex(9:16)),32));

    mss1 = (mss1=='1');
    mss1 = double(mss1);
    mss1(mss1==0) = -1;
    mss1 = mss1.';
    
    cross = zeros(15,1);
    cross1 = zeros(15,1);
    for j = 1:8
        cross = cross+xcorr(negCSS1(((j-1)*8+1):j*8),mss1(((j-1)*8+1):j*8));
        cross1 = cross1+xcorr(negCSS12(((j-1)*8+1):j*8),mss1(((j-1)*8+1):j*8));
    end
    PeakSoAC1(k) = max(cross);
    PeakSoAC12(k) = max(cross1);
end

PeakSoAC1 = PeakSoAC1+PeakSoAC12;
S1 = find(PeakSoAC1 == max(PeakSoAC1));
S2 = find(PeakSoAC2 == max(PeakSoAC2));
S1 = S1 -1;
S2 = S2-1;
S1 = S1(1);
S2 = S2(1);

%% 6. FFT size and MISO/SISO using extracted CSS
switch S1
	case 0
		MISO = 0;
        FEF = [];
		disp('P1 Decoding: T2 SISO Enabled');
	case 1
		MISO = 1;
        FEF = [];
		disp('P1 Decoding: T2 MISO Enabled');
    case 2
        MISO = [];
        FEF = 'FEF';
        disp('P1 Decoding: FEF Part - Cannot Decode. Moving to next P1 symbol in data set');
	otherwise
		MISO = [];
        FEF = 'FEF';
        disp('P1 Decoding: Reserved for Future use. Moving to next P1 symbol in data set');
end


S2 = de2bi(S2, 4, 2, 'left-msb');
	if S2(1:3)== [0 0 0]
		NFFT = 2048;
		guardint = [1/16 1/8 1/4];
    elseif S2(1:3)==  [0 0 1]
		NFFT = 8192;
		guardint = [1/128 1/32 1/16 19/256 1/8 19/128 1/4];
    elseif S2(1:3)==  [0 1 0]
		NFFT = 4096;
		guardint = [1/32 1/16 1/8 1/4];
    elseif S2(1:3)==  [0 1 1]
		NFFT = 1024;
		guardint = [1/16 1/8 1/4];
    elseif S2(1:3)==  [1 0 0]
		NFFT = 16384;
		guardint = [1/128 1/32 1/16 19/256 1/8 19/128 1/4];	
    elseif S2(1:3)==  [1 0 1]
		NFFT = 32768;
		guardint = [1/128 1/32 1/16 19/256 1/8 19/128 1/4];		
    elseif S2(1:3)==  [1 1 0]
		NFFT = 8192;
		guardint = [1/128 1/32 1/16 19/256 1/8 19/128 1/4];		
    elseif S2(1:3)==  [1 1 1]
		NFFT = 32768;
		guardint = [1/128 1/32 1/16 19/256 1/8 19/128 1/4];		
    else
		error('S2 is undefined')
    end

if isempty(FEF)
    fprintf('P1 Decoding: NFFT = %u \n',NFFT);
else
    disp('No FFT size can be applied')
end
		
end