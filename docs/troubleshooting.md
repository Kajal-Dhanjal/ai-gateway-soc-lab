# Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| "Failed to connect to Wazuh indexer port 9200" right after start | Indexer takes about a minute to start | Wait. Expected per Wazuh docs |
| Laptop can't run the stack | Not enough disk space | Run on a cloud instance. See [decision 0001](../decisions/0001-aws-free-plan.md) |
| MFA option not in the account menu or IAM | Project based account signs in through Builder ID | Account menu > Profile > Security. See [01-aws-setup.md](01-aws-setup.md) |
| SSH times out after it worked before | Your home IP changed, so the "My IP" rule no longer matches | EC2 > Security Groups > `wazuh-lab-sg` > Edit inbound rules > set SSH source to My IP again |
