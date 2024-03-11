% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


classdef Session 
   properties
       service,
       backend,
   end
   methods (Access=public)
       function obj = Session(service,backend)
            obj.backend = backend;
            
            if isempty(service.session_mode) && service.Start_session==1
                service.session_mode = "batch";
                obj.service = service;
            else
                obj.service = service;
            end

            % symbols = ['a':'z' 'A':'Z' '0':'9'];
            % MAX_ST_LENGTH = 16;
            % stLength = randi([1,length(symbols)],MAX_ST_LENGTH,1);
            
            % if service.Start_session ==1
            %     % obj.service.session_id = symbols(stLength);
            % end
            if ~isempty(backend)
                obj.service.backend = backend;
            end
       end
       % function obj = set.service(obj,val)
       %      obj.service = val;
       % end
   end
end