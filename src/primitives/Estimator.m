% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


classdef Estimator
   properties
       session,
       circuits,
       Hamiltonian,
       options,
   end
   methods

       function obj = Estimator(session,options)
            session.service.program_id = "estimator";
            obj.session = session;
            obj.options = options;

       end

       function jobinfo = run(varargin)
           %%% Remove classical bit
            pat = "bit[" + digitsPattern + ("] c;");
            circuit     = erase(varargin{1,2},pat);
            %%% Remove measurements
            pat2 = ("c["|"c =" );
            circuit     = extractBefore(circuit, pat2);
            
            hubinfo    = varargin{1, 1}.session.service;
            hamiltonian = varargin{1,3};
            if nargin==4
                parameters = varargin{1,4};
                params = varargin{1, 1}.options.SetOptions(circuit,1, hamiltonian,parameters);
            else
                params = varargin{1, 1}.options.SetOptions(circuit,1, hamiltonian);
            end
    
            
            %% Run the circuit on IBM Quantum Estimator primitive
            %%%% Submit the job
            jobinfo = Job.submitJob(params, hubinfo);

       end
      
      function result = Results(varargin)
        job_id      = varargin{1,2};
        service  = varargin{1, 1}.session.service;

        result = Job.retrieveResults(job_id, service);

      end

   end
end
