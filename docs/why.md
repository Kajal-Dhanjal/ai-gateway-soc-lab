# Why: decisions, alternatives and research

The step docs say **what** to run. This page says **why**, what was ruled out, and where every fact came from. Read it before changing anything.

Last updated: 2026-11-22. Layer 1 (SOC) in progress.

## The idea

A SOC that watches its own AI. Every AI request passes through a gateway, the gateway's logs go into Wazuh, and Wazuh rules detect AI misuse.

| Layer | Component | State |
|---|---|---|
| 1 SOC | Wazuh 4.14.10 single node in Docker on AWS EC2 | Running |
| 2 AI | Model | Open question |
| 3 Gateway | AI gateway | Open question |
| 4 Pipeline | Wazuh agent ships gateway logs to the manager | Not started |
| 5 Detections | Wazuh rules for AI misuse | Not started |

Why this shape and not a SOC sitting next to the AI: routing the gateway's logs into the SOC is what makes the SOC watch the AI.

## Key terms

| Term | Meaning here |
|---|---|
| EC2 instance | A virtual server on AWS. Ours is `wazuh-lab` |
| Instance type | The server's size (CPU and memory). Ours is `m7i-flex.large` |
| AMI | The disk image a server starts from. Ours is Ubuntu Server 26.04 LTS |
| EBS volume | The server's disk. Ours is 50 GiB, gp3, encrypted |
| KMS key `aws/ebs` | The AWS managed key that encrypts the disk |
| Security group | A firewall around the instance. Ours is `wazuh-lab-sg` |
| `/32` | A rule that matches exactly one IP address |
| Key pair | The SSH key (`wazuh-lab.pem`). AWS keeps the public half, you keep the private half |
| SSH tunnel | Carries the dashboard's traffic inside the SSH connection, so the dashboard never faces the internet |
| Docker Engine | Runs containers on Linux. Not Docker Desktop, which is the Windows and Mac app |
| Container | A packaged program with everything it needs to run |
| Docker Compose | Starts several containers together from one file (`docker-compose.yml`) |
| Wazuh manager | Receives agent logs and runs the detection rules |
| Wazuh indexer | Stores and searches alerts |
| Wazuh dashboard | The web interface |
| Wazuh agent | Installed on a machine you want to watch. Sends its logs to the manager |
| `vm.max_map_count` | A Linux memory-mapping limit the indexer needs raised to 262144 |
| `admin` | Dashboard login, and the account the manager and dashboard use to reach the indexer |
| `wazuh-wui` | The account the dashboard uses to reach the manager's API |
| `securityadmin.sh` | Applies changed indexer users and settings to the running indexer |

## Decisions

### 1. Run it in the cloud, on AWS

**Chosen:** a new AWS account on the Free plan.

**Why:** the laptop doesn't have the disk space (Wazuh needs 50 GB). The mentor pointed to AWS. The Free plan can't charge.

**Facts:**
- New accounts get US$100 at sign-up and can earn up to US$100 more. The Free plan doesn't charge. It ends after 6 months or when the credit runs out, whichever comes first. Only accounts that have never had AWS qualify. [1]
- This account: US$100, free period ends 2027-05-22.

**Ruled out:**

| Option | Why not |
|---|---|
| Laptop | Not enough disk |
| AWS Paid plan | Costs money once the credit is used. Kept as the fallback if the Free plan instance can't cope |
| Oracle Cloud free tier | Reported to have halved its free Arm allowance in Aug 2026 [8]. Oracle's own page still showed the old limits when checked, so treat as unconfirmed. No advantage over AWS either way |
| Azure for Students | US$100 credit for 12 months [9], but AWS is the target platform for this build |

### 2. Secure the account first

**Chosen:** MFA (authenticator app, TOTP) on the AWS Builder ID.

**Why:** the console can be reached from anywhere.

**Facts:**
- The new, project based AWS sign-up signs you in through AWS Builder ID or a social login (Google, in this case). MFA registers there, not in IAM. Resources live in one home Region set at sign-up. A hard spend limit per project is available from US$20 a month. [3]
- Path: account menu > Profile > Security > Register device.

**Also done:** if you sign in with Google, GitHub or Apple, turn on two-step verification there too. That account controls your AWS sign-in.

**Not done, on purpose:** no spend limit. The Free plan can't charge, so a limit adds nothing yet. Set one before upgrading.

### 3. The server

**Chosen:** `m7i-flex.large` (2 vCPU, 8 GiB), Ubuntu Server 26.04 LTS, 50 GiB gp3 encrypted, Sydney.

**Why `m7i-flex.large`:** it's the largest type the Free plan allows. The Free plan's types are t3.micro, t3.small, t4g.micro, t4g.small, c7i-flex.large and m7i-flex.large [2]. Wazuh's single node needs at least 8 GB RAM [6].

**Why Ubuntu 26.04:** it's the current long-term release, the console default, and Docker Engine supports it [5]. Wazuh runs in Docker, so the host version doesn't affect Wazuh (see decision 5).

**Why 50 GiB:** Wazuh's single node needs at least 50 GB of disk [6].

**Why encrypted:** encrypting the disk with `aws/ebs` was a single setting in the launch wizard. An unencrypted disk in a security lab is an easy finding for any reviewer.

**Wizard defaults changed:**

| Setting | Wizard default | Ours | Why |
|---|---|---|---|
| Instance type | t3.micro (1 GiB) | m7i-flex.large (8 GiB) | Wazuh needs 8 GB |
| Storage | 8 GiB | 50 GiB | Wazuh needs 50 GB |
| Encryption | Off | On, `aws/ebs` | Data at rest protected |
| SSH source | Anywhere, 0.0.0.0/0 | My IP, /32 | Only one address can try to log in |

**Known trade-off:** Wazuh's single node minimum is 4 CPU cores [6]. This instance has 2. Running fine so far with no agents. If it struggles, the fallback is the Paid plan with `t3.xlarge` (4 vCPU, 16 GiB), about US$0.21 an hour in Sydney [7].

**Ruled out:** a ready-made Wazuh server image (AMI) from AWS Marketplace. It would mean a new instance and likely a paid size. Not checked in detail.

### 4. Network: one door, one key

**Chosen:** security group `wazuh-lab-sg` with one inbound rule, SSH (port 22) from one IP. Nothing else open.

**Why:** Wazuh listens on ports 443, 9200, 1514, 1515, 514 and 55000 on the instance. The security group blocks all of them before traffic reaches the server. The dashboard is reached through an SSH tunnel instead.

**Two locks, not one:** the security group is the network lock. Changing the default passwords (decision 6) is the second. If the network rule is ever loosened by mistake, the passwords still stand.

**Side effect:** if your home IP changes, SSH stops connecting. Fix: set the rule back to My IP. See [troubleshooting](troubleshooting.md).

**Ruled out:**

| Option | Why not |
|---|---|
| Open 443 to reach the dashboard | Puts a login page on the internet |
| SSH from Anywhere | The whole internet can try to log in |

### 5. Access from the laptop

**Chosen:** SSH from PowerShell, with a tunnel: `ssh -i .\wazuh-lab.pem -L 8443:localhost:443 ubuntu@<public-ip>`. The dashboard opens at `https://localhost:8443`.

**Why:** PowerShell's SSH client was already on the laptop and connected first time.

**Windows detail:** SSH refuses a key file other users can read. `icacls` locks it to your user. See [01-aws-setup.md](01-aws-setup.md#5-connect).

**Ruled out:**

| Option | Why not |
|---|---|
| EC2 Instance Connect (browser) | Connects from AWS's own addresses, which the My IP rule blocks (from AWS docs knowledge, not rechecked) |
| PuTTY | Works, but needs the key converted to `.ppk` first. No gain over PowerShell |

### 6. Wazuh in Docker

**Chosen:** Wazuh 4.14.10 single node, using Wazuh's official `wazuh-docker` repository. Docker Engine 29.10.0 from Docker's own apt repository.

**Why Docker:**
- Wazuh 4.14 lists Ubuntu 16.04 to 24.04 for package installs (Quickstart or step-by-step), not 26.04 [10]. Containers carry their own userland, so the host version doesn't matter.
- One command starts or stops all three components. The setup can be torn down and rebuilt the same way every time, which matters for anyone following this repo.

**Why Docker's repository, not Ubuntu's `docker.io` package:** Docker's install guide uses its own repository and lists 26.04 as supported [5].

**Ruled out:**

| Option | Why not |
|---|---|
| Quickstart script | Not listed for Ubuntu 26.04 in 4.14 [10] |
| Step-by-step package install | Same OS limit, more manual work |
| Multi-node | For scale and failover. One host is enough for a lab |
| Kubernetes | Too much for one host |
| Virtual machine (OVA) | Runs on the laptop, which doesn't have the space |

**Coming:** Wazuh 5.0 pre-release docs list Ubuntu 24.04 and 26.04 [11]. Once 5.0 is released, a non-Docker install on this host becomes an option.

**Worth knowing:** membership of the `docker` group is effectively root on the host. Fine on a single-user lab box, not on a shared server (general Docker security guidance, not rechecked here).

### 7. Change the default passwords

**Chosen:** change `admin` now, `wazuh-wui` next.

**Why:** both defaults are published in Wazuh's own files and docs. `admin` controls the dashboard and every alert in the indexer.

**How `admin` was changed:** hash the new password with Wazuh's `hash.sh`, put the hash in `internal_users.yml`, update `INDEXER_PASSWORD` in `docker-compose.yml`, restart, then run `securityadmin.sh` inside the indexer [12]. Full steps: [02-wazuh.md](02-wazuh.md#7-change-the-admin-password).

**Rules from the Wazuh docs [12]:**
- Log out of the dashboard first.
- Change one indexer user at a time.
- Double any `$` in `docker-compose.yml`.
- API passwords need 8 to 64 characters with upper case, lower case, a number and a symbol, or the manager won't start.

**Passwords never go in this repo.**

| Account | Purpose | State |
|---|---|---|
| `admin` | Dashboard login and indexer access | Changed |
| `wazuh-wui` | Dashboard to manager API | Next |
| `kibanaserver` | Dashboard's own indexer account | Optional, lower risk |

### 8. Document it in public

**Chosen:** a public repo with step docs, decision records, a dated build log, `STATUS.md` as the handover, and redacted screenshots. Pushed once per session.

**Why:** anyone can follow it, each session picks up where the last ended, and it shows the work.

**Redaction rule:** console screenshots showed the AWS account ID, a home IP and email addresses. Crop or cover them before committing. See [images/README.md](images/README.md).

## Open questions

1. Which gateway: the mentor's product or an open source stand-in?
2. Where should the model run? This instance has no memory to spare.
3. Will 2 vCPU hold up once agents report? Watch it.

## Commands

| Task | Command |
|---|---|
| Connect with tunnel | `ssh -i .\wazuh-lab.pem -L 8443:localhost:443 ubuntu@<public-ip>` |
| Container status | `cd ~/wazuh-docker/single-node && docker compose ps` |
| Stop Wazuh | `docker compose down` |
| Start Wazuh | `docker compose up -d` |
| Stop the instance | EC2 > Instances > `wazuh-lab` > Instance state > Stop |

The public IP changes each time the instance stops and starts. Check it in EC2 before connecting.

## Sources

Checked on the dates shown. Third-party sources are marked.

1. [AWS Free Tier FAQs](https://aws.amazon.com/free/faqs/), 2026-11-21
2. [Amazon EC2 Free Tier usage](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-free-tier-usage.html), 2026-11-21
3. [AWS Security Blog: ease of use and secure defaults in the new AWS experience](https://aws.amazon.com/blogs/security/ease-of-use-and-secure-defaults-in-the-new-aws-experience/), 2026-11-22
4. [AWS: Free Tier credits and 6-month free plan announcement](https://aws.amazon.com/about-aws/whats-new/2025/07/aws-free-tier-credits-month-free-plan), 2026-11-21
5. [Docker: install Docker Engine on Ubuntu](https://docs.docker.com/install/linux/ubuntu/), 2026-11-22
6. [Wazuh: Docker deployment](https://documentation.wazuh.com/current/docker/wazuh-container.html), 2026-11-21
7. Third party: [doit.com, t3.xlarge pricing in ap-southeast-2](https://www.doit.com/compute/spot/ap-southeast-2/t3.xlarge), 2026-11-21
8. Third party: [linuxiac.com on Oracle's free tier change](https://linuxiac.com/?p=214114), 2026-11-21
9. [Microsoft: Azure for Students offer](https://azure.microsoft.com/pricing/offers/ms-azr-0170p/), 2026-11-21
10. [Wazuh 4.14: Quickstart, recommended operating systems](https://documentation.wazuh.com/current/quickstart.html), 2026-11-22
11. [Wazuh 5.0 pre-release: Quickstart](https://documentation.wazuh.com/5.0-rc/quickstart.html), 2026-11-22
12. [Wazuh: changing the default password of Wazuh users (Docker)](https://documentation.wazuh.com/current/deployment-options/docker/changing-default-password.html), 2026-11-22
