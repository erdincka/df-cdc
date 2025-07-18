# Data Fabric Demo with CDC

End to end data processing for change data capture, using HPE Data Fabric.

Change Data Capture is a mechanism to grab the changes happening on a database and send it to another system. This demo shows how HPE Data Fabric can facilitate end to end data processing from MySQL database changes. We set up an RDBMS instance, create a `users` table and use NiFi flows to capture the changes on that table. Current version processes only **INSERT** statements, but can be easily modified to take action against other SQL operations.

To use the demo, you can use provided [docker-compose.yaml](./docker-compose.yaml) file to start a MapR Sandbox instance automatically configured with all required core and EEP components (ie, NiFi, Hive, Zeppelin).

You can then open NiFi endpoint to enable/disable the flow, and use Zeppelin to see changes reflected in real time.

## TODO 

![Demo Flow](./images/CDC%20Demo.png)


## Requirements

- Basic knowledge of Data Fabric, NiFi, Hive & Zeppelin - not necesarily needed though

- Docker, with min 8 cores & 30GB memory

- Git CLI (Download from [its website](https://git-scm.com/downloads) or `brew install git` on MacOS)


## Run

- Clone the repository `git clone https://github.com/erdincka/df-cdc.git`

- Edit [Compose file](./docker-compose.yaml)
    - Replace `NIFI_WEB_PROXY_HOST` with the hostname of your docker - Leave empty if running locally
    - (Optional) Set other "ARGS".

- Run `docker compose -f docker-compose.yaml up -d`.


## Demo Flow

- Open [NiFi](https://localhost:12443/nifi) to configure passwords and enable controllers
    - Login with `admin/Admin123.Admin123.` (or use your credentials if you've changed in the `docker-compose.yaml` file).

    - Drag "Process Group" from top of the page onto Canvas, browse to upload the [flow file: CDC MySQL to Hive Flow.json](./CDC%20MySQL%20to%20Hive%20Flow.json.json).

        - Select the Process Group, and select [Settings](./images/NiFi_ControllerSettings.png) for "NiFi Flow".
    
            - In the "Controller Services" tab,
    
                - Enter mapr password `mapr` for [Hive3_EEP_ConnectionPool](./images/NiFi_HiveSettings.png) by clicking "gear" icon.
    
                - Enable [all services](./images/NiFi_ControllerServices.png) by clicking the lightning icon and then "Enable".
    
            - Enter into "Process Group" by double-click.
    
        - Double-click on [CaptureChangeMySQL processor](./images/NiFi_CaptureChangeMySQL.png), enter [Password](./images/NiFi_MySQLPassword.png).
    
        - S3 credentials should be available within the provided credentials file `/home/mapr/.aws/credentials`.
    
    - Click on empty space and select "Play" button to start all processors.


- Open [Zeppelin](https://localhost:9995/) (replace `localhost` if not running locally)

    - Login with `mapr/mapr`

    - Import [the note](./HiveDashboard_2M333SR9V.zpln)

    <!-- - Configure Interpreter - Hive -->

    - Run paragraphs

- Insert records to the pre-configured MySQL table `users`

    - Run `uv run users.py`

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
