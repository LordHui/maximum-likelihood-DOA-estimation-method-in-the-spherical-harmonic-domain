%%%%%%%%%%%�����г�������Ȼ(SHMLE)�㷨����%%%%%%%%%%%%%%%%%%%%
clear
a = 0.139;%�����а뾶
load('position32.mat');%������λ�ã��뾶Ϊ1
MicPos = position32*a;
[Mic_Phi,Mic_Theta,Mic_R] = cart2sph(MicPos(:,1),MicPos(:,2),MicPos(:,3));%ֱ������ϵ������������ϵ
Mic_Theta = pi/2-Mic_Theta;%���ǵ���
M = 32;%��������Ŀ
c = 340;%����
K = 1024;%����֡����
N = 4;%չ������
%%
[data,fs] = audioread('GaussWhiteNoise.wav');
data1 = resample(data,192000,fs);%Ϊ��֤������ʱ׼ȷ��������������ʱ�󽵲���
fs = 192000;
%%
Theta_s = 90/180*pi;%��Դλ��
Phi_s = 180/180*pi;
Cart_s = a*[sin(Theta_s)*cos(Phi_s),sin(Theta_s)*sin(Phi_s),cos(Theta_s)];%��Դֱ������
tp = zeros(M,1);
for m = 1:M
    Dis = norm(MicPos(m,:)-Cart_s);%����������Դ����ľ���
    TimeDelay(m) = a*fs*(2*a^2-Dis^2)/(2*a^2)/c;%��ʱ����
end
%%

for m = 1:M
    data2(:,m) = resample(data1([961:end-960]+round(TimeDelay(m))),16000,fs);%����������ʱ�󽵲���
end
fs = 16000;
%%
Fu = round(K*c*N/(fs*2*pi*a));%����Ƶ�������ޣ�ka ~ [3 4]
Fl = ceil(K*c*3/(fs*2*pi*a));
%%
x_p = zeros(K,M);%���������֡ʱ���ź�
X = zeros(K,M);%Ƶ���ź�
for m = 1:M
    x_p(:,m) = data2(1:K,m);
    X(:,m) = fft(x_p(:,m));
end
%%
Y_nm = zeros((N+1)^2,M);
for n = 0:N
    for m = 1:M
        Y_nm(n^2+1:(n+1)^2,m) = SphHarmonic(n,Mic_Theta(m),Mic_Phi(m));
    end
end
X_nm = 4*pi/M*conj(Y_nm)*X.';%��г�任
%%
Bn = zeros((N+1)^2,Fu);
for k = 1:Fu
    ka = 2*pi*k/K*fs/c*a;
    for n = 0:N
        Bn(n^2+1:(n+1)^2,k) = 4*pi*(1j)^n*SphBesselj(n,ka);
    end
end
%%
theta = (0:3:180)/180*pi;
phi = (0:3:360)/180*pi;

for num1 = 1:length(theta)
    num1
    for num2 = 1:length(phi)
        temp = 0;
        P_nm = zeros((N+1)^2,1);
        for n = 0:N
            P_nm(n^2+1:(n+1)^2,1) = SphHarmonic(n,theta(num1),phi(num2));
        end
        for k = Fl:Fu
            d_nm = diag(Bn(:,k))*conj(P_nm);
            temp = temp+norm(X_nm(:,k)-d_nm*pinv(d_nm)*X_nm(:,k))^2;
        end
        Out(num1,num2) = temp;
    end
end

Out1 = -10*log10(Out);
figure
imagesc(phi/pi*180,theta/pi*180,Out1-max(max(Out1)));
colorbar
set(gca,'yDir','normal')
% axis([0 360 0 180 -22 0])
set(gca,'Fontsize',18)
xlabel('{\it\phi} [deg]');ylabel('{\it\theta} [deg]');zlabel('[dB]')


