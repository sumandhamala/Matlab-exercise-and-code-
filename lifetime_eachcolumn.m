dbstop if error
%% This programme is used to calculate the average life time for a particular CJJ voltage. 
%% coded  by Suman Dhamala: 06-21-2017

vcjj= -5.1;   
DD=length(vcjj); %no of vcjj

columns=100; rows=65536; discard=0; columnused=columns-discard;  
timeperiod=1; %freq=1Hz
Dignum=7; %no. of data points to sum to find diff in digitization function
% vout_tot(totalpoints,1)=0;
%jump=0.6;
period=8.1;
%%
vrff(1,5)=0;
map_vout(65536,97)=0; 


for j= 5;%:18%:MM %no of vrf with same vcjj
%% Import data from string
name= sprintf('lifetime_%01i_*_Vcjj(%.04fV).dat',j-1,vcjj);
filename = dir(name); %lifetime_ 3_Vin(1.4600V)_Vsq(0.8607V)_Vrf(-1.3900V)_Vcjj(-4.4000V)
if isempty(filename) 
continue; 
end
Data=importdata(filename.name,'\t',20);
Fname=filename.name;
find1=strfind(Fname,'(');
find2=strfind(Fname,'V)');
% % vsq(j)=str2double(Fname(find1(2)+1:find2(2)-1)); % string to get the value 
vrff(j)=str2double(Fname(find1(3)+1:find2(3)-1));
vrf= vrff(vrff~=0);

%% Getting data from file
v_q =Data.data(:,1);
v_out =Data.data(:,(discard+1):columns);
time = (0:1.5259e-05:1); %making the time series so need to plot graph with time not the point 

%% maapping 
for k=1:columnused
map_vout(:,k)=(v_out(:,k)-min(v_out(:,k)))/(max(v_out(:,k))-min(v_out(:,k)));
end
%% using self created digitize function to get state 
state=digitize(map_vout,Dignum); 
state(state==0)=-1; 
ssize=size(state);
%% get UP and DOWN points
clear UP DOWN;
for kk=1:columnused
    
if state(1, kk)==1
count1 =1;
count0 =0;
UP(1,kk)=count1;
else
count1 =0;
count0 =1;
DOWN(1,kk)= count0;
end

for ii=2:length(state) %totalpoints
if state(ii,kk)~=state(ii-1,kk)
if state(ii,kk)==1
    count1=count1+1;
    UP( count1, kk)= 1;
else
    count0=count0 +1;
    DOWN(count0, kk)= 1;
end        
else
if state(ii,kk)==1
    UP(count1, kk)= UP(count1, kk)+1;
else
    DOWN(count0, kk)= DOWN(count0, kk)+1;
end        
end    
end
%% calculate time of each part up and down
prob1(1,97)=0;prob0(1,97)=0;
prob1(kk)=sum(UP(:,kk))/65536;
prob0(kk)=sum(DOWN(:,kk))/65536;
UP (:,kk)= (UP(:,kk)./65536 )*timeperiod;
DOWN(:,kk)= ( DOWN(:,kk)./65536 )*timeperiod;
%check=sum(UP (:,kk))+sum(DOWN(:,kk)); % this should be equal to total timePERIOD
% UP = UP(UP~=0);
% DOWN = DOWN(DOWN~=0);
b=size(UP);
c=size(DOWN);
% UP(UP == 0 ) = [];
% DOWN(DOWN == 0 ) = [];
% reshape(UP,b(2)-1,b(1));
% UP(UP(:,b(2))==0, :) = [];
% DOWN(DOWN(:,c(2))==0, :) = [];
%%
tauup(kk)=0;taudown(kk)=0;
tauup(kk)= sum(UP (:,kk))./nnz(UP (:,kk));% mean(total_up)for short 
taudown(kk)= sum(DOWN (:,kk))./nnz(DOWN (:,kk));
end

end 
Tau_upmean = mean(tauup);
Tau_downmean = mean(taudown);
std_Tau_upmean=std(tauup);
std_Tau_downmean=std(taudown);
uncer_up = std_Tau_upmean/sqrt(length(tauup));
uncer_down = std_Tau_downmean/sqrt(length(taudown));

%% calculate Energy bias
epsilon= (log(Tau_upmean./Tau_downmean)); %epsilon=log(tau1/tau0)=log(gamma01/gamma10)

%% Uncertanity in Epsilon propagation from equation
uncer_epsilon= sqrt( ( uncer_up./ Tau_upmean).^2 + ( uncer_down./ Tau_downmean).^2  );

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4)
histup=histogram(tauup,25);
figure(5)
histdown=histogram(taudown,25);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %% standard way to fixed binsize
% tau_average= mean(UP (:,kk));% mean(total_up)for short 
% maxt= 5*tau_average;
% binnum=15;
% binsize= maxt/binnum;
% binup=0.0:binsize:maxt;
% exclude=2;
% %%
% figure(100+kk)
% histup=histogram(UP(:,kk),binup);
% up_edgess=(histup.BinEdges(1:binnum)+histup.BinEdges(2:binnum+1))./2;
% up_edges=up_edgess( exclude:binnum);
% 
% up_valuee= histup.Values;
% up_value= up_valuee(exclude:binnum);
% up_weight= 1./(up_value); %weight in matlab is different than that of Igor
% up_weight(up_weight==inf)=0;
% %%
% ft = fittype( 'y0+A*exp(-(x- x0)/tau)','independent','x','coefficients',{'y0','A','x0','tau'});
% optsu = fitoptions( 'Method', 'NonlinearLeastSquares' );
% optsu.Display = 'Off';
% optsu.StartPoint = [0 up_value(1) 0 tau_average]; %up_value(numel(up_value))
% optsu.Weights = up_weight;
% %% Fit model to data.
% [fitresultu,tofu]= fit( up_edges', up_value', ft, optsu );
% tau1=fitresultu.tau;
% uncer_u=diff(confint(fitresultu)/2);%uncertanity is given by subtracting max and min and dividing by 2
% tau1SE=uncer_u(4);
% %%
% plot( fitresultu,up_edges', up_value');
% hold on
% errorbar(up_edges,up_value,sqrt(up_value),-sqrt(up_value),'b.')
% disp(fitresultu)
% xlabel('\it Time (s)');
% ylabel('\it Count');
% title(['Average lifetime of the state 1 @Vcjj:',num2str(vcjj),'V']);
% grid on
% fit_stru=[' \it \tau = ( ' , num2str(fitresultu.tau,'%+.6f'),'\pm',num2str(tau1SE,'%.6f'),')s'];
% hleg=legend({'foo', 'bar'}, 'Location', 'best');
% axes('position', get(hleg, 'position'));
% text(-2,0.3,fit_stru,'color',[0 0 1]);
% axis off
% delete(hleg);
% hold on
% %text(0.15,100,fit_str,'color','b');
% %%
% yfitup=feval(fitresultu, up_edges); % gives the fitted y value
% for kkk=1:numel(up_value)
% chisquaree(kkk)=((up_value(kkk) - yfitup(kkk)))^2/up_value(kkk);
% end
% chisquaree(chisquaree==inf)=0;
% chi2up=sum(chisquaree);
% %%
% nn = length(up_edges);                % number of data points
% m = 4;                                 % number of fitting parameters a1, a2, ...
% reduce_chi2up=chi2up/(nn-m);
% disp(reduce_chi2up);
% 
% fit_st=['{\it \chi^2}_{reduced} =  ', num2str( reduce_chi2up,'%+.2f')];
% text(-2,-0.5,fit_st,'color','b');
% hold off
% %% Goodness-of-Fit
% tgof = '   *** Acceptable Fit   ***';
% if reduce_chi2up > 1, tgof = '   ??? Fit may not be acceptable ???'; end;
% if reduce_chi2up <= 1, tgof = '   ? Fit may be too good ?'; end;
% disp(tgof);
% 
% 



