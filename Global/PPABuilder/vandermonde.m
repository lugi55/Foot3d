function A = vandermonde(v,order)

%function to derive the Vandermonde matrix of order 
%INPUT
%data to build vandermonde matrix on
%order of polynomial
%
%OUTPUT
% Vandermonde

A = ones(size(v,1),order+1);
for i = 1:order
    A(:,i+1) = (v(:,1).^i);
end
end