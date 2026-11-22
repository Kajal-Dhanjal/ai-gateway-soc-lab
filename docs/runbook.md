# Runbook: start and stop the lab

## Start

### 1. Start the instance (AWS console)

EC2 > Instances > `wazuh-lab` > Instance state > **Start instance**.

Wait for **Running** and status checks **passed**. Copy the new **Public IPv4 address**. It changes every time the instance starts.

### 2. If SSH times out: update the IP rule

Your home IP may have changed. EC2 > Security Groups > `wazuh-lab-sg` > Edit inbound rules > SSH source **My IP** > Save.

### 3. Connect with the dashboard tunnel (PowerShell)

```powershell
cd <folder-with-wazuh-lab.pem>
ssh -i .\wazuh-lab.pem -L 8443:localhost:443 ubuntu@<public-ip>
```

### 4. Start Wazuh (on the instance)

```bash
cd ~/wazuh-docker/single-node
docker compose up -d
docker compose ps
```

All three containers should show **Up**. If they were already running, `up -d` changes nothing.

### 5. Open the dashboard

Wait about a minute for the indexer, then browse to `https://localhost:8443` and log in as `admin`.

Keep the PowerShell window open. Closing it closes the tunnel.

## Stop

### 1. Stop Wazuh (on the instance)

```bash
cd ~/wazuh-docker/single-node
docker compose down
history -c
exit
```

### 2. Stop the instance (AWS console)

EC2 > Instances > `wazuh-lab` > Instance state > **Stop instance**.

A stopped instance doesn't use compute credit. Its disk is kept. Record the state in [STATUS.md](../STATUS.md).

## Quick health checks

```bash
docker compose ps                              # three containers, all Up
docker compose logs wazuh.manager --tail 30    # manager errors
free -h                                        # memory headroom
df -h /                                        # disk headroom
```
