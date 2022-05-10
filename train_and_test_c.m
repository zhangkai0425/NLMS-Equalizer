% clear;

M = 256;
Size = 500;
sim=randi([0,M-1],[Size,1]);
channel = [0.5,1,1.2,-1];

MQAM = qammod(sim,M);
SI = MQAM;

figure();
plot(SI,'r*')
title("S(i)ɢ��ͼ");
% axis([-4,4,-4,4]);

SI_H = conv(channel,SI);
% ���������v(i)
SNR = 30;
UI = awgn(SI_H,30,'measured');

figure();
plot(UI,'g*')
title("U(i)ɢ��ͼ");

% ��������
epsilon = 10^(-6);
Delta = 15;
L = 35;    % ����������
miu = 0.4; % u

% ������ģ��
C = zeros(L,1);

UI_P = [zeros(35-16,1);UI;zeros(20,1)];
X_P = UI_P;

% ѵ��ģʽ-train
for j = 1:500
    yk = C'*X_P(j+34:-1:j);
    Xs = X_P(34+j:-1:j);
    ek = SI(j) - yk;
    C = C + (miu*conj(ek)*Xs)/(epsilon + Xs'*Xs);
end  
X = UI;
Y = conv(X,C);
Ys = Y(16:end);
Ys = Ys(1:500);
C_256 = C;
save('C_256.mat',"C_256");

figure;
plot(Ys,'*');
title("QPSK�����ѵ������Ч��ͼ");


% test ����
M = 256;
Size = 5000;
sim=randi([0,M-1],[Size,1]);
channel = [0.5,1,1.2,-1];

MQAM = qammod(sim,M);
SI = MQAM;

SI_H = conv(channel,SI);
% ���������v(i)
SNR = 30;
UI = awgn(SI_H,30,'measured');

% ����ģʽ-test
UI_P = [zeros(35-16,1);UI;zeros(20,1)];

X_P = UI_P;
result_int = zeros(5000,1);
result = zeros(5000,1);

MQAM_Points = qammod(0:M-1,M);

% �����о�ģʽ
for j = 1:5000
    yk = X_P(j+34:-1:j).'*C;
    [~,argmin] = min(abs(yk-MQAM_Points));
    yk_pre = MQAM_Points(argmin);
    
    result_int(j) = yk;
    result(j) = (yk_pre==SI(j));
    
    Xs = X_P(34+j:-1:j);
    ek = SI(j) - yk;
    C = C + conj((miu*conj(ek)*Xs)/(epsilon + Xs'*Xs));
end  
figure();
plot(result_int,'y*')
SER = 1-sum(result)/length(result);
title(["256-QAM-5000�����о��������ɢ��ͼ,SER:"+num2str(SER*100)+"%"]);



