%%
clc;
clear;

%% Load battery data
cellOne = xlsread('cell1.xls','Sheet1'); 
cellTwo = xlsread('cell2.xls','Sheet1'); 
cellThree = xlsread('cell3.xls','Sheet1'); 

N=length(cellThree);
if N>168
    N=168;   
end
t=1:N;
dt = 1;
Zmeasured(1,1:N)=cellThree(1:N,:)'; %measured data
Future_Cycle=43;    % prediction starts 68 cycles before the end of data 118 93 68 43
start=N-Future_Cycle; % prediction starts at 100th cycle

%% initial value of model parameters

%x=unifrnd(1.91, 1.932); %for cell one
%x =unifrnd(2.01, 2.037); %for cell two
x=unifrnd(1.929, 1.945); %for cell three

%b=unifrnd(-0.002515, -0.002389); %for cell one
%b=unifrnd(-0.003414, -0.003257); %for cell two
b=unifrnd(-0.002038, -0.001947); %for cell three

X0=[x,b]';

%% Parameters for Particle Filter
M=500; %no of particles
p = 2; %no of parameters
Xparam=zeros(p,N); %Matrix to keep track of changing x and b values
Xparam(:,1)=X0;    %Initialization of parameter matrix 
 
%% Process Noise and Measurement Noise
var_x = 0.1;    %variance of parameter x
var_b = 1e-10;  %variance of parameter b
Q = diag([var_x,var_b]);

%sd_z = 0.03123; %for cell one
%sd_z = 0.03801; %for cell two
sd_z = 0.02371; %for cell three
 
F=eye(p);
R=0.001;
 
%% Monte Carlo Simulation
Xm=zeros(p,M,N);
for i=1:M
    Xm(:,i,1)=X0+sqrtm(Q)*randn(p,1);
end

%% Particle Collection Matrix
Xcollection(:,1) = (datasample(Xm(1,:,1),10))';
XcollectionIndex(:,1)=1;
 
%% Particle Filter Initialization
Zm=zeros(1,M,N);
Xestimated=zeros(1,N);
W=zeros(N,M);

%% Particle Filtering
for k=2:N
    %% state transition equations
    for i=1:M
        %Xm(:,i,k)=F*Xm(:,i,k-1)+sqrtm(Q)*randn(2,1);
        Xm(1,i,k)=Xm(1,i,k-1)*exp(Xm(2,i,k-1)*(k-(k-1)))+sqrt(var_x)*randn();
        Xm(2,i,k)=Xm(2,i,k-1)+sqrt(var_b)*randn();
       
    end
    
    %Update particle sample matrix to show particles on plot
    if(mod(k,25)==0 && k<=start )
        ind = size(XcollectionIndex,2);
        Xcollection(:,ind+1) = (datasample(Xm(1,:,k),10))';
        XcollectionIndex(:,ind+1)=k;
    end
    
    %% Weighing of particles
    for i=1:M
   
        %Zm(1,i,k)=feval('hfun',Xm(:,i,k),k);
        Zm(1,i,k)=Xm(1,i,k)+ sd_z*randn();                     
        W(k,i)=exp(-(Zmeasured(1,k)-Zm(1,i,k))^2/2/R)+1e-99; % calculate weight of each particle
    end
 
    %% Resampling based on weights
    W(k,:)=W(k,:)./sum(W(k,:));
    outIndex = residualR(1:M,W(k,:)');        
    Xm(:,:,k)=Xm(:,outIndex,k);
    
    %Update particle sample matrix to show particles on plot
    if(mod(k,25)==0 && k<=start )
        ind = size(XcollectionIndex,2);
        Xcollection(:,ind+1) = (datasample(Xm(1,:,k),10))';
        XcollectionIndex(:,ind+1)=k+2;
    end
    
    %% Mean value of particles
    %Zpf(1,k)=feval('hfun',Xpf(:,k),k);
    Xestimated(1,k)=mean(Xm(1,:,k));
    Bestimated(1,k)=mean(Xm(2,:,k));
    Xparam(:,k)=[Xestimated(1,k);Bestimated(1,k)];
    
end

%% RUL estimation
noOfCycles = 250;
initial_value=Zmeasured(1,1);
threshold = 0.75;
threshold_capacity = threshold*initial_value;
flag = 0;
%% Extrapolation Matrix
Xextrapolated(1,1)= Xestimated(1,start);
Bmean = Bestimated(1,start);
cycle(1,1)=start;

%%
for k=start+1:noOfCycles
    Xextrapolated(1,k-start+1)=Xextrapolated(1,k-start)*exp(Bmean*dt);
    cycle(1,k-start+1)=k;
    %RUL
    if Xextrapolated(1,k-start+1)<= threshold_capacity && flag==0
    flag = 1; 
    failure_index = k;
    failure_capacity = Xextrapolated(1,k-start+1);
    end      
end
noOfCyclesLeft =  failure_index-start;

%% Post Processing
figure
hold on;box on;
plot(Xestimated,'-r*')  
plot(Zmeasured,'-b.')   
plot(cycle,Xextrapolated,'-.g.') 
plot([start start]',[0 2]','g','LineWidth',2);
plot([failure_index failure_index]',[0 failure_capacity]','r','LineWidth',2);
title({'Battery Capacity vs Cycle';'Ck = Ck-1 *exp(b*dt)'});
ylabel('Battery Capacity');
xlabel('Cycle');
legend('Predicted Capacity','Measured Capacity','Extrapolated Capacity','Prediction Start Point','Failure Threshold');
RULText = ['RUL is ',num2str(noOfCyclesLeft),' Cycles']; 
text(150,1.65,RULText,'FontSize',14);
text(10,2.4,'cell 3','FontSize',14);
for i=1:length(XcollectionIndex)
      for j=1:10
        if mod(i,2) == 0
            scatter(XcollectionIndex(i),Xcollection(j,i),'filled',...
                'MarkerEdgeColor',[0 .5 .5],...
                'MarkerFaceColor',[0 .7 .7],...
                'LineWidth',1.5);
        else
            scatter(XcollectionIndex(i),Xcollection(j,i),'filled',...
                'MarkerEdgeColor',[0.7 0.7 0],...
                'MarkerFaceColor',[1 1 0],...
                'LineWidth',1.5);
        end
        end
end







