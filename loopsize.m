% loop_size
Vcjj=-10:10;
for i=1:numel(Vcjj)
 
%     name = sprintf('rfloop_%01i_*_Vcjj(%.04fV)_avg.dat',i-1,Vcjj(i));
    name = sprintf('rfloop_*_Vcjj(%.04fV)_avg.dat',Vcjj(i));
    %name = sprintf('rfloop_%01i_*_avg.dat',i-1);
    filename = dir(name);
    DD=importdata(filename.name,'\t',20);
    Vrf=DD.data(:,1);
    Vout=DD.data(:,2);
    diffVout=diff_num(Vout,21);
    [mm,locmax]=max(diffVout);
    [mm,locmin]=min(diffVout);
    dVrf(i)= (Vrf(locmax)-Vrf(locmin))/100;% factor 100 comes from conversion
    cVrf(i)=(0.5*(Vrf(locmax)+Vrf(locmin)))/100; % 100 conversion comes from conversion
end
%%
figure(1)
plot(Vcjj,dVrf,'*')
xlabel('{\itV}_{cjj}(V)')
ylabel('d{\itV}_{qx}(\muV)')
%%
figure(2)
plot(Vcjj,cVrf,'*')
xlabel('{\itV}_{cjj}(V)')
ylabel('c{\itV}_{qx}(\muV)')
P1 = polyfit(Vcjj(3:10), cVrf(3:10), 1);
fit1 = (polyval(P1, Vcjj));
hold on 
plot(Vcjj,fit1)
hold off
fit_equation1=['cVqx=',num2str(P1(1),'%.3f'),'*Vcjj ',num2str(P1(2),'%+.3f')];
    text(-1.6,-200,fit_equation1,'color',[1 0 0]);


% %I use diff_num()
% function diffnum=diff_num(data,num)
% 
% if nargin < 2 || isempty(num)
%   num = 21;
% end
% Dsize=size(data);
% diffnum=zeros(Dsize);
% sum1=sum(data(1:num,:));
% sum2=sum(data(num+2:2*num+1,:));
% diffnum(num+1,:)=sum2./num-sum1./num;          
% for ii=num+2:Dsize(1)-num
%     sum1=sum1+data(ii-1,:)-data(ii-num-1,:);
%     sum2=sum2+data(ii+num,:)-data(ii,:);
%     diffnum(ii,:)=sum2./num-sum1./num;
% end
% end
%  diffVout=diff_num(Vout,21);