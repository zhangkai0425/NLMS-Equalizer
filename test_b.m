% 测试模式代码 test
M = 16;
Size = 5000;
sim=randi([0,M-1],[Size,1]);
channel = [0.5,1,1.2,-1];

MQAM = qammod(sim,M);
SI = MQAM;

% figure();
% plot(SI,'r*')
% title("S(i)散点图");
% axis([-4,4,-4,4]);

SI_H = conv(channel,SI);
% 加入白噪声v(i)
SNR = 30;
UI = awgn(SI_H,30,'measured');

% figure();
% plot(UI,'g*')
% title("U(i)散点图");

MQAM_Points = qammod(0:M-1,M);

% 测试模式-test
UI_P = [zeros(35-16,1);UI;zeros(20,1)];

X_P = UI_P;


% 0为NLMS模式;1为LMS模式
mode = 1;
if(mode==0)
    load C_NLMS.mat
end
if(mode==1)
    load C_LMS.mat
end   
Cs = [C_150,C_300,C_500];

for idx = 1:3
    decision(X_P,idx,mode,Cs(:,idx),MQAM_Points,SI);
end

function [] = decision(X_P,idx,mode,C,MQAM_Points,SI)
CStr = [150;300;500];
result_int = zeros(5000,1);
result = zeros(5000,1);
% 面向判决模式
for j = 1:5000
    yk = X_P(j+34:-1:j).'*C;
  
    [~,argmin] = min(abs(yk-MQAM_Points));
    yk_pre = MQAM_Points(argmin);
    
    result_int(j) = yk;
    result(j) = yk_pre;
    
    Xs = X_P(34+j:-1:j);
    ek = SI(j) - yk;
    
    if(mode==0)
        miu = 0.4;
        epsilon = 0.001;
        C = C + conj((miu*conj(ek)*Xs)/(epsilon + Xs'*Xs));
    end   
    if(mode==1)
        miu = 0.001;
        C = C + conj((miu*conj(ek)*Xs));
    end   
end  

subplot(1,3,idx);
plot(result_int,'b*')
title(["均衡器输出散点图  训练迭代次数",num2str(CStr(idx))]);
end

