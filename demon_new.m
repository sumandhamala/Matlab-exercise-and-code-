%% variable quantity
Vcjj=-5.1; 
VVrf=-3.0; 
real_freq=1;                         % the freq set in the Labview 
delay= 00;
feedbackpoint= 16220-delay;
NameIndex=7;                     %need to run more than one file as we are taking mean in the code
period=8.2;

%% The value of qubit voltage and corresponding energy bias
XVrf=[-3.09,-3.06,-3.03,-3,-2.97,-2.94,-2.91,-2.88];
epsilon=[-5.30301386857667;-3.51503329686686;-1.87371822521416;-0.407888468775535;1.17249039071537;2.15956629217710;3.01354485658015;5.07541732471747];
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
E=fit_epsilon(phix);            

%% Dividing waveform into four parts
X00=1:Ssize(1)/4;
X01=Ssize(1)/4+1:Ssize(1)/2;
X11=Ssize(1)/2+1:Ssize(1)*3/4;
X10=Ssize(1)*3/4+1:Ssize(1);
%%
X00ramp=1:11011; %11010
X00flat=11011+1:16253;  %16220
X00fast=16253+1:16384;
%% %%%%%%%%%%%% get four right conditions %%%%%%%%%%%%
for i=1:Ssize(2)     
        if state(feedbackpoint,i)==-1
            C00=C00+1;
            S00(X00,C00)=state(X00 ,i);
            
            S00ramp(X00ramp,C00)=S00(X00ramp,C00);
            S00flat(:,C00)=S00(X00flat,C00);
            S00fast(:,C00)=S00(X00fast,C00);
        end    
end

Eramp=E(X00ramp);
W00ramp(1,C00)=0;
Q00ramp(1,C00)=0;
for k= 2:numel(X00ramp); %2:Ssize(1)/4
W00ramp(k, :)=  W00ramp(k-1,:) -S00ramp(k,:)*(Eramp(k)-Eramp(k-1)); %W00(k-1, :)
Q00ramp(k,:)= Q00ramp(k-1,:)- 0.5*(S00ramp(k,:)-S00ramp(k-1,:))*( Eramp(k)+Eramp(k-1))*0.5;    %Q00(k-1,:)
end

Eflat=E(X00flat);
W00flat(1,1:C00)= W00ramp(11011);
Q00flat(1,1:C00)=Q00ramp(11011);
for k= 2:numel(X00flat);
W00flat(k, :)=  W00flat(k-1,:) -S00flat(k,:)*(Eflat(k)-Eflat(k-1)); %W00(k-1, :)
Q00flat(k,:) = Q00flat(k-1,:)- 0.5*(S00flat(k,:)-S00flat(k-1,:))*( Eflat(k)- Eflat(k-1));    %Q00(k-1,:)
end

Efast=E(X00fast);
W00fast(1,1:C00)= W00flat(16253);
Q00fast(1,1:C00)=Q00flat(16253);
for k= 2:numel(X00fast);
W00fast(k, :)=  W00fast(k-1,:) -S00fast(k,:)*(Efast(k)-Efast(k-1)); %W00(k-1, :)
Q00fast(k,:) = Q00fast(k-1,:)- 0.5*(S00fast(k,:)-S00fast(k-1,:))*( Efast(k)+Efast(k-1))*0.5;    %Q00(k-1,:)
end

W00SS=[W00ramp; W00flat; W00fast];
Q00SS= [Q00ramp; Q00flat; Q00fast];
end
 time=(1:length(Q00SS))*1/real_freq/real_rate*1000; % converting each part points to time in ms
 totalT=(1:real_rate)*1/real_freq/real_rate*1000; % converting points to time in ms
 
cc=8;
figure(1)
subplot(3,1,2);
plot(S00(X00, cc),'r')
xlabel('\it time (ms)')
ylabel('\it State')
ylim([-1, 1.2])
%xlim([0,260])
 grid on
subplot(3,1,3);
plot( Q00SS(:, cc), 'b');
%ylim([min(E),  max(E)])
%xlim([0,260])
ylabel('\it Q00S/k_BT (cumulative)')
xlabel('\it time (ms)')
grid on
subplot(3,1,1);
plot( E(1:16384), 'b');
ylim([min(E(1:16384)),  max(E(1:16384))])
%xlim([0,260])
xlabel('\it time (ms)')
ylabel('\it \epsilon/k_BT ')
grid on
%%
cc=50;
figure(2)
subplot(3,1,2);
plot(S00flat(:, cc),'r') %time(X00ramp)
ylim([-1, 1.2])
xlabel('\it time (ms)')
ylabel('\it State')
%xlim([0,260])
 grid on
subplot(3,1,3);
plot( Q00flat(:, cc), 'b');
%ylim([min(E),  max(E)])
%xlim([0,260])
ylabel('\it Q00S/k_BT (cumulative)')
xlabel('\it time (ms)')
grid on
subplot(3,1,1);
plot( E(X00flat), 'b');
ylim([min(E(1:16384)),  max(E(1:16384))])
%xlim([0,260])
xlabel('\it time (ms)')
ylabel('\it \epsilon/k_BT ')
grid on
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