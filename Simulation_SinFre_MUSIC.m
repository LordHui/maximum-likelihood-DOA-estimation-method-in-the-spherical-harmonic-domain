%%%%%%%��Ƶ��г�������Ȼ(SHMLE)�㷨%%%%%%%%%%%%%%%%%%%%
clear
a = 0.139;%�����а뾶
c = 340;%����
ka = 3.142;%��Bessel��������ӦƵ��
Theta_l = 90/180*pi;%��Դλ��
Phi_l = 180/180*pi;
load('position32.mat')%������λ�ã��뾶Ϊ1
M = 32;%��������Ŀ
N = 4;%չ������
MicPos = position32*a;
[Mic_Phi,Mic_Theta,Mic_R] = cart2sph(MicPos(:,1),MicPos(:,2),MicPos(:,3));%ֱ������ϵ������������ϵ
Mic_Theta = pi/2-Mic_Theta;%���ǵ���
%%
bn = zeros(51,1);%����bn(ka)
for n = 0:50
    bn(n+1,1) = 4*pi*(1j)^n*SphBesselj(n,ka);
end
%%
p = zeros(M,1);%��Ƶʱ��M������������ѹ
for m = 1:M
    for n = 0:50
        Bn = bn(n+1)*eye(2*n+1);
        p(m,1) = p(m,1)+(SphHarmonic(n,Theta_l,Phi_l))'*...
            Bn*SphHarmonic(n,Mic_Theta(m),Mic_Phi(m));
    end
end
p = awgn(p,20,'measured');%�������
%%
Y_nm = zeros((N+1)^2,M);%������г����
for num = 1:M
    for n = 0:N
        Y_nm((n^2+1:(n+1)^2),num) = SphHarmonic(n,Mic_Theta(num),Mic_Phi(num));
    end
end
p_nm = 4*pi/M*conj(Y_nm)*p;%�źŴ�Ƶ��任����г��
%%
Bn = zeros((N+1)^2,1);
for n = 0:N
    Bn(n^2+1:(n+1)^2) = bn(n+1);
end
L = 1;%��Դ��Ŀ 
a_nm = p_nm./Bn;
S = a_nm*a_nm';
[V,D] = eig(S);
[Y,I] = sort(diag(D));
E = V(:,I(1:end-L));%���������ӿռ�
%%
theta = (0:3:180)/180*pi;
phi = (0:3:360)/180*pi;
P_music = zeros(length(theta),length(phi));%MUSIC��
for num1 = 1:length(theta)
    num1
    for num2 = 1:length(phi)
        y_nm = zeros(1,(N+1)^2);
        for n = 0:N
            y_nm(1,n^2+1:(n+1)^2) = SphHarmonic(n,theta(num1),phi(num2)).';
        end
        P_music(num1,num2) = 1/(y_nm*E*E'*y_nm');
    end
end
out = 10*log10(abs(P_music));
out = out-max(max(out));
[x,y] = find(out==max(max(out)));

figure
imagesc(phi/pi*180,theta/pi*180,out);
h = colorbar('fontsize',16);
set(get(h,'Ylabel'),'String','[dB]','Fontsize',16,'Fontname','arial')
set(gca,'yDir','normal')
set(gca,'Fontsize',16)
xlabel('{\it\phi} [deg]');ylabel('{\it\theta} [deg]');
