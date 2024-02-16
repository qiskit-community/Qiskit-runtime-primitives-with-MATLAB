% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.

classdef QiskitRuntimeService 
   properties
    hub = "ibm-q";
    group = "open";
    project = "main";
    program_id = "estimator";
    Access_API;
    backend = "ibmq_qasm_simulator";
    Start_session = true;
    session_id = [];
    channel = [];
    tokenType = '';
    instance;
    session_mode;
   end
   methods
       function obj = QiskitRuntimeService(channel, apiToken, instance)
            
            Runtime_apiToken = get_API(channel, apiToken);

            if channel == "ibm_cloud"
                obj.program_id = "estimator";
                obj.Access_API = Runtime_apiToken.access_token;
                obj.tokenType = Runtime_apiToken.token_type;
                obj.backend = "ibmq_qasm_simulator";
                obj.Start_session = true;
                obj.session_id = [];
                obj.channel = "ibm_cloud";
                obj.instance = instance;
                obj.session_mode = [];
            else
                obj.hub = "ibm-q";
                obj.group = "open";
                obj.project = "main";
                obj.program_id = "estimator";
                obj.Access_API = Runtime_apiToken.id;
                obj.backend = "ibmq_qasm_simulator";
                obj.channel = "ibm_quantum";
                obj.Start_session = true;
                obj.session_id = [];
                obj.session_mode = [];


            end
 %%
       end
  end
end