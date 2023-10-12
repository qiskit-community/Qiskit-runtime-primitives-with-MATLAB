clc;
clear;
close all;
%%
N = 3; % Number of cities
rng default % For reproducibility
stopsLon = 1.5*rand(N,1);
stopsLat = rand(N,1);
plot(stopsLon,stopsLat,"ko")

[X,Y] = meshgrid(1:N);
dist = hypot(stopsLon(X) - stopsLon(Y),stopsLat(X) - stopsLat(Y));


QUBO = tsp2qubo(dist);


Quadratic = full(QUBO.QuadraticTerm);  %% Quadratic term
Linear = full(QUBO.LinearTerm); %% Linear Term


%% Conver the Qubo to Ising Hamiltonian
Qubo = QuadraticProgram(Linear,Quadratic);
[Pauli_terms,Pauli_Coeff, Offset_value] = Qubo.To_ising(Linear, Quadratic)


%% Example of travelling salesman problem and converting it to a Qubo format
function QP = tsp2qubo(dist)
%   QP = TSP2QUBO(DIST) returns a QUBO problem from the traveling salesperson
%   problem specified by the distance matrix DIST. DIST is an N-by-N
%   nonnegative matrix where DIST(i,j) is the distance between locations
%   i and j.

% Copyright 2023 The MathWorks, Inc.

N = size(dist,1);
% Create constraints on routes
A = eye(N);
B = ones(N);
Q0 = kron(A,B);
Q1 = kron(B,A);
% Create upper diagonal matrices of distances
v = ones(N-1,1);
A2 = diag(v,1);
Q2 = kron(B,A2); % Q2 has a diagonal just above the main diagonal in each block
C = kron(dist,B);
Q2 = Q2.*C; % Q2 has an upper diagonal dist(i,j)
% Create dist(j,i) in the upper-right corner of each block
E = zeros(N);
E(1,N) = 1;
Q3 = kron(B,E); % Q3 has a 1 in the upper-right corner of each block
CP = kron(dist',B); % dist' for D(j,i)
Q3 = Q3.*CP; % Q3 has dist(j,i) in the upper-right corner of each block
% Add the multipliers
M = max(max(dist));
QN = sparse(M*(Q0 + Q1)*N^2 + Q2 + Q3);
% Symmetrize
QN = (QN + QN.')/2;

% Include the constant and linear terms
c = -4*ones(N^2,1)*M*N^2;
d = 2*N*M*N^2;

QP = qubo(QN,c,d);

end
