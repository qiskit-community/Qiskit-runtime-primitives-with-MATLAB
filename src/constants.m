% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


classdef constants 
   properties(SetAccess = private)
       urljob_iqp = 'https://runtime-us-east.quantum-computing.ibm.com/jobs/',
       urljob_crn = 'https://us-east.quantum-computing.cloud.ibm.com/jobs/',

       urllog_iqp = 'https://auth.quantum-computing.ibm.com/api/users/loginWithToken',
       urllog_crn = 'https://iam.cloud.ibm.com/identity/token',
       matlab_version = 'qiskit-version-2/0.39.2/MATLAB\',

       timeout = 100; %% Timeout session set to be 100 Sec
   end
   methods(Static)

   end
end