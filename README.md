# Private Ethereum Network Setup with Docker, Grafana, and Prometheus

## Project Overview

This project sets up a private Ethereum network using Geth nodes, with monitoring provided by Prometheus and Grafana. The network includes a bootnode, a miner node, and an RPC endpoint. Monitoring tools are integrated to observe the performance and health of the network.

## Folder Structure

```plaintext
.
├── README.md                     # Project documentation
├── bootnode.key                  # Bootnode key used for the private network
├── docker-compose.yaml           # Docker Compose file to define and run services
├── grafana
│   ├── dashboard.yml             # Grafana dashboard configuration
│   ├── dashboards
│   │   └── main-dashboard.json   # Grafana dashboard JSON definition
│   └── datasources
│       └── datasource.yml        # Grafana datasource configuration for Prometheus
├── node-image
│   ├── Dockerfile                # Dockerfile to build the Geth client image
│   └── genesis.json              # Genesis block definition for the private network
└── prometheus
    └── prometheus.yml            # Prometheus configuration file
```

## Prerequisites
- Docker and Docker Compose
- Bootnode key (bootnode.key) generated with the command:
```bash
bootnode -genkey bootnode.key
```
- Enode address generated with:
```bash
bootnode -nodekeyhex <nodekeyhex-from-file> -writeaddress
```

## Services Overview
- geth-bootnode: Acts as the bootnode for Ethereum peers to discover each other.
- geth-rpc-endpoint: Provides an RPC interface to interact with the Ethereum network.
- geth-miner-1: The mining node that participates in block validation.
- prometheus: A monitoring tool that collects metrics from the Ethereum network.
- grafana: A web-based visualization tool to display Prometheus metrics.

## Docker Compose Configuration
The `docker-compose.yaml` file defines the services required for the private Ethereum network:

geth-bootnode: Configured with a static node key, it serves as the entry point for other nodes to connect.
geth-rpc-endpoint: Exposes the Ethereum JSON-RPC interface on port `8545`.
geth-miner-1: A single-threaded mining node.
Prometheus: Exposes its interface on port `9090` and collects metrics from the Geth nodes.
Grafana: Visualizes metrics from Prometheus, accessible on port `3000`.

## Monitoring Setup
- Prometheus: Configured to collect metrics from the Ethereum nodes using the `prometheus.yml` file.
- Grafana: A dashboard is pre-configured to visualize metrics from Prometheus. Configuration files for data sources and dashboards are provided in the grafana folder.
![dashboard](<Screenshot.png>)

## How to Run
- Ensure Docker and Docker Compose are installed on your machine.
- Generate the bootnode key if you haven't already:
```bash
bootnode -genkey bootnode.key
```
- Generate the enode address using the command:
```bash
bootnode -nodekeyhex <nodekeyhex-from-file> -writeaddress
```
- Start the entire network using Docker Compose:
```bash
docker-compose up --build
```
- Access the services:
  - Ethereum JSON-RPC Endpoint: http://localhost:8545
  - Prometheus: http://localhost:9090
  - Grafana: http://localhost:3000 (Default credentials: `admin`/`grafana`)

## Notes
- The `NETWORK_ID` and `ACCOUNT_PASSWORD` are passed through an `.env` file. Make sure to create this file before running the network.
- The subnet for the Ethereum network is restricted to `172.16.254.0/28` for security purposes.

## Customization
You can extend or modify the network by:

- Adding more miner nodes by uncommenting and editing the `geth-miner-2` service in the `docker-compose.yaml`.
- Modifying the Grafana dashboard by editing `main-dashboard.json`.
- Updating Prometheus configurations in `prometheus.yml` to monitor additional metrics.