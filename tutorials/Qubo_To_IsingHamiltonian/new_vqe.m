% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.



 clc;
clear all;
close all;

%% Setup IBM Quantum cloud credentials

apiToken='3c5b304ce66fac801ad3173a65e5b99717bf2f4002989578e01185ba3f56d02a0589e8c3d208f99fe1c7040df83ddedf9f74e4cb178e51022daa6e80294acd28'




%% Setup IBM Quantum Platform credentials
channel="ibm_quantum"
service=QiskitRuntimeService(channel,apiToken,[]);

%%Define backend and access

service.Start_session=true;
backend="ibmq_qasm_simulator";
service.hub="ibm-q-wits"
service.group="internal"
service.project="physics"
%%
service.program_id = "estimator";
service.Start_session = true;


%% Enable the session and Estimator
session = Session(service, backend);  
estimator = Estimator(session=session);

%%
% Setup for Two-Qubit Quantum State Tomography Using VQE

%%%% this function generates the complete set of projections that are
%%%% needed for state tomography where the projectors are flattened
%%%% we assume this is done for two photons


twophoton = "T";
dim=2;
numParticles = 2;

numMeasurements = 4*nchoosek(dim, 2)+dim; %%% number of measurements needed

T = ProduceProjectionsmat(dim, twophoton);
T=double(T);
TestState = reshape(eye(dim), [dim^numParticles, 1]);

Testrho = kron(TestState, TestState');

rhoflat = reshape(Testrho, [(dim^numParticles)^2, 1]); % flattened density matrix
%% compute 

Measurements = (T*rhoflat);
M=Measurements;
[MeasurementsFor_Disp, DensityMat_For_Disp] = MatricesForplots(Measurements, rhoflat, dim,numMeasurements);


%visualises the measurements
MeasurementsFor_Disp = reshape(Measurements, [numMeasurements, numMeasurements])
imagesc(MeasurementsFor_Disp)

% densitymatrix_display
%DensityMat_For_Disp = reshape(rhoflat, [dim^2, dim^2])
% imagesc(DensityMat_For_Disp)

%% 


%% 1. Mapping the problem to qubits/Quantum Hamiltonian

%%%% Here we use the QuadraticProgram class to convert into the Pauli terms
Linear    = -(T'* M + (M' * T)');
Quadratic = T'* T;
constant  = M'* M;


Qubo = QuadraticProgram(Linear,Quadratic,constant);
[Pauli_terms,Pauli_Coeff, Offset_value] = Qubo.To_ising(Linear,Quadratic,constant);
hamiltonian.Pauli_Term = Pauli_terms;
hamiltonian.Coeffs = Pauli_Coeff;

%% 2. Choosing the ansatz circuit/s
circuit.reps=2;
circuit.entanglement = "linear";
circuit.number_qubits = strlength(Pauli_terms(1));
circuit.num_parameters = (circuit.reps+1)*circuit.number_qubits;

%% Arguments for the optimizer 
arg.hamiltonian = hamiltonian;
arg.circuit     = circuit;
arg.estimator   = estimator;

%% Define the cost function
cost_func = @(theta) cost_function(theta,arg);

%% Set the parameters for MATLAB surrogateopt global optimizer 
x0 = -5*ones(circuit.num_parameters,1);
max_iter =1500;

lower_bound = repmat(-2*pi,circuit.num_parameters,1);
upper_bound = repmat( 2*pi,circuit.num_parameters,1);

options = optimoptions("surrogateopt",...
    "MaxFunctionEvaluations",max_iter, ...
    "PlotFcn","optimplotfval",...
    "InitialPoints",x0);

%% 3. Executing the quantum VQE algorithm using the qiskit Estimator primititve and MATLAB 
% optimizer to find the ground state energy of H2 molecule

rng default %% For reproducibility

[angles,minEnergy] = surrogateopt(cost_func,lower_bound,upper_bound,options);

fprintf('Ground state energy: [ %s ]\n', minEnergy);
%%


ansatz = Twolocal(circuit, angles);

plot(ansatz)
sampler = Sampler(session=session);



job = sampler.run(ansatz,sampler.options.service);
results = sampler.Results(job.id);
%%% extract the bitstring
string_data = string(fieldnames(results.quasi_dists));
bitstring_data = replace(string_data,"x","");
%%% Extract the probabilitites
probabilities = cell2mat(struct2cell(results.quasi_dists));

%%% Find the bitstring with the highest probability
bitstring_maxprobability = string_data(find(probabilities==max(probabilities)));
fprintf('The quantum solution for vqe is: [ %s ]\n', bitstring_maxprobability);

%%%% plot the results and color the graph using the received bit-string
%%%% (solution)

%%
bitstrings = fieldnames(results.quasi_dists);
counts = struct2array(results.quasi_dists);


% Create the bar plot
bar(counts)
title('Bitstring Distribution')
xlabel('Bitstrings')
ylabel('Counts')

% Label the x-axis with bit strings
set(gca, 'XTick', 1:length(bitstrings), 'XTickLabel', bitstrings)
xtickangle(45)  % Rotate labels for clarity
%%
[Ary]=strconvert(bitstring_maxprobability)
%% Define the cost function to calculate the expectation value of the derived Hamiltonian
function [energy] = cost_function(parameters,arg)    

    % Construct the variational circuit 
    ansatz = Twolocal(arg.circuit, parameters);

    estimator = arg.estimator;
    job       = estimator.run(ansatz,arg.hamiltonian);

    %%%% Retrieve the results back
    results   = estimator.Results(job.id);
    energy    = results.values;
end

%%
function [pauli_terms, coefficients] = compute_pauli_terms(T, M)
    % Compute T^T T for convenience
    TTT = T'*T;
     TM=T'*M;
    % Dimensions
    N = size(T, 2);

    % Coefficients and terms
    coefficients = [];
    pauli_terms = {};

    % Calculate the J_{ij} coefficients and generate the associated Pauli terms
    for i = 1:N
        for j = i+1:N
            J_ij = 0.25 * TTT(i,j);
            
            if J_ij ~= 0
                coefficients = [coefficients; J_ij];
                term = generate_pauli_string(i, j, N);
                pauli_terms{end+1} = term;
            end
        end
    end

    % Calculate the h_i coefficients and generate the associated Pauli terms
    for i = 1:N
        h_i = -0.5 * sum(TTT(i,:)) +TM(i);

        if h_i ~= 0
            coefficients = [coefficients; h_i];
            term = generate_pauli_string(i, 0, N);  % 0 indicates a linear term
            pauli_terms{end+1} = term;
        end
    end
    
    % Add the offset term
    offset = (0.25 * sum(sum(TTT)))+M'*M-sum(T'*M);
    coefficients = [coefficients; offset];
    pauli_terms{end+1} = generate_pauli_string(0, 0, N);  % Using a special case in generate_pauli_string to get 'IIII...'
end

function term = generate_pauli_string(i, j, N)
    term = repmat('I', 1, N);
    
    if i == 0 && j == 0  % Offset term
        return;
    elseif j == 0  % Linear term
        term(i) = 'Z';
    else  % Quadratic term
        term(i) = 'Z';
        term(j) = 'Z';
    end
end


%Tomography function
%%

function [Ary]=strconvert(bitstring_data)
sz=size(bitstring_data)
if sz(1)==1
sol=convertStringsToChars(bitstring_data)
Ary=zeros(length(sol)-1,1);
for k=1:length(Ary)
    Ary(k)=str2num(sol(k+1));
end
l=sqrt(length(sol)-1);

imagesc(Ary)
else
    for r=1:sz(1)
        Res=bitstring_data(r,:);
        sol=convertStringsToChars(Res)
        Ary=zeros(length(sol)-1,1);
        for k=1:length(Ary)
        Ary(k)=str2num(sol(k+1));
        end
        l=sqrt(length(sol)-1);
        
       
        subplot(sz(1),1,r)
        imagesc(Ary)
    end 
end 
end

function T = ProduceProjectionsmat(dim, twophoton)
Basis = eye( dim ); 

c=1;
for k = 1:dim 
State = Basis(:, k);
Projjsinglephoton{c} = kron(State, conj(transpose(State)));
c=c+1;
end

for k = 1:dim 
    j = k+1;
   while j<=dim
       for al =  [1, -1, 1i, -1i]
           State =vpa((Basis(:, k) + al*Basis(:, j)) ./ (sqrt(2)));
           Projjsinglephoton{c} =vpa(kron(State, State'));
           c = c+1;
       end
       j = j+1;
   end
end

numMeasureSinglePhoton = 4*nchoosek(dim, 2) + dim;

T = [];

if twophoton == "T"
 
    for j = 1 : numMeasureSinglePhoton

        ProjPhoton1 = Projjsinglephoton{j};

        for k = 1 : numMeasureSinglePhoton
            ProjPhoton2 = Projjsinglephoton{k};
            Proj12 = vpa(kron(ProjPhoton1, ProjPhoton2));

            T = [T, reshape(Proj12, [dim^4, 1])];
        end
    end
else
        for j = 1 : numMeasureSinglePhoton
           T= [T,reshape(Projjsinglephoton{j}, [dim^2, 1])];
        end
end
T = T';
end

function [MeasurementsFor_Disp, DensityMat_For_Disp] = MatricesForplots(Measurements, rhoflat, dim,numMeasurements)

%visualises the measurements
MeasurementsFor_Disp = reshape(Measurements, [numMeasurements, numMeasurements]);
%imagesc(MeasurementsFor_Disp)

% densitymatrix_display
DensityMat_For_Disp = reshape(rhoflat, [dim^2, dim^2]);
imagesc(DensityMat_For_Disp)
end










