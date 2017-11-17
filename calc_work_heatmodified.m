%% function define to calculate workdone and heat absorbed.
function [WWork,QQheat]=calc_work_heatmodified(SState,XX)
    fit_epsilon = evalin('base', 'fit_epsilon');
    phix = evalin('base', 'phix');
    SSsize= size(SState);
    WWork=  zeros(SSsize);
    QQheat= zeros(SSsize);
    %U_L=1/2*fit_epsilon(phix(XX));
    %U_R=-1/2*fit_epsilon(phix(XX));
    E=round(fit_epsilon(phix(XX)),5);
    %E= fit_epsilon(phix(XX));
    %for jj=1:SSsize(2)
        for ii= 2:SSsize(1)
            if SState(ii,:)== SState(ii-1,:)
%                 %WWork(jj,ii)=WWork(jj,ii-1)+(1-SState(ii,jj))*(U_L(ii)-U_L(ii-1))+ SState(ii,jj)*(U_R(ii)-U_R(ii-1));
%                 WWork(jj,ii)=WWork(jj,ii-1 )-SState(ii,jj)*(E(ii)-E(ii-1));  
%                 QQheat(jj,ii)=QQheat(jj,ii-1);
%             else
%                 WWork(jj,ii)=WWork(jj,ii-1);
%                 %QQheat(jj,ii)=QQheat(jj,ii-1)+(SState(ii,jj)-SState(ii-1,jj))*(U_L(ii)-U_R(ii-1));
%                  QQheat(jj,ii)=QQheat(jj,ii-1)- 0.5*(SState(ii,jj)-SState(ii-1,jj))*( E(ii)+E(ii-1))*0.5;  
%                  
                 
                    WWork(ii, :)= WWork(ii-1, :)- 0.5*SState(ii,:)*(E(ii)-E(ii-1)); % WWork(ii-1, jj)
                    QQheat(ii,:)= QQheat(ii-1,:);
            else
                    WWork(ii,:)= WWork(ii-1,:);
                    %QQheat(jj,ii)=QQheat(jj,ii-1)+(SState(ii,jj)-SState(ii-1,jj))*(U_L(ii)-U_R(ii-1));
                    QQheat(ii,:)= QQheat(ii-1,:)- 0.5*( SState(ii,:)-SState(ii-1,:) )*0.5*( E(ii) + E(ii-1)) ;  %QQheat(ii-1,jj)
            end
        end
    end
%end