function W = KendallCoef(X)
% Compute the Kendall's coefficient of concordance of the matrix X.
% E.g. KenCoef = KendallCoef(RankMatrix)
%
% Input:
%           X must be a N-by-K matrix, N is the number of
%           "candidate" and the K is the number of "judge"
% Outputs:
%           W = Kendall's coefficient of concordance
%
% Edited by Lijie Huang, 2010/6/5
%==========================================================================
[N,K] = size(X);
RankMatrix = zeros(N,K);
for i = 1:K
    temp = X(:,i);
    [a,b] = sortrows(temp);
    RankMatrix(b,i) = 1:N;
end
ranksum = sum(RankMatrix,2);
S1 = sum(ranksum.^2,1);
S2 = (sum(ranksum))^2;
S = S1 - S2/N;
temp = N^3 - N;
W = 12*S/(K^2*temp);
end