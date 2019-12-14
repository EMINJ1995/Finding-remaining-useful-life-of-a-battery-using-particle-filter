function outIndex = residualR(inIndex,q)
if nargin < 2
error('Not enough input arguments.'); 
end
[S,arb] = size(q);
N_babies= zeros(1,S);
q_res = S.*q';
N_babies = fix(q_res);
N_res=S-sum(N_babies);
if (N_res~=0)
  q_res=(q_res-N_babies)/N_res;
  cumDist= cumsum(q_res);   
  u = fliplr(cumprod(rand(1,N_res).^(1./(N_res:-1:1))));
  j=1;
  for i=1:N_res
    while (u(1,i)>cumDist(1,j))
      j=j+1;
    end
    N_babies(1,j)=N_babies(1,j)+1;
  end;
end;
index=1;
for i=1:S
  if (N_babies(1,i)>0)
    for j=index:index+N_babies(1,i)-1
      outIndex(j) = inIndex(i);
    end;
  end;   
  index= index+N_babies(1,i);   
end
