# 02 Wazuh

Single node stack in Docker, Wazuh v4.14.10.

Source for every step on this page: [Wazuh Docker deployment](https://documentation.wazuh.com/current/docker/wazuh-container.html), checked 2026-11-21.

## Host requirements

| | Wazuh minimum | This lab |
|---|---|---|
| CPU | 4 cores | 2 vCPU (below minimum, see [decision 0001](../decisions/0001-aws-free-plan.md)) |
| Memory | 8 GB | 8 GiB |
| Disk | 50 GB | 50 GiB |

## 1. Install Docker

Source: [Docker Engine on Ubuntu](https://docs.docker.com/install/linux/ubuntu/), checked 2026-11-22. Ubuntu 26.04 is supported.

```bash
# Docker's GPG key
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Docker's apt repository
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update

# Install
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify
sudo docker run hello-world
```

Optional, run Docker without `sudo` (log out and back in after):

```bash
sudo usermod -aG docker $USER
```

## 2. Kernel setting

```bash
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee /etc/sysctl.d/99-wazuh-max-map-count.conf
sudo sysctl --system
```

The first line applies it now. The other two keep it after a reboot.

## 3. Clone

```bash
git clone https://github.com/wazuh/wazuh-docker.git -b v4.14.10
cd wazuh-docker/single-node/
```

## 4. Certificates

```bash
docker compose -f generate-indexer-certs.yml run --rm generator
```

## 5. Start

```bash
docker compose up -d
```

The indexer takes about a minute. Errors about port 9200 in that minute are expected.

## 6. Log in

Through the SSH tunnel from [01-aws-setup.md](01-aws-setup.md): `https://localhost:8443`.

Default login `admin` / `SecretPassword`. Change it straight away using the Wazuh docs section "Changing the default password of Wazuh users".

> TODO: record the password change steps on the first run.

## Done when

- [ ] Dashboard loads
- [ ] Default password changed
- [ ] One agent reporting
