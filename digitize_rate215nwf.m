function state=digitize_rate(Vout,num,jump)
%% digitize the Vout => state
%  edit by Gang Li @KU update 20170211
%  num default is 21, jump default is 0.5
%  1st: 
%       i+num......i......i-num 
%       '----_----' '----_----'
%           sum2   -    sum1    =  diffnum(i)
%  diffnum  ----^---v----^----v----^-----v-----
%  2nd:
%  use jump(0.5 of the maxdiff) to find the UP location,          
%  between two UP find the DOWN(min loc) and change the
%  UP to the max loc.
%  3rd:
%  set the state 0 or 1:
%  1----     =======       =========       ========-------
%     (v)    ^     v      ^        v      ^      (v)
%  0----=====       =======         =======        -------
%  end
%% default values
if nargin < 2 || isempty(num)
  num = 21;
end
if nargin < 3 || isempty(jump)
  jump = 0.5;
end
%% 1st part: change Vout to diffnum
Vsize=size(Vout);
diffnum=zeros(Vsize);
sum1=sum(Vout(1:num,:));
sum2=sum(Vout(num+2:2*num+1,:));
diffnum(num+1,:)=sum2./num-sum1./num;          
for ii=num+2:Vsize(1)-num
    sum1=sum1+Vout(ii-1,:)-Vout(ii-num-1,:);
    sum2=sum2+Vout(ii+num,:)-Vout(ii,:);
    diffnum(ii,:)=sum2./num-sum1./num;
end
%% 2nd & 3rd part: find the UP locs and digitize
jumpp=max(abs(diffnum))*jump;
state=zeros(size(Vout)); 
for jj=1:Vsize(2)
    count=0;
    clear UPloc;
    for ii=1:Vsize(1)-1
        if(diffnum(ii+1,jj))>jumpp(jj) && diffnum(ii,jj)<jumpp(jj)
            count=count+1;
            UPloc(count)=ii;
        end            
    end
    [vmin,locmin]=min(diffnum(1:UPloc(1),jj));
    if vmin< -jumpp(jj)*2
        state(1:locmin-1,jj)=1;
    end
    for ii=1:count-1
        [~,locmax]=max(diffnum(UPloc(ii):UPloc(ii+1),jj));
        [~,locmin]=min(diffnum(UPloc(ii):UPloc(ii+1),jj));
        state(UPloc(ii)+locmax-1:UPloc(ii)+locmin-2,jj)=1;
    end
    [~,locmax]=max(diffnum(UPloc(count):Vsize(1),jj));
    [vmin,locmin]=min(diffnum(UPloc(count):Vsize(1),jj));
    if vmin< -jumpp(jj) %% *0 deleted coz last point of WF can be 0 or 1 
        state(UPloc(count)+locmax-1:UPloc(count)+locmin-2,jj)=1;
    else
        state(UPloc(count)+locmax-1:Vsize(1),jj)=1;
    end
end
%%%%%%%%%%%% end of function %%%%%%%%%%%%%%%%%%%%%%%%%%%%