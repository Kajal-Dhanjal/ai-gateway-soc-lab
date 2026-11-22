# 0001 Run on the AWS Free plan, m7i-flex.large

**Date:** 2026-11-22
**Status:** Accepted

## Context

The laptop doesn't have the disk space for the Wazuh stack. Wazuh's single node minimum is 4 CPU cores, 8 GB RAM and 50 GB disk. The build should cost nothing while there's no budget for it.

## Decision

New AWS account on the Free plan. One `m7i-flex.large` instance (2 vCPU, 8 GiB), the largest type the Free plan allows, in Sydney.

## Alternatives

| Option | Why not |
|---|---|
| Laptop | Not enough disk |
| AWS Paid plan, `t3.xlarge` (4 vCPU, 16 GiB) | Costs money once credit runs out. Fallback if the Free plan instance can't cope |
| Oracle Cloud free tier | Reports of the free Arm allowance being halved in Aug 2026. No advantage over AWS |
| Azure for Students | Smaller credit, and AWS is the target platform for this build |

## Consequences

- 2 vCPU is below Wazuh's 4 core minimum. Expected to work for one agent, untested.
- No memory left on this host for a local AI model.
- The host runs Ubuntu 26.04, which Wazuh 4.14 does not list for package installs (Quickstart or step-by-step recommend up to Ubuntu 24.04). Wazuh runs in Docker here, so the host version doesn't matter. Don't switch to the Quickstart script on this host with 4.14.
- Hard stop when credit runs out or on 2027-05-22. Everything worth keeping lives in this repo.

## Sources

- [Wazuh Docker deployment](https://documentation.wazuh.com/current/docker/wazuh-container.html), checked 2026-11-21
- [Amazon EC2 Free Tier usage](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-free-tier-usage.html), checked 2026-11-21
- [AWS Free Tier FAQs](https://aws.amazon.com/free/faqs/), checked 2026-11-21
- [Wazuh 4.14 Quickstart, recommended operating systems](https://documentation.wazuh.com/current/quickstart.html), checked 2026-11-22
