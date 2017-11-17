%I use diff_num()
function diffnum=diff_num(data,num)

if nargin < 2 || isempty(num)
  num = 21;
end
Dsize=size(data);
diffnum=zeros(Dsize);
sum1=sum(data(1:num,:));
sum2=sum(data(num+2:2*num+1,:));
diffnum(num+1,:)=sum2./num-sum1./num;          
for ii=num+2:Dsize(1)-num
    sum1=sum1+data(ii-1,:)-data(ii-num-1,:);
    sum2=sum2+data(ii+num,:)-data(ii,:);
    diffnum(ii,:)=sum2./num-sum1./num;
end
end