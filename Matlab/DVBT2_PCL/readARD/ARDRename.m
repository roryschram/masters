%This is a script to rename a batch of files with any extension in a
%particular directory. This code should work with any version of Matlab.

clc;clear all;close all;
%% Read the ARDs

ARD_files = dir(fullfile( 'C:\Users\Thatohatsi\Desktop\ARDView\ETTUS Data\Test 19\Batch 12\*.ard'));%This extracts all files with a particular extention i.e. *.ard
%and gives their information such as the names of the files etc.

%% Convert the ARDs
for id = 1:length(ARD_files)%this will loop through all the files in the directory one by one
    
    [~,f] = fileparts(ARD_files(id).name);%gets the name of the file to be renamed
    V = cellfun(@(s)s(end-8:end),cellstr(f),'uni',0);% this section of code extracts a section of the filename. i.e. the last 8 letters of the filename. 
    C = cell2mat(V);
    num = str2double(C);
    
    if ~isnan(num) 
       
        f = [f '.ard']; %this is the file to be renamed
        OPath =  ['C:\Users\Thatohatsi\Desktop\ARDView\ETTUS Data\Test 19\Batch 12\' f]; %filename plus path of the old file to be renamed
        NPath = ['C:\Users\Thatohatsi\Desktop\ARDView\ETTUS Data\Test 19\Batch 12\' sprintf('E%09f.ard', num) ];%new path and name of the file name to be renamed.
        movefile(OPath, NPath);%this takes the old file "OPath" and renames it and stores it in a new path or just replaces the old file in the same directory "NPath
        
    end
end