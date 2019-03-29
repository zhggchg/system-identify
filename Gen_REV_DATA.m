clc;
clear;
%  仿真生成多通道混响信号
file_name='T60=400ms-1-L';
addpath('./ISM');
[Src,fs]=audioread('white_noise.wav');    
load(file_name)
Data=filter(RIR_cell{1,1},1,Src);
% Data=ISM_AudioData(file_name,Src');
audiowrite([file_name,'.wav'],Data,fs);
