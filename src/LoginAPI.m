% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.

function response = get_Api(apiToken)
%% Web Access using Data Import and Export API
var = constants;
uri = var.urllog;
body = struct(...
    'apiToken', apiToken...
);
options = weboptions(...
    'ContentType', 'json',...
    'MediaType', 'application/json'...
);
response = webwrite(uri, body, options);

end