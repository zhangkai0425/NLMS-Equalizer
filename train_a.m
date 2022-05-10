% clear;
load train.mat

% 参数设置
epsilon = 10^(-6);
Delta = 15;
L = 35;    % 均衡器长度
miu = 0.4; % u

% 均衡器模型
C = zeros(L,1);

X = UI;
UI_P = [zeros(35-16,1);UI;zeros(20,1)];
X_P = UI_P;

% 训练模式-train
for j = 1:500
    yk = C'*X_P(j+34:-1:j);
    Xs = X_P(34+j:-1:j);
    ek = SI(j) - yk;
    C = C + (miu*conj(ek)*Xs)/(epsilon + Xs'*Xs);

end  

Y = conv(X,C);
Ys = Y(16:end);
Ys = Ys(1:500);

save('C.mat',"C");
plot(Ys,'*');
title("QPSK均衡后效果图");
