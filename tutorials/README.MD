## Tutorials
In this tutorial the VQE algorithm is used to find the ground state energy of H2 molcule and solve the MaxCut Optmization problem using MATLAB/Qiskit runtime primitives

## VQE using Estimator primitive and Sessions to find the ground state energy of H2 molecule

### Background

Variational quantum algorithms are promising candidate hybrid-algorithms for observing the utility of quantum computation on noisy near-term devices. Variational algorithms are characterized by the use of a classical optimization algorithm to iteratively update a parameterized trial solution, or `ansatz`. Chief among these methods is the Variational Quantum Eigensolver (VQE) that aims to solve for the ground state of a given Hamiltonian represented as a linear combination of Pauli terms, with an ansatz circuit where the number of parameters to optimize over is polynomial in the number of qubits. Given that size of the full solution vector is exponential in the number of qubits, successful minimization using VQE requires, in general, additional problem specific information to define the structure of the ansatz circuit.
Executing a VQE algorithm requires the following 3 components:

1. Hamiltonian and ansatz (problem specification)
2. Qiskit Runtime estimator
3. Classical optimizer

Although the Hamiltonian and ansatz require domain specific knowledge to construct, these details are immaterial to the Runtime, and we can execute a wide class of VQE problems in the same manner.

### Problem specification

Here we define the problem instance for the VQE algorithm. Although the problem in question can come from a variety of domains, the form for execution via Runtime is the same. The Hamiltonians can be defined as a list of string in Pauli form with the corresponding coefficient.The ansatz circuits can be constructed using MATLAB Quantum Computing Toolbox.

```
hydrogen_Pauli = ["II","IZ","ZI","ZZ","XX"];
coeffs = string([-1.0523732, 0.39793742, -0.3979374 , -0.0112801, 0.18093119]);

```

and our choice of ansatz is the TwoLocal that, linearly entangles qubits, making it ideal for quantum hardware with limited connectivity.

```
circuit.reps=4;
circuit.entanglement = "linear";
circuit.number_qubits = strlength(hydrogen_Pauli(1));
circuit.num_parameters =

% Construct the variational circuit 
ansatz = Twolocal(arg.circuit, parameters);
```

### VQE cost function and minimization
Like many classical optimization problems, the solution to a VQE problem can be formulated as minimization of a scalar cost function. By definition, VQE looks to find the ground state solution to a Hamiltonian by optimizing the ansatz circuit parameters to minimize the expectation value (energy) of the Hamiltonian. With the Runtime Estimator directly taking a Hamiltonian and parameterized ansatz, and returning the necessary energy, The cost function for a VQE instance is quite simple:

```
%% Define the cost function to calculate the expectation value of the derived Hamiltonian
function [energy] = cost_function(parameters,arg)    

    % Construct the variational circuit 
    ansatz = Twolocal(arg.circuit, parameters);

    estimator = arg.estimator;
    job       = estimator.run(ansatz,arg.estimator.options.service,arg.hamiltonian);

    %%%% Retrieve the results back
    results = Job.retrieveResults(job.id,arg.estimator.options.service.Access_API);
    energy  = results.values;
end

```

Note that, in addition to the array of optimization parameters, we use additional arguments to pass the terms needed in the cost function.

We are now free to use a classical optimizer of our choice to minimize our cost function. Here we use the Surrogate optimizer from [MATLAB global optimization toolbox](https://www.mathworks.com/products/global-optimization.html). Note that, when running on real quantum hardware, the choice of optimizer is important as not all optimizers handle noisy cost function landscapes equally well.

To begin the routine, we start by specifying a random initial set of parameters,

```
x0 = -1*ones(circuit.num_parameters,1);
```

Then we need to set the parameters for the surrogate optimizer as follows:
```
max_iter = 40;

lower_bound = repmat(-2*pi,circuit.num_parameters,1);
upper_bound = repmat( 2*pi,circuit.num_parameters,1);

options = optimoptions("surrogateopt",...
    "MaxFunctionEvaluations",max_iter, ...
    "PlotFcn","optimplotfval",...
    "InitialPoints",x0);
```

Now it is time to run the optimizer to find the ground state energy of H2 molecule:

```
[angles,minEnergy] = surrogateopt(cost_func,lower_bound,upper_bound,options);

```


After the max_iter reached ot the process stopped by the optimizer setting parameters, the progress towards convergence for H2 molecule as monitored by the cost history at each iteration:

<p align="center">
  <img width="600" height="400" src="https://github.ibm.com/Partnership-Integration/MATLAB-Qiskit-Runtime-Primitives/blob/main/tutorials/Ground%20State%20Energy%20of%20H2%20Molecule%20Using%20Estimator/Results/opt_h2.jpg">
</p>

The same process can be done for Maxcut problem with sampler or estimator to find the solution to the problem.