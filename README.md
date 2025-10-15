# BOOM Deployment and Setup Guide at University of Minnesota
BOOM runs on High-Performance Computing (HPC) nodes provided by the Minnesota Supercomputing Institute (MSI) at UMN. This guide explains how to connect to these nodes and access BOOM’s services.

## Connect to BOOM
Before accessing the MSI nodes, ensure you're connected to the University of Minnesota network. If you're off-campus or not connected to the university Wi-Fi, you'll need to use the [UMN VPN](https://it.umn.edu/services-technologies/virtual-private-network-vpn).

To access the MSI nodes assigned to boom, you should SSH into your node and then using a jump host (bridge).
For example, if your assigned node is xxx111, run:

```
ssh -J your_umn_username@mangi.msi.umn.edu your_umn_username@xxx111
```
- _The -J option specifies the jump host (bridge) connection through the login node (mangi.msi.umn.edu)._
- _Replace your_umn_username with your UMN account username._
- _Replace xxx111 with the node allocated to boom._


You will then need to enter your UMN password and choose a two-factor authentication method (only Duo is available).
To avoid typing the long command, your password, and Duo verification each time, you can do as follows:

1. **Edit (or create) your SSH config file:**

    ```
    nano ~/.ssh/config
    ```

2. **Add the following lines:**

    ```
    Host boom
        HostName xxx111
        User your_umn_username
        ProxyJump your_umn_username@mangi.msi.umn.edu
    
        ControlMaster auto
        ControlPath /tmp/%r@%h:%p
        ControlPersist 2h
    ```
    _The first block allows you to connect to the BOOM nodes using `ssh boom`. The second block keeps the SSH connection alive while a terminal is open, and for 2 hours afterward. This prevents you from having to validate Duo each time you open a new SSH connection._

3. **Set up SSH key-based authentication:**
    ```
    ssh-keygen -t ed25519 -C "your_umn_username@umn.edu"
    ssh-copy-id -i ~/.ssh/id_ed25519.pub your_umn_username@mangi.msi.umn.edu
    ```
    _This allows passwordless login through the jump host._


## Monitor BOOM
To access BOOM services running on specific ports on the host node, you can use SSH port forwarding as follows:
```
ssh -L LOCAL_PORT:localhost:REMOTE_PORT boom
```

This will forward the service running on the node to the same port on your local computer, allowing you to access it as if it were running locally. For example, to access some common services:

- **Uptime kuma:**
```
ssh -L 3001:localhost:3001 boom
```
- **Prometheus:**
```
ssh -L 9090:localhost:9090 boom
```
- **Kafka (with filter worker output):**
```
ssh -L 9092:localhost:9092 boom
```
_After running the command, you can open your browser or local client and connect to localhost:<LOCAL_PORT> to interact with the service._


## Backup BOOM Data
MSI provides access to a [Second Tier Storage](https://msi.umn.edu/about-msi-services/data-storage/second-tier-storage) platform offering up to 120 TB of space per project.
This storage tier is slower than the primary HPC storage but is ideal for large datasets, archival data, and backups.

BOOM uses this storage to back up and restore its MongoDB databases.
The Second Tier Storage supports both the S3 (Simple Storage Service) interface and Globus for data transfer.
The following steps describe how to back up and restore the BOOM MongoDB data using S3:

1. **Dump MongoDB to a gzip file**
    ```bash
    ./apptainer.sh backup <local_backup_dir>
    ```
2. **Upload the backup to S3**
    ```bash
    s3cmd put <path_to_backup_directory>/mongo_YYYY-MM-DD.gz s3://<bucket_name>
    ```

3. **List backups on S3**
    ```bash
    s3cmd ls s3://<bucket_name>
    # Example output:
    # 2025-10-15 17:15    64G  s3://<bucket_name>/mongo_2025-10-15.gz
    ```

4. **Download a backup**
    ```bash
    s3cmd get s3://<bucket_name>/mongo_YYYY-MM-DD.gz <local_restore_dir>
    ```

5. **Restore MongoDB from a backup**
    ```bash
    ./apptainer.sh restore <local_restore_dir>/mongo_YYYY-MM-DD.gz
    ```