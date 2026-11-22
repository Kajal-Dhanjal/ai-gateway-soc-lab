# Status

Read this first every session. Update it last.

**Last session:** 2026-11-22
**Layer:** 1 SOC | 2 AI | 3 Gateway | 4 Pipeline | 5 Detections
**Current:** 1 SOC

## Done last session
- AWS account created through the new sign-up (project based). Free plan confirmed.
- Repo scaffolded and pushed.
- MFA (TOTP) registered on the AWS Builder ID profile.
- Home Region confirmed: Asia Pacific (Sydney), ap-southeast-2.
- Spend limit skipped: the Free plan can't charge. Set one before any upgrade to the Paid plan.
- EC2 instance `wazuh-lab` launched (m7i-flex.large, Ubuntu 26.04, 50 GiB encrypted gp3, SSH from my IP only). SSH works.
- Docker 29.10.0 installed, hello-world passed, ubuntu user added to the docker group.
- Wazuh 4.14.10 single node running in Docker (manager, indexer, dashboard).
- `admin` password changed; dashboard login through the SSH tunnel works.
- `wazuh-wui` (API) password changed; API returns a token with the new password.

## Next step (one action)
Enrol one agent. Layer 1 is done when it reports.

## Then
1. Rotate both passwords to long random ones from a password manager before anything faces the internet.

## Blockers
- None.

## Open questions for the mentor
- Which gateway: the mentor's product or an open source stand-in?
- Where should the AI model run? Wazuh uses the whole instance (see [decisions/0001](decisions/0001-aws-free-plan.md)).

## Account
| Item | Value |
|---|---|
| Plan | AWS Free plan |
| Credits left | US$100.00 |
| Free period ends | 2027-05-22 |
| Instance state | Stopped (2026-11-22). Public IP changes on next start |
