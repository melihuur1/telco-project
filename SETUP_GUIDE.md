Execution of the docker-compose up -d command, showing the Oracle XE container successfully transitioning to the 'Started' state.

![alt text](./images/image.png)

Docker logs verifying the Automated Database Seeding process. The table creation script executes automatically upon container initialization.

![alt text](./images/image1.png)

DBeaver connection settings configured for the local Oracle XE instance (Host: localhost, Port: 1521, Service: XEPDB1)

![alt text](./images/image2.png)

Database Navigator in DBeaver confirming that all required tables were successfully created via the automated seeding process.

![alt text](./images/image3.png)
