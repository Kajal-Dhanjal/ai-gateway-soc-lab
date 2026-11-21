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

Follow [Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/).

> TODO: record the exact commands used on the first run.

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
