%%%%%%%%%%%%%%%%%%�����������Ȼ(SHMLE)��Դ��λ�㷨%%%%%%%%%%%%%%%%%%%
% �������ڷ�λ��Ϊ��           5----------8
%                          6/---------7/ |
%                          |  |       |  |
%                          |  1-------|--4
%                          2/---------3 /
%
%          ����ϵ��         ^
%                       z  |
%                          |
%                          | ------>    y
%                         / o
%                        /
%                   x   ~
%%
clear
MicPos = [ -0.08   -0.08   -0.08 %��������Ԫֱ������ϵλ��
    0.08   -0.08   -0.08
    0.08    0.08   -0.08
    -0.08    0.08   -0.08
    -0.08   -0.08    0.08
    0.08   -0.08    0.08
    0.08    0.08    0.08
    -0.08    0.08    0.08
    ];
a = 0.08*sqrt(3);%�����а뾶a
[Mic_Phi,Mic_Theta,Mic_R] = cart2sph(MicPos(:,1),MicPos(:,2),MicPos(:,3));%ֱ������ϵ������������ϵ
Mic_Theta = pi/2-Mic_Theta;%���ǵ���
M = 8;%��������Ŀ
c = 340;%����
K = 2048;%����֡����
N = 1;%������չ������
%%
load('w_cal.mat');%������У׼�ļ�
% [data,fs] = audioread('ListeningRoom_Whitenoise.wav');%������ʵ������
[data,fs] = audioread('AnechoicChamber_Whitenoise.wav');%������ʵ������
for num = 1:M
    data(:,num) = filter(w_cal(:,num),1,data(:,num));%�ֱ��ÿ�������������ݽ���У׼
end
FrameNumber = floor(length(data(:,1))/K);%�����յ������ݷ�֡
FrameFlag = zeros(FrameNumber,1);%������Ч�Ա��
cnt = 0;
for num = 1:FrameNumber
    if(sum(data((num-1)*K+1:num*K,1).^2)>10*1e-5)%�ж������Ƿ���Ч
        FrameFlag(num) = 1;
        cnt = cnt+1;
        flags(cnt) = (num-1)*K+1;%��Ч֡������ʼλ��
    else
        FrameFlag(num) = 0;
    end
end
%%
Fu = round(K*c*N/(fs*2*pi*a));%����Ƶ�������� ka ~ [0.5 1]
Fl = round(Fu/2);
%%
X = zeros(K,M);%���źű任��Ƶ��
for m = 1:M
    x_p(:,m) = data([1:K]+flags(4),m);
    X(:,m) = fft(x_p(:,m));
end
%%
Bn = zeros((N+1)^2,Fu);%����bn(ka)
for k = 1:Fu
    ka = 2*pi*k/K*fs/c*a;
    for n = 0:N
        Bn(n^2+1:(n+1)^2,k) = 4*pi*(1j)^n*SphBesselj(n,ka);
    end
end
%%
Y_nm = zeros((N+1)^2,M);%������г����
for n = 0:N
    for m = 1:M
        Y_nm(n^2+1:(n+1)^2,m) = SphHarmonic(n,Mic_Theta(m),Mic_Phi(m));
    end
end
X_nm = zeros(Fu,(N+1)^2);%��ͬƵ����г�任���
for k = 1:Fu
    X_nm(k,:) = 4*pi/M*X(k+1,:)*Y_nm';
end
X_nm = X_nm.';

%%
theta = (0:3:180)/180*pi;%���ֿռ�����
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
            d_nm = diag(Bn(:,k))*conj(P_nm);%����dnm
            temp = temp+norm(X_nm(:,k)-d_nm*pinv(d_nm)*X_nm(:,k))^2;%���Ĺ�ʽ(19)
        end
        Out(num1,num2) = temp;
    end
end

Out1 = -10*log10(Out);
imagesc(phi/pi*180,theta/pi*180,Out1-max(max(Out1)))
colorbar;set(gca,'ydir','normal')
% caxis([-17 0])
set(gca,'Fontsize',18)
xlabel('{\it\phi} [deg]');ylabel('{\it\theta} [deg]');zlabel('[dB]')






