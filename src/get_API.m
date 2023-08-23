% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.

function response = get_API(channel, apiToken)
%% Web Access using Data Import and Export API
var = constants;

if channel =="ibm_cloud"
    uri = var.urllog_crn;
    body = append('grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=',apiToken);
    options = weboptions('MediaType', 'application/x-www-form-urlencoded');
else
    uri = var.urllog_iqp;
    body = struct(...
        'apiToken', apiToken...
    );
    options = weboptions(...
        'ContentType', 'json',...
        'MediaType', 'application/json'...
    );
end

response = webwrite(uri, body, options);


end