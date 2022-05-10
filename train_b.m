% clear;
load train.mat

% ��������
epsilon = 10^(-6);
Delta = 15;
L = 35;    % ����������
miu = 0.4; % u

% ������ģ��
C = zeros(L,1);

UI_P = [zeros(35-16,1);UI;zeros(20,1)];
X_P = UI_P;
% 0ΪNLMSģʽ;1λLMSģʽ
mode = 1;
% ѵ��ģʽ-train
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
% title("QPSK�����Ч��ͼ");
