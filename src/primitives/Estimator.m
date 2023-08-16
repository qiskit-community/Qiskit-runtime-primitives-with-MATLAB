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
       parameters,
       Hamiltonian,
       options,
   end
   methods (Static)

       function obj = Estimator(session,options)
            options.service.program_id = "estimator";
            obj.session = session;
            obj.options = options;

       end

       function jobinfo = run(varargin)
            circuit     = varargin{1,1};
            hubinfo     = varargin{1,2};
            hamiltonian = varargin{1,3};

            params = Options.SetOptions(circuit,1, hamiltonian);
            %% Run the circuit on IBMQ Estimator program
            %%%% Submit the job
            jobinfo = Job.submitJob(params, hubinfo);

       end
      
      function result = Results(varargin)
        job_id      = varargin{1,1};
        Access_API  = varargin{1,2};

        result = Job.retrieveResults(job_id, Access_API);

      end

   end
end