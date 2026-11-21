# Status

Read this first every session. Update it last.

**Last session:** 2026-11-22
**Layer:** 1 SOC | 2 AI | 3 Gateway | 4 Pipeline | 5 Detections
**Current:** 1 SOC

## Done last session
- AWS account created through the new sign-up (project based). Free plan confirmed.
- Repo scaffolded.

## Next step (one action)
Find where MFA is set for this account type (AWS Builder ID) and turn it on.

## Then
1. Confirm the project's home Region is Sydney (ap-southeast-2).
2. Set a project spend limit.
3. Launch the EC2 instance per [docs/01-aws-setup.md](docs/01-aws-setup.md).

## Blockers
- MFA setting not found yet. Not in the account menu, not in IAM > Root access management.

## Open questions for the mentor
- Which gateway: the mentor's product or an open source stand-in?
- Where should the AI model run? Wazuh uses the whole instance (see [decisions/0001](decisions/0001-aws-free-plan.md)).

## Account
| Item | Value |
|---|---|
| Plan | AWS Free plan |
| Credits left | US$100.00 |
| Free period ends | 2027-05-22 |
| Instance state | Not launched |
