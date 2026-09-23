# Demo script: show cost impact in GitHub PRs

This script is designed for an Azure architect, FinOps specialist, or platform engineering stakeholder to walk through a live cost change demonstration.

## Baseline scenario

The default parameter set uses:

- `Standard_D2s_v5`
- 1 VM
- 128 GiB premium SSD data disk
- Standard Azure Bastion
- 30-day Log Analytics retention

This produces a moderate monthly cost suitable for an initial review.

## Cost increase scenario A: larger VM

Change the parameter in the PR:

```bicep
param vmSize string = 'Standard_D4s_v5'
```

Expected impact:
- Higher compute footprint
- Increased monthly cost roughly proportional to the VM size uplift
- Infracost comments reflect a clear delta within a PR

## Cost increase scenario B: scale to two VMs

```bicep
param vmCount int = 2
```

Expected impact:
- Incremental compute cost for the second VM
- Additional NIC and disk costs
- Better demonstration of monthly total cost variance

## Cost increase scenario C: premium disk expansion

```bicep
param premiumDataDiskSizeGiB int = 512
```

Expected impact:
- Additional managed disk cost
- Clear visual difference in Infracost output
- Good demonstration of storage cost sensitivity

## Cost increase scenario D: longer Log Analytics retention

```bicep
param logAnalyticsRetentionInDays int = 90
```

Expected impact:
- Increased observability cost
- Impact visible in the Log Analytics line item
- Provides a discussion point on operational trade-offs vs cost

## Pull request flow

1. Create a branch with a small infrastructure change.
2. Update parameters to increase VM size or counts.
3. Open a pull request to `main`.
4. The GitHub Actions workflow validates Bicep.
5. The workflow runs Infracost.
6. Infracost posts a cost diff comment to the PR.
7. Review the delta and discuss the trade-offs with engineering and FinOps stakeholders.

## Example PR summary

The PR cost comment will highlight items such as:

- Compute: additional VM core hours and baseline VM cost
- Storage: premium managed disk delta
- Monitoring: Log Analytics trend increase
- Network: Bastion cost or public IP cost if the configuration is changed

## Suggested talking points

- Track the cost delta before and after each modification
- Tie each cost movement to the engineering decision being made
- Discuss whether a larger workload tier is justified for a proof-of-concept or production platform
- Use the Infracost feedback as a governance gate for infrastructure proposals
