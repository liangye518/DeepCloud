function m = sqdist(p, q, A)
% SQDIST      Squared Euclidean or Mahalanobis distance.
% SQDIST(p,q)   returns m(i,j) = (p(:,i) - q(:,j))'*(p(:,i) - q(:,j)).
% SQDIST(p,q,A) returns m(i,j) = (p(:,i) - q(:,j))'*A*(p(:,i) - q(:,j)).

% Written by Tom Minka

[d, qn] = size(q);
[d, pn] = size(p);

if pn == 0 || qn == 0
  m = zeros(pn,qn);
  return
end

if nargin == 2
  
  pmag = sum(p .* p);
  qmag = sum(q .* q);
  m = repmat(qmag, pn, 1) + repmat(pmag', 1, qn) - 2*p'*q;
  %m = ones(pn,1)*qmag + pmag'*ones(1,qn) - 2*p'*q;
  
else

  Ap = A*p;
  Aq = A*q;
  pmag = sum(p .* Ap);
  qmag = sum(q .* Aq);
  m = repmat(qmag, pn, 1) + repmat(pmag', 1, qn) - 2*p'*Aq;
  
end
