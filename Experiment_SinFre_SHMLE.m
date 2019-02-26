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
K = 1024;%����֡����
N = 1;%������չ������
%%
load('w_cal.mat');%������У׼�ļ�
[data,fs] = audioread('ListeningRoom_390Hz.wav');%������ʵ������
% [data,fs] = audioread('AnechoicChamber_390Hz.wav');%������ʵ������
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
X = zeros(K,M);%���źű任��Ƶ��
for m = 1:M
    x_p(:,m) = data([1:K]+flags(11),m);
    X(:,m) = fft(x_p(:,m));
end

I = floor(390/fs*K)+2;%��Ƶ��Ӧ������λ��
%%
bn = zeros(N+1,1);
ka = 2*pi*390/c*a;
for n = 0:N
    bn(n+1) = 4*pi*(1j)^n*SphBesselj(n,ka);
end
%%
Y_nm = zeros((N+1)^2,M);%������г����
for n = 0:N
    for m = 1:M
        Y_nm(n^2+1:(n+1)^2,m) = SphHarmonic(n,Mic_Theta(m),Mic_Phi(m));
    end
end
X_nm = zeros(1,(N+1)^2);
X_nm(1,:) = 4*pi/M*X(I,:)*Y_nm';%��г�任
X_nm = X_nm.';
%%
theta = (0:3:180)/180*pi;
phi = (0:3:360)/180*pi;
Out = zeros(length(theta),length(phi));
for num1 = 1:length(theta)
    num1
    for num2 = 1:length(phi)
        for n = 0:N
            D_nm(n^2+1:(n+1)^2,1) = bn(n+1)*conj(SphHarmonic(n,theta(num1),phi(num2)));%���㹫ʽ(20)
        end
        Out(num1,num2) = norm(X_nm-D_nm*pinv(D_nm)*X_nm);%���Ĺ�ʽ(20)
    end
end
out = -20*log10(abs(Out));
out = out-max(max(out));
[x,y] = find(out==max(max(out)));
figure
imagesc(phi/pi*180,theta/pi*180,out)
colorbar;set(gca,'ydir','normal')
% axis([0 360 0 180 -22 0])
caxis([-17 0])
set(gca,'Fontsize',18)
xlabel('{\it\phi} [deg]');ylabel('{\it\theta} [deg]');
