% clear;
load train.mat

% 参数设置
epsilon = 10^(-6);
Delta = 15;
L = 35;    % 均衡器长度
miu = 0.4; % u

% 均衡器模型
C = zeros(L,1);

UI_P = [zeros(35-16,1);UI;zeros(20,1)];
X_P = UI_P;
% 0为NLMS模式;1位LMS模式
mode = 1;
% 训练模式-train
for j = 1:500
    yk = C'*X_P(j+34:-1:j);
    Xs = X_P(34+j:-1:j);
    ek = SI(j) - yk;
    if(mode==0)
        C = C + (miu*conj(ek)*Xs)/(epsilon + Xs'*Xs);
    end
    if(mode==1)
        miu = 0.001;
        C = C + (miu*conj(ek)*Xs);
    end   
    if(j==150)
        C_150 = C;
    end 
    if(j==300)
        C_300 = C;
    end 
    if(j==500)
        C_500 = C;
    end 
end  
X = UI;
Y = conv(X,C);
Ys = Y(16:end);
Ys = Ys(1:500);
if(mode==0)
    save('C_NLMS.mat',"C_150","C_300","C_500");
else
    save('C_LMS.mat',"C_150","C_300","C_500");
end

% plot(Ys,'*');
% title("QPSK均衡后效果图");
