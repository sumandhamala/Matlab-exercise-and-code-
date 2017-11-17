

%% variable quantity
Vcjj=-5.1; 
VVrf=-3.0; 
real_freq=1;                         % the freq set in the Labview 
delay= 80;
feedbackpoint= 16220-delay;
NameIndex=113;                     %need to run more than one file as we are taking mean in the code
period=8.2;

%% The value of qubit voltage and corresponding energy bias
XVrf=[-3.06, -3.03, -3, -2.97, -2.94];  % lifetime6
epsilon=[-2.56274; -1.47352; 0; 1.56457; 2.50008]; %% OFFSET OF 0.00568

%XVrf=[-3.09,-3.06,-3.03,-3,-2.97,-2.94,-2.91,-2.88];
%epsilon=[-5.30301386857667;-3.51503329686686;-1.87371822521416;-0.407888468775535;1.17249039071537;2.15956629217710;3.01354485658015;5.07541732471747];
xlim([1, 810]);

%% import the data
real_rate=65536;               % the rate set in the Labview
NameHead='demon';
NN=length(NameIndex);          % file count
rows=100;
Rline=10.30;                    % resistance in qubit flux line(Kohm)

C00=0;C01=0;C11=0;C10=0;choose=0;
%%%%%%% import data from file %%%%%%%%%%%%%

for   ii=1:NN
    name = sprintf('%s_%1i_*Vrf(%.4fV)*_Vcjj(%.4fV).dat',NameHead,NameIndex(ii),VVrf,Vcjj);
    filename=dir(name);
    DD=importdata(filename.name,'\t',20);
    Vout=DD.data(delay+1:65536+delay, 3:100); 
    Vrf=DD.data(1:66536-1000, 1);
    A=filename.name;
    A1=strfind(A,'(');
    A2=strfind(A,'V)');
    cVrfset=str2double(A(A1(3)+1:A2(3)-1)); 
    TEXT=DD.textdata;

%% digitize to state 
    Dignum=21;
    jump=0.5;
    state=digitize_rate215nwf(Vout,Dignum,jump);
    state(state==0)=-1; %%% convention of state +-1

%% checking if there is bad columns in a file 
AAA=find(state(real_rate/4,:)==1 | state(real_rate/2,:)==1 | state(real_rate*3/4,:)==1 );
while ~isempty(AAA)&& Dignum>3
    Dignum=Dignum-1;
    state(:,AAA)=digitize_rate215nwf(Vout(:,AAA),Dignum,jump);
    AAA=find(state(real_rate/4,:)==1 | state(real_rate/2,:)==1 | state(real_rate*3/4,:)==1 );
end
state(:,AAA)=[];
Vout(:,AAA)=[];
Ssize=size(state);
%% clear to save memory
% clear VVout MaxIndix MinIndix id allMax allMin A A1 A2 DD DDsize 
% clear ffreq filename freqnum Maxlimit Minlimit name Pdelay RIndix freq 
% clear NameHead NameIndex NN rate freq 

%% Getting fit value of energy bias
Xphix=(XVrf-cVrfset)/period+0.5;
linefit=fittype('a*x+b','independent','x','coefficients',{'a','b'});
fit_epsilon=fit(Xphix',epsilon,linefit,'StartPoint', [1000,-500]);

%% Energy bias as a function of phix
phix=(Vrf-cVrfset)/period+0.5;
%E= round(fit_epsilon(phix)+ 0.6680,5);%0.667996885033290;   
E=round(fit_epsilon(phix)-0.00568,5); %% need to change in calc_work_heat function


%% Dividing waveform into four parts
X00=1:Ssize(1)/4;
X01=Ssize(1)/4+1:Ssize(1)/2;
X11=Ssize(1)/2+1:Ssize(1)*3/4;
X10=Ssize(1)*3/4+1:Ssize(1);

%% %%%%%%%%%%%% get four right conditions %%%%%%%%%%%%
for i=1:Ssize(2)     
        if state(feedbackpoint,i)== -1
            C00=C00+1;
            S00(X00,C00)=state(X00 ,i);
        end
% if state(Ssize(1)*2/8+feedbackpoint,i)==-1
% C01=C01+1;
% S01(X00,C01)=state(X01 ,i);
% end
%         if state(Ssize(1)*4/8+feedbackpoint,i)==-1
%             C11=C11+1;
%             S11(X00,C11)=state(X11 ,i);
%         end
% if state(Ssize(1)*6/8+feedbackpoint,i)==-1
% C10=C10+1;
% S10(X00,C10)=state(X10 ,i);
% end
        
end
%%
W00(X00,C00)=0;
Q00(X00,C00)=0;
% W01(X00,C01)=0;
% Q01(X00,C01)=0;
% W11(X00,C11)=0;
% Q11(X00,C11)=0;
% W10(X00,C10)=0;
% Q10(X00,C10)=0;
%%
% EE=E(Ssize(1)/4+1:Ssize(1)/2);
% EEE=E(Ssize(1)/2+1:Ssize(1)*3/4);
% EEEE=E(Ssize(1)*3/4+1:Ssize(1));
for k= 2:Ssize(1)/4
W00(k,:)=   W00(k-1,:)-S00(k,:)*(E(k)-E(k-1)); 
Q00(k,:)=   Q00(k-1,:)-0.5*( S00(k,:)-S00(k-1,:) )*( E(k)+E(k-1))*0.5;

% W01(k,:)=   W01(k-1,:)-S01(k,:)*(EE(k)-EE(k-1)); 
% Q01(k,:)=   Q01(k-1,:)-0.5*( S01(k,:)-S01(k-1,:) )*( EE(k)+EE(k-1))*0.5;
% 
% W11(k,:)=   W11(k-1,:)-S11(k,:)*(EEE(k)-EEE(k-1)); 
% Q11(k,:)=   Q11(k-1,:)-0.5*( S11(k,:)-S11(k-1,:) )*( EEE(k)+EEE(k-1))*0.5;
% 
% W10(k,:)=   W10(k-1,:)-S10(k,:)*(EEEE(k)-EEEE(k-1)); 
% Q10(k,:)=   Q10(k-1,:)-0.5*( S10(k,:)-S10(k-1,:) )*( EEEE(k)+EEEE(k-1))*0.5;
end

%% deleting colums which are all zero
columnsWithAllZeros = all(Q00 == 0);
Q00 = Q00(:, ~columnsWithAllZeros);

% columnsWithAllZerosS = all(Q01 == 0);
% Q01 = Q01(:, ~columnsWithAllZerosS);
% 
% columnsWithAllZerosSS = all(Q11 == 0);
% Q11 = Q11(:, ~columnsWithAllZerosSS);
% 
% columnsWithAllZerosSSS = all(Q10 == 0);
% Q10 = Q10(:, ~columnsWithAllZerosSSS);
% columnsWithAllZeross = all(W00 == 0);
% W00 = W00(:, ~columnsWithAllZeross);

%% save mean of each file in a matrix
%  meanvsq(ii,:)= mean(state');
% 
% meanW00(ii,:)=mean(W00');
%  meanQ00(ii,:)=mean(Q00');

% meanW01S(ii,:)=mean(W01');
% meanQ01S(ii,:)=mean(Q01');
% 
% meanW11S(ii,:)=mean(W11');
% meanQ11S(ii,:)=mean(Q11');
% 
% meanW10S(ii,:)=mean(W10');
% meanQ10S(ii,:)=mean(Q10');

end
 %% select particular rows which are bad and delete it
%meanQ00S([23 24 49],:)=[]; 
% figure(173);plot(mean(meanvsq));grid on
% 
%  time=(1:length(Q00))*1/real_freq/real_rate*1000; % converting each part points to time in ms
%  totalT=(1:real_rate)*1/real_freq/real_rate*1000; % converting points to time in ms
%  
% cc=1;
% figure(1)
% subplot(3,1,2);
% plot(time,S00(X00, cc),'r')
% xlabel('\it time (ms)')
% ylabel('\it State')
% ylim([-1, 1.2])
% %xlim([0,260])
%  grid on
%  subplot(3,1,3);
% plot( time,Q00(:, cc), 'b');
% %ylim([min(E),  max(E)])
% %xlim([0,260])
% ylabel('\it Q00S/k_BT (cumulative)')
% xlabel('\it time (ms)')
% grid on
% subplot(3,1,1);
% plot(time, E(1:16384), 'b');
% ylim([min(E(1:16384)),  max(E(1:16384))])
% %xlim([0,260])
% xlabel('\it time (ms)')
% ylabel('\it \epsilon/k_BT ')
% grid on
% 
% figure(37847);plot((Q00S));grid on
% figure(37);plot(meanQ00S');grid on
% figure(3676);
%  S_00=histogram(W00');
% %%
% cc=50;
% figure(2)
% subplot(3,1,2);
% plot(S00flat(:, cc),'r') %time(X00ramp)
% ylim([-1, 1.2])
% xlabel('\it time (ms)')
% ylabel('\it State')
% %xlim([0,260])
%  grid on
% subplot(3,1,3);
% plot( Q00flat(:, cc), 'b');
% %ylim([min(E),  max(E)])
% %xlim([0,260])
% ylabel('\it Q00S/k_BT (cumulative)')
% xlabel('\it time (ms)')
% grid on
% subplot(3,1,1);
% plot( E(X00flat), 'b');
% ylim([min(E(1:16384)),  max(E(1:16384))])
% %xlim([0,260])
% xlabel('\it time (ms)')
% ylabel('\it \epsilon/k_BT ')
% grid on
%%

% figure(30);
% plot(time,mean(AAA(:,1:5)'),'m')
% ylabel('\it < Q00S/k_BT > (cumulative)')
% xlim([0,260])
% xlabel('\it time (ms)')

% plot(time,Q00(:, cc),'m');
% xlabel('\it time (ms)')
% xlim([0,260])
% ylabel('\it Q00S/k_BT')
% %ylim([-1,5])
% grid on 