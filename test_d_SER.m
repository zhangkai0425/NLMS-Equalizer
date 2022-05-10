clear;
load C.mat
% C.mat保存了(a)中训练得到的均衡器参数
C0 = C;
Size = 5000;
figure;
for M = [4,16,64,256]
    [SNRs,SER] = snr_ser(M,C0,Size);
    plot(SNRs,SER);
    hold on;
end

xlabel('SNR(dB)');
ylabel('SER');
title(["SNR-SER曲线图"+",序列点数:"+ num2str(Size)]);
legend('M=4','M=16','M=64','M=256');


function [SNRs,SER] = snr_ser(M,C0,Size)
SNRs = 5:1:30;
SER = zeros(length(SNRs),1);
% 均采用Size个点判决

sim=randi([0,M-1],[Size,1]);
channel = [0.5,1,1.2,-1];
MQAM = qammod(sim,M);
SI = MQAM;
SI_H = conv(channel,SI);

% 参数设置
epsilon = 10^(-6);
% Delta = 15;
% L = 35;    % 均衡器长度
miu = 0.4; % u  
for k = 1:length(SNRs)
    % 根据不同的SNR加入白噪声v(i)
    SNR = SNRs(k);
    UI = awgn(SI_H,SNR,'measured');
    % 补齐
    UI_P = [zeros(35-16,1);UI;zeros(20,1)];
    X_P = UI_P;
    result_int = zeros(5000,1);
    result = zeros(5000,1);
    MQAM_Points = qammod(0:M-1,M);
    C = C0;
    % 面向判决模式
    for j = 1:Size
        yk = X_P(j+34:-1:j).'*C;
        [~,argmin] = min(abs(yk-MQAM_Points));
        yk_pre = MQAM_Points(argmin);

        result_int(j) = yk;
        result(j) = (yk_pre==SI(j));
        Xs = X_P(34+j:-1:j);
        ek = SI(j) - yk;
        C = C + conj((miu*conj(ek)*Xs)/(epsilon + Xs'*Xs));
    end  
    SER(k) = (1 - sum(result)/length(result));
end
end

