# Azure Landing Zone + Bicep + AVM + Infracost Demo

This repository demonstrates a secure Azure landing zone pattern for a single Windows workload in a production-aligned environment. It is intentionally designed for GitHub pull request workflows where Infracost can analyse infrastructure changes and post a cost delta directly to the PR.

## Included architecture

- Resource Group
- Virtual Network + workload subnet + AzureBastionSubnet
- Azure Bastion Standard
- Network Security Group
- Key Vault with RBAC authorization, purge protection, and soft delete
- Log Analytics Workspace
- Windows Server 2022 VM with Trusted Launch
- User-assigned managed identity
- Azure Monitor Agent installation
- Diagnostic settings for platform visibility

## Design principles

- Secure by default with no public IP on the workload VM
- Management path routed exclusively through Azure Bastion
- Key Vault for VM credential storage and retrieval
- Least-privilege access using RBAC
- Azure Well-Architected Framework (WAF) and Cloud Adoption Framework (CAF) patterns
- Azure Verified Modules (AVM) used where available to reduce drift and align with Microsoft guidance

## Repository layout

```text
.
├── .github/
│   └── workflows/
│       └── bicep-infracost-pr.yml
├── bicep/
│   ├── main.bicep
│   └── main.parameters.json
├── docs/
│   ├── architecture.md
│   ├── avm-selection.md
│   ├── demo-script.md
│   └── security-caf-waf.md
├── modules/
│   └── README.md
├── .gitignore
├── .infracost.yml
├── README.md
└── infra-cost-demo.md
```

## Deployment target

- Default region: UK South
- Region is parameterized to support a Five Eyes region strategy and repeatable demo use in alternative regions
- The example is aligned to a secure platform engineering approach with standardized naming and operational guardrails

## Cost demonstration strategy

The deployment has intentionally configurable variables for:

- VM size
- VM count
- Premium SSD size
- Bastion SKU
- Log Analytics retention
- Additional managed disks

These are designed so a PR can show visible cost deltas when the infrastructure changes from a small baseline to a larger scale or higher-performance profile.

## Security model summary

- Workload VM has no public IP
- Bastion provides remote admin access over private connectivity
- NSG restricts inbound traffic to Bastion subnet and required ports
- Key Vault is RBAC-authorized and protected with purge protection and soft delete
- Managed identity is used for Azure service-to-service integration
- Boot diagnostics, Trusted Launch, Secure Boot, and vTPM are enabled
- Azure Monitor Agent is installed for operational telemetry

## Infracost integration

The repository includes a GitHub Actions workflow that:

1. Validates Bicep syntax and deployment viability
2. Builds the Bicep templates
3. Runs Infracost for PRs
4. Comments with cost deltas directly on the pull request
5. Exposes monthly cost impact for key resource changes

## For the demonstration audience

This repo is intended for:

- Enterprise Azure architects
- Cloud platform engineers
- FinOps specialists
- Security engineers
- Application owners and engineering teams building secure landing zone patterns

## Notes

This workspace is intentionally scaffolded as a demonstration repository rather than a production-coded environment for a specific customer. It demonstrates the patterns and engineering disciplines required for a Microsoft-aligned Azure landing zone design integrated with pricing review automation.
