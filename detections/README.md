# Detections

One folder per rule:

```
detections/
└── NNN-short-name/
    ├── rule.xml           Wazuh rule
    ├── sample-event.log   event that should trigger it
    ├── expected-alert.json
    └── README.md          what it detects, mapping, false positives
```

Record test results in [validation/STATUS-TABLE.md](../validation/STATUS-TABLE.md).
