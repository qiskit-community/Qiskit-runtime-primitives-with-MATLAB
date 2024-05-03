function deserialized_data = decode_and_deserialize(data, decompress)
    % Decode and deserialize input data using Python

    % Import required Python modules
    py.importlib.import_module('zlib');
    py.importlib.import_module('base64');
    py.importlib.import_module('tempfile');
    py.importlib.import_module('numpy');

    % Decode Base64 data using Python
    decoded = py.base64.standard_b64decode(data);

    % Decompress data using zlib in Python
    if decompress
        decompressed = py.zlib.decompress(decoded);
    else
        decompressed = decoded;
    end

    % Write decompressed data to a temporary file
    temp_file = char(py.tempfile.mktemp('.mat'));
    
    fh = fopen(temp_file, 'wb');
    fwrite(fh, uint8(decompressed));
    fclose(fh);

    % Load data using np.load in Python
    deserialized_data = py.numpy.load(temp_file);

    % Delete temporary file
    py.os.remove(temp_file);
end
