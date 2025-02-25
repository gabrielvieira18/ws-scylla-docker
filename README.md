## Overview

This project simplifies ScyllaDB cluster configuration with 3 nodes for local testing using Docker and Docker Compose. It facilitates easy deployment and testing of ScyllaDB, a highly scalable NoSQL database.

## Prerequisites

Before you begin, make sure the following software is installed on your system:

- [Docker](https://docs.docker.com/engine/install/ubuntu/)
- [Docker Compose](https://docs.docker.com/compose/install/linux/)

> [!NOTE]
> The Docker's commands listed below consider when you use its Docker V2

## Getting Started

### **Clone this repository**

```sh
git clone https://github.com/gvieira18/ws-scylla.git
```

### **Configure ScyllaDB settings**

Before starting the cluster, ensure the [fs.aio-max-nr](https://www.kernel.org/doc/Documentation/sysctl/fs.txt) value is sufficient (e.g. `1048576` or `2097152` or more).

You can use the Makefile setup command to configure the `fs.aio-max-nr` value. It will set the value to `1048576`, which is the minimum recommended for clusters.

```sh
make setup
```

If you prefer to configure it manually, run one of the following commands to check the current value:

```sh
sysctl --all | grep --word-regexp -- 'aio-max-nr'
```
```sh
sysctl fs.aio-max-nr
```
```sh
cat /proc/sys/fs/aio-max-nr
```

If the value is lower than required, you can use one of these commands:

```sh
# Update config non-persistent
sysctl --write fs.aio-max-nr=1048576
```

> [!WARNING]
> This command adds a file to the `/etc/sysctl.d` folder to be loaded when the system boots.

```sh
# Update config persistent
echo fs.aio-max-nr=1048576 | sudo tee /etc/sysctl.d/41-aio_max_nr.conf && sudo sysctl --load '/etc/sysctl.d/41-aio_max_nr.conf'
```

<details>
  <summary><i>Optional</i></summary>

  <p style="text-align: justify;">Modify the <code>docker-compose.yml</code> file to customize ScyllaDB settings, such as port mappings, volume mounts, and network configurations.</p>
</details>

### **Start the ScyllaDB container**

Use the following command to pull the ScyllaDB Docker image (if not already downloaded) and start the container in the background:

```sh
docker compose up --detach # starts the cluster in the background
```

## Usage

### Accessing the Database

#### **CQLSH (Cassandra Query Language Shell)**

CQLSH is the command-line interface for interacting with ScyllaDB using the Cassandra Query Language (CQL). It allows you to execute CQL queries and manage the database.

```sh
docker compose exec -it ws-scylla-1 cqlsh
```

#### **Nodetool**

Nodetool is a command-line utility for managing and monitoring ScyllaDB clusters. It provides various operations, such as checking the status of nodes, compaction, repair, and more.

```sh
docker compose exec -it ws-scylla-1 nodetool status
```

#### **Inside the Docker Network**

The `docker-compose.yml` file defines a specific network (`ws-scylla`) for internal usage. Integration with other projects within different Docker Compose specifications is possible setting on external.

```yml
services:
  custom-service:
    networks:
      - ws-scylla
networks:
  ws-scylla:
    external: true
```

After starting the custom service, it registers within the `ws-scylla` network. The ScyllaDB configuration already defines default ports for access.

| Service Name |    Host     | Port  |
| ------------ | :---------: | :---: |
| ws-scylla-1  | ws-scylla-1 | 9042  |
| ws-scylla-2  | ws-scylla-2 | 9042  |
| ws-scylla-3  | ws-scylla-3 | 9042  |

```js
// Cassandra JS Driver
const client = new cassandra.Client({
  contactPoints: ['ws-scylla-1:9042', 'ws-scylla-2:9042', 'ws-scylla-3:9042'],
  localDataCenter: 'datacenter1',
  keyspace: 'system'
});
```

#### **Outside the Docker Network**

The default `docker-compose.yml` file enables the following ports for external access to the DBMS/SGDB or directly to the database driver:

| Service Name |   Host    | Port  |
| ------------ | :-------: | :---: |
| ws-scylla-1  | localhost | 9040  |
| ws-scylla-2  | localhost | 9041  |
| ws-scylla-3  | localhost | 9042  |

Using the same example from internal access:

```js
// Cassandra JS Driver
const client = new cassandra.Client({
  contactPoints: ['localhost:9040', 'localhost:9041', 'localhost:9042'],
  localDataCenter: 'datacenter1',
  keyspace: 'system'
});
```

When accessing via [**Datagrip**](https://www.jetbrains.com/pt-br/datagrip/), the JDBC standard is followed. You can build the JDBC URL as follows:

```properties
URL="jdbc:cassandra://localhost:9040,localhost:9041,localhost:9042/system"
```

### Stop and Remove Cluster/Container

#### **Stop the Cluster**

```sh
docker compose stop
```

#### **Stop and Remove Containers**

```sh
docker compose down
```

> [!CAUTION]
> Removing the volume also means removing any information stored in the database, so proceed with caution and make a backup if necessary.

```sh
docker compose down --volumes # or docker compose down -v
```

## References

- [ScyllaDB - DockerHub](https://hub.docker.com/r/scylladb/scylla)
- [ScyllaDB - University](https://university.scylladb.com/courses/scylla-essentials-overview/lessons/high-availability/topic/consistency-level-demo-part-1)
- [ScyllaDB - CarePet PHP example](https://github.com/scylladb/care-pet/blob/master/php/README.md)
- [Reflective Thoughts from a Unforgotten Past](https://gist.github.com/gvieira18/df11b9517eff971d748e82bf23a16d47)
- [fee-mendes/workshop-demo](https://github.com/fee-mendes/workshop-demo)
- [tzach/docker-compose.yml](https://gist.github.com/tzach/4d2c2485945465459e3c74cc5d42d949)

## License

This project is licensed under the [MIT License](LICENSE).
