%%  Demon experiment for first part of waveform only ,,,,,,,,,"""",,,
% calculate the center\plot the probability\get Tau\get epsilon\find the right Vout\calculate the work. 
% put digitize in C:\Users\*****\Documents\MATLAB or in the same folder where the code is. 
% add checkdata(find min or max not right one)

%% variable quantity
Vcjj=-5; VVrf=-3.99; real_freq=1.25; feedbackpoint=12810; %16220;%15820;
NameIndex=1; period=8.2;
XVrf=[-5.10,-5.05,-5,-4.95,-4.90,-4.85,-4.80];
epsilon=[-6.19893085661616;-4.37692004069891;-1.70990570087699;0.180479975510690;1.37633482702439;3.98563395400798;5.48344994344618];
xlim([1, 1000]);

 %% import the data
Runtime=(now-736883);            % 736883 means 17/07/07
real_rate=65536;               % the rate set in the Labview
%real_freq=1.25;      % the freq set in the Labview 
rate=real_rate/2;              % rate for calculate prob
freq=real_freq*2;              % frequency for calculate prob
Pdelay=freq*5.2/16384*rate*0;  % points delay for AWG trig is 0;for 1208HS change 0 to 1
Pdelay= 100;
Trise=0.350;                     % time of rise (time of the second part)
NameHead='demon';
%NameIndex=7:10;        % name index for the file
NN=length(NameIndex);          % file count
rows=90;
Vout=zeros(real_rate,rows*NN);
Rline=10.30;% resistance in qubit flux line(Kohm)

%% import data
for   ii=1:NN
    %%%%%%% import data from file %%%%%%%%%%%%%
    name = sprintf('%s_%1iAWG_*Vrf(%.4fV)*_Vcjj(%.4fV).dat',NameHead,NameIndex(ii),VVrf,Vcjj);
    filename=dir(name);
    DD=importdata(filename.name,'\t',20);
    %%%%%%%% get Vrf and VVout from data %%%%%%%%%%
    DDsize=size(DD.data);
    allMax=max(DD.data(:,3:DDsize(2)));
    allMin=min(DD.data(:,3:DDsize(2)));
    Maxlimit=mean(allMax)+5*std(allMax);
    Minlimit=mean(allMin)-5*std(allMin);
    MaxIndix=find(allMax<Maxlimit);
    MinIndix=find(allMin>Minlimit);
    id = ismember(MaxIndix,MinIndix);
    RIndix=MaxIndix(id)+2;
    
%     VVout(1:DDsize(1)-Pdelay,1:rows)=DD.data(Pdelay+1:DDsize(1),RIndix(6:rows+5));
%     VVout(DDsize(1)-Pdelay+1:DDsize(1),1:rows)=DD.data(1:Pdelay,RIndix(7:rows+6)); 
%     Vout(:,(ii-1)*rows+1:ii*rows)=VVout;
%     Vout(:,(ii-1)*rows+1:ii*rows)=DD.data(:,6:rows+5);
 Vout=DD.data(:,2:90);
%    Vout=reshape(VVout,[],1); %% reshape is a good function
end
Vrf=DD.data(:,1);
A=filename.name;
A1=strfind(A,'(');
A2=strfind(A,'V)');
cVrfset=str2double(A(A1(3)+1:A2(3)-1)); 
TEXT=DD.textdata;
%% clear to save memory
clear VVout MaxIndix MinIndix id allMax allMin A A1 A2 DD DDsize 
clear ffreq filename freqnum Maxlimit Minlimit name Pdelay RIndix freq ii
clear NameHead NameIndex NN rate freq 

totalT=(1:real_rate)*1/real_freq/real_rate*1000; % converting points to time in ms
map_voutawg=(Vout(:,1)-min(Vout(:,1)))/(max(Vout(:,1))-min(Vout(:,1)));
map_vrf=(Vrf(:,1)-min(Vrf(:,1)))/(max(Vrf(:,1))-min(Vrf(:,1)));

figure(1);plot(totalT,map_vout,'m','linewidth',1.5);hold on;plot(totalT,map_voutawg,'b','linewidth',2);hold on;plot(totalT,map_vrf,'g','linewidth',1)
xlabel('\it time (ms)')
title('Compare AWG output waveform (blue),Sense Voltage (magneta) and calculated waveform ')
figure(10);plot(map_vout,'m','linewidth',1.5);hold on;plot(map_voutawg,'b','linewidth',2);hold on;plot(map_vrf,'g','linewidth',1)
