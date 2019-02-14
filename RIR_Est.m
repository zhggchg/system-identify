% 函数功能 ：估计房间脉冲响应及混响时间，该方法无需同步采集参考信号
close all;
clc;
clear;

%麦克风捕获信号：
[rec_x,fs]=audioread('F:\Data\sogou\Rec_Data_2019_1_12\Room1\Cir1\FW\SN1\[Cir1_FW_H87_SN1_EnN59][S1_MT_Azi300_Ele0_Dis300]\SPL\White_Noise\White_Noise_Ch7.wav');
%非同步参考信号：
[ref_x,fs1]=audioread('F:\Data\sogou\merge_corpus\white_noise.wav'); 


res_fs=((fs-5):0.2:(fs+5)); % 重采样的频率范围
if(abs(fs-fs1)>0.01)
    error('the sampling rate of recorded signal and reference signal should be same');
end
[xcor,lag]=xcorr(rec_x,ref_x);
figure;
plot(lag,xcor);
grid on
title('参考信号与麦克风采集信号的相关函数（重采样前）')
[Res_Data,Opt_fs]=Opt_Resample(rec_x,ref_x,fs,res_fs);
rec_x=Res_Data;
[xcor,lag]=xcorr(rec_x,ref_x);
figure;
plot(lag,xcor);
grid on;
title('参考信号与麦克风采集信号的相关函数（重采样后）')

[~,I]=max(xcor);
Shift_I=lag(I);
if(Shift_I>0)
    rec_x=rec_x(Shift_I+1000:end);
end
if(Shift_I<0)
    Shift_I=abs(Shift_I);
    ref_x=ref_x(Shift_I+1000:end);
end

figure;
plot(rec_x/max(rec_x));
hold on;
x=ref_x/max(ref_x);
hold on;
plot(x);
L=8192;
d1=rec_x/max(rec_x);
tic 
Rxx=Est_Rxx(x,L,2);
Rxy=Est_Rxy(x,d1,L,2);
toc
tic
gpu_Rxx=gpuArray(Rxx);
gpu_Rxy=gpuArray(Rxy);
gpu_w_ori=gpu_Rxx\gpu_Rxy;
w_ori=gather(gpu_w_ori);
toc
figure;
plot((1:L)/fs,w_ori);
grid on;
ylabel('响应幅度')
xlabel('时间/s');
legend('实验房间脉冲响应');

addpath('F:\My_Work\Speech_Processing\T60 Estimate\using rir');
[rt,iidc] = t60(w_ori,fs);
fprintf('reverbration time T60 of room is %4.2f ms',rt);

function [Res_Data,Opt_fs]=Opt_Resample(x,ref_x,fs,res_fs)
% resample signals  
% 最优重采样信号
max_idx=0;
max_value=0;
Ori_Idx=(1:length(x))/fs;
    for i=1:length(res_fs)
        New_Idx=(100:length(x)-100)/res_fs(i);
        Res_x=interp1(Ori_Idx,x,New_Idx,'spline');
%         Res_x=resample(x,fs,res_fs(i));
        [xcor]=xcorr(Res_x,ref_x);
        if(max(abs(xcor))>max_value)
            max_value=abs(max(xcor));
            max_idx=i;
        end
    end
    New_Idx=(100:length(x)-100)/res_fs(max_idx);
    Res_Data=interp1(Ori_Idx,x,New_Idx);
%     Res_Data=resample(x,fs,res_fs(max_idx));
    Opt_fs=res_fs(max_idx);
 
end

