# Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| "Failed to connect to Wazuh indexer port 9200" right after start | Indexer takes about a minute to start | Wait. Expected per Wazuh docs |
| Laptop can't run the stack | Not enough disk space | Run on a cloud instance. See [decision 0001](../decisions/0001-aws-free-plan.md) |
| MFA option not in the account menu or IAM | Project based account signs in through Builder ID | Open. See [STATUS.md](../STATUS.md) |
