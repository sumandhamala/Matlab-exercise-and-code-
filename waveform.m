n=16000; cVrf=0;dVrf=4;out=zeros(1,n);
for i=1:n
% if ( i< 2*n/20 )
% out(i)= cVrf-dVrf  + dVrf/(2*n/20)   *( i -0);
% elseif (i<3*n/20)
% out(i)=cVrf;
% elseif (i< 5*n/20)
% out(i)=cVrf -  dVrf/(2*n/20)   *( i -3*n/20 ) ;
% elseif (i< 7*n/20)
% out(i)=cVrf - dVrf+ dVrf/(2*n/20)   *( i -5*n/20 ) ;
% elseif (i< 8*n/20)
% out(i)=cVrf ;
% elseif (i< 10*n/20)
% out(i)=cVrf +  dVrf/(2*n/20)   *( i -8*n/20 ) ;
% elseif (i< 12*n/20)
% out(i)=cVrf + dVrf-  dVrf/(2*n/20)   *( i -10*n/20 ) ;
% elseif (i< 13*n/20)
% out(i)=cVrf ;
% elseif (i< 15*n/20)
% out(i)=cVrf +   dVrf/(2*n/20)   *( i -13*n/20 ) ;
% elseif (i< 17*n/20)
% out(i)=cVrf + dVrf-  dVrf/(2*n/20)   *( i -15*n/20 ) ;
% elseif (i< 18*n/20)
% out(i)=cVrf ;
% elseif (i<= 20*n/20)
% out(i)=cVrf -  dVrf/(2*n/20)   *( i -18*n/20 ) ;
%% second waveform
% if (i<n/8)
% out(i)= cVrf-dVrf  + dVrf/(n/8)    *( i -0);
% elseif (i<2*n/8)
% out(i)= cVrf           - dVrf/(n/8)    *( i -n/8);
% elseif (i<4*n/8)
% out(i)= cVrf-dVrf  + dVrf/(n/8)    *( i -2*n/8);
% elseif (i<5*n/8)
% out(i)= cVrf+dVrf  - dVrf/(n/8)    *( i -4*n/8);
% elseif (i<6*n/8)
% out(i)= cVrf          + dVrf/(n/8)    *( i -5*n/8);
% elseif (i<=8*n/8)
% out(i)= cVrf+dVrf  -  dVrf/(n/8)    *( i -6*n/8);
%% third waveform
if ( i< 8*n/20 )
out(i)= cVrf-dVrf  + dVrf/(8*n/20)   *( i -0);
elseif (i<16*n/20)
out(i)=cVrf;
elseif (i<= 17*n/20)
out(i)=cVrf - dVrf/(17*n/20)   * i  ;
elseif (i<= 20*n/20)
out(i)=cVrf - dVrf ;


end
end
%% 4th waveform
plot([0,4,6,6.5,7,7.5],[-1,0,0,1,-1,-1],[0,4,6,6.5,7,7.5],[-1,0,0,-1,-1,-1])
grid on
 set(gca,'xticklabel',[])
 set(gca,'yticklabel',[])
text(4,0.05,'center')
xlabel('\it\bf time')
ylabel('\it\bf qubit voltage ')
legend('Arb.waveform 1','Arb.waveform 2')
% end
figure(347637);
plot(out,'m','linewidth',2.5)
grid on;
%grid minor;
text(40,0.3,'center')
xlabel('\it\bf time')
ylabel('\it\bf qubit voltage ')
grid on 
%   xticks([-3*pi -2*pi -pi 0 pi 2*pi 3*pi])
% xticklabel({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'})
% ytick([-1 -0.8 -0.2 0 0.2 0.8 1])
% set(gca,'xtick',[])
% set(gca,'xticklabel',[])
% % set(gca,'ytick',[])
% set(gca,'yticklabel',[])
