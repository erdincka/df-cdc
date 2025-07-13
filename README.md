# Data Fabric Demo with CDC

End to end data processing for change data capture, using HPE Data Fabric.

Change Data Capture is a mechanism to grab the changes happening on a database and send it to another system. This demo shows how HPE Data Fabric can facilitate end to end data processing from MySQL database changes. We set up an RDBMS instance, create a `users` table and use NiFi flows to capture the changes on that table. Current version processes only **INSERT** statements, but can be easily modified to take action against other SQL operations.

To use the demo, you can use provided [docker-compose.yaml](./docker-compose.yaml) file to start a MapR Sandbox instance automatically configured with all required core and EEP components (ie, NiFi, Hive, Zeppelin).

You can then open NiFi endpoint to enable/disable the flow, and use Zeppelin to see changes reflected in near realtime.

## TODO 

[PLACE DEMO PIPELINE IMAGE HERE]


## Requirements

- Docker


## Run

- (Optional) Edit [Compose file](./docker-compose.yaml) to set "ARGS".

- Run `docker compose -f docker-compose.yaml up -d`.

- Open [App UI](http://localhost:3000).

- Follow instructions.


## Demo Flow

- Open [NiFi](https://localhost:12443/nifi) to configure passwords and enable controllers
    - login with provided credentials (defaults: `admin/Admin123.Admin123.`)

- Open Zeppelin Notebook

- Insert records to the pre-configured MySQL table `users`

- Check NiFi flow to see processed messages (it may take a while to process all records)

- Query the resulting table from Zeppelin - re-run queries as new records are being processed



## Optional

- Create a connection to Hive table using Presto (within HPE PCAI platform)

- Connect HPE PCAI Superset to the newly created data source (hive s3parquet endpoint)

- Monitor Superset dashboard for changes in near realtime

**Follow instructions in [Manual Installation](./MANUAL-INSTALL.md) for further details**


## Manual Installation

- You can follow the steps below to manually install the demo on your own Data Fabric instance

[Open Manual Installation Instructions](./MANUAL-INSTALL.md)


# TODO

[] Create helm chart to deploy on HPE PCAI

[] Enable processing operations other than INSERT

[] Enable data transformation in NiFi flow (change/hide fields?)

[] Better user experience (integrate Sparkflows demo flow)
