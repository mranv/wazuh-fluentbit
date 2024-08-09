local cjson = require("cjson")

-- Function to read JSON file
local function read_json_file(file_path)
    local file, err = io.open(file_path, "r")
    if not file then
        return nil, "Failed to open file: " .. file_path .. ". Error: " .. (err or "unknown")
    end
    local content = file:read("*all")
    file:close()
    
    local success, result = pcall(cjson.decode, content)
    if not success then
        return nil, "Failed to parse JSON: " .. result
    end
    
    return result
end

-- Global variable to store the template
local template

-- Function to log messages
local function log(level, message)
    print(string.format("[%s] [wazuh_template] %s", level, message))
end

function append_wazuh_template(tag, timestamp, record)
    -- Load the template if it hasn't been loaded yet
    if not template then
        local json_file_path = "/etc/fluent-bit/wazuh_template.json"
        local json_data, err = read_json_file(json_file_path)
        if err then
            log("ERROR", "Error reading JSON file: " .. err)
            return 0, timestamp, record
        end
        
        if not json_data["wazuh-alerts-4.x-2024.08.08"] then
            log("ERROR", "Expected key 'wazuh-alerts-4.x-2024.08.08' not found in JSON")
            return 0, timestamp, record
        end
        
        template = json_data["wazuh-alerts-4.x-2024.08.08"]
        log("INFO", "Template loaded successfully")
    end

    -- Create a deep copy of the template to avoid modifying the original
    local template_copy = cjson.decode(cjson.encode(template))

    -- Add or update the index.query.default_field setting
    if not template_copy.settings then
        template_copy.settings = {}
    end
    if not template_copy.settings.index then
        template_copy.settings.index = {}
    end
    template_copy.settings.index.query = {
        default_field = {
            "rule.description",
            "rule.id",
            "rule.level",
            "rule.category"
        }
    }

    -- Wrap the template in the expected structure
    local full_template = {
        index_patterns = {"wazuh-alerts-4.x-*"},
        template = template_copy
    }
    
    -- Add the template to the record
    record["_index_template"] = full_template
    
    log("DEBUG", "Template appended to record")
    
    return 2, timestamp, record
end

-- Test the function (comment out in production)
local test_record = {}
local _, _, modified_record = append_wazuh_template("test_tag", os.time(), test_record)
log("INFO", "Test complete. Record now contains _index_template: " .. tostring(modified_record["_index_template"] ~= nil))