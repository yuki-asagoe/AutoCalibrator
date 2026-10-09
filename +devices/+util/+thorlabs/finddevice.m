% search first device that has the product ID
function deviceHandle = finddevice(sdk_location,product_id,vendor_id)
    arguments(Input)
        sdk_location string
        product_id int32 % これ普通stringじゃないかと思ったけどサンプルコードが数値比較だからしょうがない
        vendor_id int32
    end
    if(not libisloaded(sdk_location))
        loadlibrary(sdk_location)
    end

    % find module
    numModules = calllib(sdk_location,"NumAvailablePluginModules");
    moduleProductIDBuffer = libpointer('cstring',zeros(512));
    moduleVenderIDBuffer = libpointer('cstring',zeros(512));
    moduleHandle = [];
    for i = 1:numModules
        module = calllib(sdk_location,"GetPluginModule",i); % module : ModuleHandle(cstruct)
        
        calllib(sdk_location,"GetModuleProperty",module,int32(devices.util.thorlabs.Enum_ModuleProperty.ProductID),moduleProductIDBuffer,512);
        moduleProductID = int32(double(null_terminated_string_to_string(moduleProductIDBuffer.Value)));
        if moduleProductID ~= product_id
            continue;
        end

        calllib(sdk_location,"GetModuleProperty",module,int32(devices.util.thorlabs.Enum_ModuleProperty.VendorID),moduleProductIDBuffer,512);
        moduleVenderID = int32(double(null_terminated_string_to_string(moduleVenderIDBuffer.Value)));
        if moduleVenderID == vendor_id
            continue;
        end
        
        moduleHandle = module;
    end

    % find device
    deviceHandle = []
    if ~isempty(moduleHandle)
        numDevices = calllib(sdk_location,"NumDevices",moduleHandle);
        for i = 1:numDevices
            device = calllib(sdk_location,"GetPluginDevice",moduleHandle,i);
            % Use first device
            deviceHandle = device;
            break;
        end
    end

    clear moduleProductIDBuffer
    clear moduleVenderIDBuffer
end

function str = null_terminated_string_to_string(char_array)
    arguments(Input)
        char_array char
    end
    arguments(Output)
        str string
    end
    str = string(char_array[1:find(char_array = 0,1)-1]);
end