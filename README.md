<h1 align="center">
  <br>
  <img src="assets/assets.gif" width="200" height="200" style="border-radius:50%">
  <br>
  <br>
  Fluent Bit Integration for Wazuh v4.9.0
</h1>

This repository contains configuration files and scripts for integrating Wazuh with OpenSearch using Fluent Bit. This setup allows you to collect Wazuh alerts and archives, process them, and send them to an OpenSearch instance.

## Contents

- `fluent-bit.conf`: Main Fluent Bit configuration file
- `parsers.conf`: Parsers configuration for Wazuh logs
- `wazuh_template.lua`: Lua script for appending Wazuh template to records

## Prerequisites

- Fluent Bit installed on your system
- Access to a Wazuh instance
- Access to an OpenSearch instance

## Configuration Files

### fluent-bit.conf

This is the main configuration file for Fluent Bit. It sets up the service, inputs, filters, and output.

Key components:

- Two inputs for Wazuh alerts and archives
- A record modifier filter to add hostname
- A Lua filter to append the Wazuh template
- An OpenSearch output

### parsers.conf

This file contains parser definitions for Wazuh alerts and archives.

### wazuh_template.lua

This Lua script appends the Wazuh template to each record. You need to replace the placeholder in this file with your actual Wazuh template.

## Setup

1. Place the configuration files in the appropriate Fluent Bit configuration directory (typically `/etc/fluent-bit/`).

2. Edit the `wazuh_template.lua` file to include your actual Wazuh template.

3. Set the required environment variables:

   ```bash
   export OPENSEARCH_USERNAME=your_username
   export OPENSEARCH_PASSWORD=your_password
   export INDEX_SUFFIX=$(date +%Y.%m.%d)
   export HOSTNAME=$(hostname)
   ```

4. Start Fluent Bit:

   ```bash
   fluent-bit -c /etc/fluent-bit/fluent-bit.conf
   ```

## Configuration Details

- The configuration uses the `tail` input plugin to continuously monitor Wazuh log files.
- Logs are parsed using custom parsers defined in `parsers.conf`.
- A Lua script is used to append the Wazuh template to each record.
- The processed logs are sent to OpenSearch using the OpenSearch output plugin.

```
Save this Lua script as /etc/fluent-bit/wazuh_template.lua. Make sure to replace the placeholder comment with the actual contents of your Wazuh template.
```

## Customization

- Modify the `Host` and `Port` in the OUTPUT section of `fluent-bit.conf` to match your OpenSearch instance.
- Adjust the `Index` and `Logstash_Prefix` settings as needed.
- If using TLS, ensure the `tls.verify` option is set correctly and provide necessary certificates.

## Troubleshooting

- Check Fluent Bit logs for any error messages.
- Ensure Fluent Bit has read permissions for Wazuh log files and write permissions for its storage path.
- Verify that the environment variables are set correctly.

## Contributing

Contributions to improve the configuration or documentation are welcome. Please submit a pull request or open an issue to discuss proposed changes.
