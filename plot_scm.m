x_smc = Xm(1,:,1);
b_smc = Xm(2,:,1);
var_x = 0.1;    %variance of parameter x
var_b = 1e-10;  %variance of parameter b
x_initial = X0(1);
b_initial = X0(2);
for l=1:length(x_smc)
    x_pdf(l)=normpdf(x_smc(l),x_initial,sqrt(var_x));
end
for l=1:length(b_smc)
    b_pdf(l)=normpdf(b_smc(l),b_initial,sqrt(var_b));
end
figure;
scatter(x_smc,x_pdf);
title('initial set of particles using SMC sampling');
xlabel('capacity x');
ylabel('probability');
text(1.2,1.2,'Cell 1');
figure;
scatter(b_smc,b_pdf);
title('initial set of particles using SMC sampling');
xlabel('degradation factor b');
ylabel('probability');
text(-2.52e-3,3e4,'Cell 1');