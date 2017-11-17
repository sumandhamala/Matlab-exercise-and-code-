p=0:0.00001:1;
H(1,numel(p))=0;
for i=1:length(p)
H(i)=-p(i)* log(p(i))-(1-p(i)) *log(1-p(i));
end
figure(134541);
plot(p,H,'m','linewidth',2 )
ylabel('\it\bf Shannon Entropy (nat)','Fontsize',13)
xlabel('\it\bf Probability','Fontsize',13)
%ylim([-0.9, 0.8])
grid on
get(gca, 'XTick'); 
set(gca, 'Fontsize',14);