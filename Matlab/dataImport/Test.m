%read converted pxgf to matlab file and resample to 

clear all

addpath('C:\Users\Motlatsi\Desktop\ComRAD_DVBT2_Recordings')


fileID = fopen('ComRad3_2017-12-01T09.40.33.433000_706.00MHz_UCTMeasurements_1_Surveillance_-31dB_test_13.pxgf_1.m');
Formatspec = '%s %s %*s';
C = textscan(fileID,Formatspec,'CommentStyle','%','EndOfLine','\r\n','Delimiter',' ','HeaderLines',3);
fclose(fileID);

% fileID = fopen('ComRad3_2017-12-01T09.40.33.433000_706.00MHz_UCTMeasurements_1_Surveillance_-31dB_test_13.pxgf_2.m');
% Formatspec = '%s %*s %*s';
% C1 = textscan(fileID,Formatspec,'CommentStyle','%','EndOfLine','\r\n','Delimiter',' ','HeaderLines',3);
% fclose(fileID);

disp('file read completed');

Values = zeros(numel(C{1}),2);

for i1 = 1:numel(C{1})
    Values(i1,1) = str2double(C{1}{i1});
    Values(i1,2) = str2double(C{2}{i1});
end
Values = Values(1:end-7,:);

pxgf_SR_uHz = 12.8e6;

[n,d] = rat((64e6/7)/12.8e6);

Values1 = resample(Values(:,1),n,d);
% Values12 = resample(Values(:,2),n,d);
% Values2 = interp(Values(:,1),n);
% Values2 = decimate(Values2(:,1),d);

% Demodremod(Values1,'BBB',0,1,0)