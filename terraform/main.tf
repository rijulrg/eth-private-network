# Define a Docker network
resource "docker_network" "eth_network" {
  name   = "eth-network"
  driver = "bridge"

  ipam_config {
    subnet = "172.16.254.0/28"
  }
}

# Define the volumes
resource "docker_volume" "prom_data" {}

resource "docker_image" "geth" {
  name = "geth-client"
  build {
    context = "../node-image"
    tag     = ["geth:develop"]
    build_arg = {
      ACCOUNT_PASSWORD : var.ACCOUNT_PASSWORD
    }
    label = {
      author : "rijul_gogia"
    }
  }
}

# Define the geth-bootnode container
resource "docker_container" "geth_bootnode" {
  name    = "geth-bootnode"
  image   = docker_image.geth.image_id
  hostname = "geth-bootnode"
  
  env = [
    "ACCOUNT_PASSWORD=${var.ACCOUNT_PASSWORD}"
  ]

  command = [
    "--nodekeyhex=31ab7e16a034fe84b1efa2b855f696942c25be6ef9f635e6c034f7fc9abd0e2e",
    "--nodiscover",
    "--metrics",
    "--metrics.addr=0.0.0.0",
    "--ipcdisable",
    "--networkid=${var.NETWORK_ID}",
    "--netrestrict=172.16.254.0/28"
  ]

  networks_advanced {
    name = docker_network.eth_network.name
  }
}

# Define the geth-rpc-endpoint container
resource "docker_container" "geth_rpc_endpoint" {
  name      = "geth-rpc-endpoint"
  image     = docker_image.geth.image_id
  hostname  = "geth-rpc-endpoint"
  depends_on = [docker_container.geth_bootnode]

  env = [
    "ACCOUNT_PASSWORD=${var.ACCOUNT_PASSWORD}"
  ]

  command = [
    "--bootnodes=enode://69f8f97134fd27b8071966c800cc69d8dd340b6d6f630a114da73ec208852260beb711e08c0bd3ebe921a7b5384ad8235015467abd1b3192a3b0f8f1457b12b8@geth-bootnode:30303",
    "--allow-insecure-unlock",
    "--http",
    "--http.addr=0.0.0.0",
    "--http.api=eth,web3,net,admin,personal",
    "--http.corsdomain=*",
    "--networkid=${var.NETWORK_ID}",
    "--netrestrict=172.16.254.0/28"
  ]

  ports {
    internal = 8545
    external = 8545
  }

  networks_advanced {
    name = docker_network.eth_network.name
  }
}

# Define the geth-miner-1 container
resource "docker_container" "geth_miner_1" {
  name      = "geth-miner"
  image     = docker_image.geth.image_id
  hostname  = "geth-miner"
  depends_on = [docker_container.geth_bootnode]

  env = [
    "ACCOUNT_PASSWORD=${var.ACCOUNT_PASSWORD}"
  ]

  command = [
    "--bootnodes=enode://69f8f97134fd27b8071966c800cc69d8dd340b6d6f630a114da73ec208852260beb711e08c0bd3ebe921a7b5384ad8235015467abd1b3192a3b0f8f1457b12b8@geth-bootnode:30303",
    "--mine",
    "--miner.threads=1",
    "--networkid=${var.NETWORK_ID}",
    "--netrestrict=172.16.254.0/28"
  ]

  networks_advanced {
    name = docker_network.eth_network.name
  }
}

# Define the Prometheus container
resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = "prom/prometheus"

  command = [
    "--config.file=/etc/prometheus/prometheus.yml"
  ]

  ports {
    internal = 9090
    external = 9090
  }

  restart = "unless-stopped"

  volumes {
    host_path = "/Users/rijul/zama/eth-private-network/prometheus"
    container_path = "/etc/prometheus"
  }

  volumes {
    volume_name = docker_volume.prom_data.name
    container_path = "/prometheus"
  }

  networks_advanced {
    name = docker_network.eth_network.name
  }
}

# Define the Grafana container
resource "docker_container" "grafana" {
  name  = "grafana"
  image = "grafana/grafana"

  ports {
    internal = 3000
    external = 3000
  }

  restart = "unless-stopped"

  env = [
    "GF_SECURITY_ADMIN_USER=admin",
    "GF_SECURITY_ADMIN_PASSWORD=grafana"
  ]

  volumes {
    host_path = "/Users/rijul/zama/eth-private-network/grafana/datasources"
    container_path = "/etc/grafana/provisioning/datasources"
  }

  volumes {
    host_path = "/Users/rijul/zama/eth-private-network/grafana/dashboard.yml"
    container_path = "/etc/grafana/provisioning/dashboards/main.yml"
  }

  volumes {
    host_path = "/Users/rijul/zama/eth-private-network/grafana/dashboards"
    container_path = "/var/lib/grafana/dashboards"
  }

  networks_advanced {
    name = docker_network.eth_network.name
  }
}
