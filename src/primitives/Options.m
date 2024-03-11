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
   properties
       % circuits,
       % circuit_indices,
       % parameters,
       % parameter_values,
       % observables,
       resilience_settings,
       transpilation_settings,
       run_options,

   end
   methods(Access=public)
       
       function obj = Options (varargin)
            obj.resilience_settings.level = 1;
    
            obj.run_options.shots = 20000;
            obj.transpilation_settings.optimization_settings.level = 3;
            obj.transpilation_settings.skip_transpilation = false;
            obj.transpilation_settings.approximation_degree = NaN;
            obj.transpilation_settings.initial_layout = NaN;
            obj.transpilation_settings.layout_method = NaN;
            obj.transpilation_settings.routing_method = NaN;
            obj.transpilation_settings.coupling_map = NaN;
            obj.transpilation_settings.basis_gates = NaN;
            obj.resilience_settings.noise_amplifier = "noise_amplifier";
            obj.resilience_settings.noise_factors = [1,3,5];
            obj.resilience_settings.extrapolator = "LinearExtrapolator";
            obj.run_options.init_qubits = true;
            obj.run_options.noise_model = NaN;
            obj.run_options.seed_simulator = NaN;


   end
 %%
    function options = SetOptions (varargin)
        options_params = varargin{1,1};
        circuit     = varargin{1,2};
        id          = varargin{1, 3};
        Observables = varargin{1,4};
        

        if isobject(circuit)
            for i = 1: length(circuit)
                qasm(i) = generateQASM(circuit(i));
            end
            options.circuits = cellstr(qasm);
            if length(circuit)==1
                options.circuit_indices = {0};
                options.parameter_values = {[]};
            else
                options.circuit_indices = 0:length(circuit)-1;
                options.parameter_values = cell(1,length(circuit));
            end

        else
            options.circuits = cellstr(circuit);
        end
        
        
        if id
            observables = containers.Map();
            observables('__type__') = "settings";
            observables('__module__') = "qiskit.quantum_info.operators.symplectic.sparse_pauli_op";
            observables('__class__') = "SparsePauliOp";
            
            observables("__value__") = containers.Map();
            observable_value = observables("__value__");
            
            observable_value("data") = containers.Map();
            observable_value_data = observable_value("data");
            
            observable_value_data("__type__") = "settings";
            observable_value_data("__module__") = "qiskit.quantum_info.operators.symplectic.pauli_list";
            observable_value_data("__class__") = "PauliList";
            
            observable_value_data("__value__") = containers.Map();
            observable_value_data_value = observable_value_data("__value__");
            observable_value_data_value("data") = Observables.Pauli_Term;
            
            
            observable_value("coeffs") = containers.Map();
            observable_value_coeffs = observable_value("coeffs");
            observable_value_coeffs("__type__") = "ndarray";
            observable_value_coeffs("__value__") = Observables.Coeffs;
            options.observables = {[observables]};
            options.observable_indices = {0};
      
        end
        options.resilience_settings.level = options_params.resilience_settings.level ;
        % options.transpilation_settings.optimization_settings.level = options_params.transpilation_settings.optimization_settings.level;
        options.run_options.shots = options_params.run_options.shots;
        % options.transpilation_settings.skip_transpilation = options_params.transpilation_settings.skip_transpilation;
        % options.transpilation_settings.approximation_degree = options_params.transpilation_settings.approximation_degree ;
        % options.transpilation_settings.initial_layout = options_params.transpilation_settings.initial_layout;
        % options.transpilation_settings.layout_method = options_params.transpilation_settings.layout_method;
        % options.transpilation_settings.routing_method = options_params.transpilation_settings.routing_method;
        % options.transpilation_settings.coupling_map = options_params.transpilation_settings.coupling_map;
        % options.transpilation_settings.basis_gates = options_params.transpilation_settings.basis_gates;
        options.resilience_settings.noise_amplifier = options_params.resilience_settings.noise_amplifier;
        options.resilience_settings.noise_factors = options_params.resilience_settings.noise_factors;
        options.resilience_settings.extrapolator = options_params.resilience_settings.extrapolator;
        % options.run_options.init_qubits = options_params.run_options.init_qubits;
        options.run_options.noise_model = options_params.run_options.noise_model ;
        options.run_options.seed_simulator = options_params.run_options.seed_simulator;
        

    end
   end
end