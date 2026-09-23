# Infracost demonstration guide

## Overview

The repository is designed to make infrastructure cost review visible in a GitHub pull request. The typical flow is:

1. change a parameter in the Bicep file
2. open a PR
3. GitHub Actions validates the deployment
4. Infracost compares the cost against the base branch
5. a PR comment shows the monthly delta

## Cost-sensitive parameters

These variables are intentionally exposed in the parameter set so they can be used in a live demo:

- `vmSize`
- `vmCount`
- `premiumDataDiskSizeGiB`
- `bastionSku`
- `logAnalyticsRetentionInDays`

## Suggested before/after changes

### Change 1: VM size

Before:
```
vmSize = 'Standard_D2s_v5'
```

After:
```
vmSize = 'Standard_D4s_v5'
```

### Change 2: VM quantity

Before:
```
vmCount = 1
```

After:
```
vmCount = 2
```

### Change 3: Storage

Before:
```
premiumDataDiskSizeGiB = 128
```

After:
```
premiumDataDiskSizeGiB = 512
```

## Expected demonstration result

These changes produce visible monthly cost drift and should appear as a PR cost comment with a clear line-item increase. That is the basis for the FinOps conversation during the demonstration.

## Implementation note

The workflow in `.github/workflows/bicep-infracost-pr.yml` is the automation layer that enables the review flow.
