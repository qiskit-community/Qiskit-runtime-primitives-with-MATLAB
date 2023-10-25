% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


classdef Options 
   properties(SetAccess = private)
       circuits,
       circuit_indices,
       parameters,
       parameter_values,
       observables,
       resilience_settings,
       transpilation_settings,
       run_options,
   end
   methods(Static)
       
 %%
    function options = SetOptions (varargin)
        circuit     = varargin{1,1};
        id          = varargin{1, 2};
        Observables = varargin{1,3};

        % qasm = generateQASM(circuit);
        qasm = QASM_Gen (circuit);
        options.circuits = {qasm};
        options.circuit_indices = {0};
        options.parameter_values = {[]};
        
        if id
            observables = {};
            observables.x__type__= "settings";
            observables.x__module__= "qiskit.quantum_info.operators.symplectic.sparse_pauli_op";
            observables.x__class__= "SparsePauliOp";
            
            observables.x__value__.data.x__type__ = "settings";
            observables.x__value__.data.x__module__ = "qiskit.quantum_info.operators.symplectic.pauli_list";
            observables.x__value__.data.x__class__ = "PauliList";
            observables.x__value__.data.x__value__.data = Observables.Pauli_Term;
            
            observables.x__value__.coeffs.x__type__ = "ndarray";
            observables.x__value__.coeffs.x__value__ = Observables.Coeffs;
            options.observables = {[observables]};
            options.observable_indices = {0};
      
        end
        
        options.resilience_settings.level = 1;
        options.transpilation_settings.optimization_settings.level = 3;
        options.run_options.shots = 100;
        options.transpilation_settings.skip_transpilation = false;
        options.transpilation_settings.approximation_degree = NaN;
        options.transpilation_settings.initial_layout = NaN;
        options.transpilation_settings.layout_method = NaN;
        options.transpilation_settings.routing_method = NaN;
        options.transpilation_settings.coupling_map = NaN;
        options.transpilation_settings.basis_gates = NaN;
        options.resilience_settings.noise_amplifier = "TwoQubitAmplifier";
        options.resilience_settings.noise_factors = [1,3,5];
        options.resilience_settings.extrapolator = "LinearExtrapolator";
        options.run_options.init_qubits = true;
        options.run_options.noise_model = NaN;
        options.run_options.seed_simulator = NaN;
        
        txt = jsonencode(options);
        txt = strrep(txt,'"x__','"__');
        options = txt;
    
    end
   end
end