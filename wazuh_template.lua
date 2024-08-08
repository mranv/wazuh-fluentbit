function append_wazuh_template(tag, timestamp, record)
    local template = {
        order = 0,
        index_patterns = {"wazuh-alerts-4.x-*", "wazuh-archives-4.x-*"},
        settings = {
            ["index.refresh_interval"] = "5s",
            ["index.number_of_shards"] = "3",
            ["index.number_of_replicas"] = "0",
            ["index.auto_expand_replicas"] = "0-1",
            ["index.mapping.total_fields.limit"] = 10000
        },
        mappings = {
            dynamic_templates = {
                {
                    string_as_keyword = {
                        mapping = {
                            type = "keyword"
                        },
                        match_mapping_type = "string"
                    }
                }
            },
            date_detection = false,
            properties = {
                ["@timestamp"] = { type = "date" },
                timestamp = {
                    type = "date",
                    format = "date_optional_time||epoch_millis"
                },
                ["@version"] = { type = "text" },
                agent = {
                    properties = {
                        ip = { type = "keyword" },
                        id = { type = "keyword" },
                        name = { type = "keyword" }
                    }
                },
                manager = {
                    properties = {
                        name = { type = "keyword" }
                    }
                },
                cluster = {
                    properties = {
                        name = { type = "keyword" },
                        node = { type = "keyword" }
                    }
                },
                full_log = { type = "text" },
                previous_log = { type = "text" },
                -- Add all other properties from the template here
                -- ...
            }
        },
        version = 1
    }

    -- Add the 'query.default_field' setting
    template.settings["index.query.default_field"] = {
        "GeoLocation.city_name",
        "GeoLocation.continent_code",
        "GeoLocation.country_code2",
        "GeoLocation.country_code3",
        "GeoLocation.country_name",
        "GeoLocation.ip",
        "GeoLocation.postal_code",
        "GeoLocation.real_region_name",
        "GeoLocation.region_name",
        "GeoLocation.timezone",
        "agent.id",
        "agent.ip",
        "agent.name",
        "cluster.name",
        "cluster.node",
        "command",
        -- Add all other fields from the 'index.query.default_field' list
        -- ...
    }

    -- Determine the index name based on the tag
    local index_name
    if tag == "wazuh-alerts" then
        index_name = "wazuh-alerts-4.x-" .. os.date("%Y.%m.%d")
    elseif tag == "wazuh-archives" then
        index_name = "wazuh-archives-4.x-" .. os.date("%Y.%m.%d")
    else
        index_name = "wazuh-unknown-4.x-" .. os.date("%Y.%m.%d")
    end

    -- Add the template to the record
    record["_index_template"] = {
        [index_name] = template
    }

    return 1, timestamp, record
end
