%%%%%%%��Ƶƽ�沨�ֽ�(PWD)�㷨%%%%%%%%%%%%%%%%%%%%
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
theta = (0:3:180)/180*pi;
phi = (0:3:360)/180*pi;
Out = zeros(length(theta),length(phi));
for num1 = 1:length(theta)
    num1
    for num2 = 1:length(phi)
        for n = 0:N
            B_n(n^2+1:(n+1)^2) = 1/bn(n+1);
            D_nm(n^2+1:(n+1)^2,1) = SphHarmonic(n,theta(num1),phi(num2));
        end
        Out(num1,num2) = p_nm.'*diag(B_n)*D_nm;
        
    end
end
out = 20*log10(abs(Out));
out = out-max(max(out));
[x,y] = find(out==max(max(out)));
for num1 = 1:length(theta)
    for num2 =1:length(phi)
        if(out(num1,num2)<-22)
            out(num1,num2) = -22;
        end
    end
end
figure
imagesc(phi/pi*180,theta/pi*180,out);
set(gca,'yDir','normal')
colorbar
h = colorbar('fontsize',18);
set(get(h,'Ylabel'),'String','[dB]','Fontsize',18,'Fontname','arial')
% caxis([-20 0])
set(gca,'Fontsize',18)
xlabel('{\it\phi} [deg]');ylabel('{\it\theta} [deg]');zlabel('[dB]')





