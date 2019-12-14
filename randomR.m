function outIndex = randomR(inIndex,q)
if nargin < 2
    error('Not enough input arguments.'); 
end
outIndex=zeros(size(inIndex));
[num,col]=size(q);
u=rand(num,1);
u=sort(u);
l=cumsum(q);
i=1;
for j=1:num
    while (i<=num)&(u(i)<=l(j))
        outIndex(i)=j;
        i=i+1;
    end
end
