# Triglav
gNMI/JTI based telemetry

Triglav allows you to collect telemetry data using telegraf and gnmi from Juniper ACX, PTX and MX devices.

Due to differences between platforms and sensor availability for different software versions, the data collected may vary. I'm using it on Junos(EVO) 24.2.

Configuration allows sending metrics to the VictoriaMetrics database.

Communication with Juniper devices is done using gNMI (SSL).

```
set system services extension-service request-response grpc ssl port 9339
set system services extension-service request-response grpc ssl local-certificate mpls
```

The following parameters must be set in the `.env` file:

```
GNMI_USERNAME=some_junos_username
GNMI_PASSWORD=some_junos_password
DB_NAME=triglav
DB_URL=http://vistoriametrics_server:8428
ACX_ADDRESSES=\"acx-1:5555\",\"acx-2:5555\"
MX_ADDRESSES=\"mx-1:5555\",\"mx-2:5555\"
PTX_ADDRESSES=\"ptx-1:5555\",\"ptx-2:5555\"
```

Due to differences in configuration, you must provide the addresses of ACX, MX and PTX routers combined with the port number, separated by a comma. Note the `\` before `"` in the device list. This is required due to the configuration of the telegraf in the TOML format

Individual Telegraf instances for ACX, MX and PTX platforms are run in containers:
```
# docker compose up -d
```