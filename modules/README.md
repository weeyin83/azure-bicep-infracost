# Module map and AVM guidance

This project is intentionally organized to separate the overall landing zone orchestration from platform module definitions. The solution is designed so it can be implemented either as a single template or split into modular Bicep components once the platform grows.

## Recommended AVM mapping for production implementation

| Capability | Microsoft-recommended AVM registry module | Why use it |
|---|---|---|
| Resource group | `br/public:avm/res/resources/resource-group` | Standardizes naming, tagging, and lifecycle control |
| Virtual network | `br/public:avm/res/network/virtual-network` | Aligns with Azure networking best practice and reduces drift |
| Network security group | `br/public:avm/res/network/network-security-group` | Enforces a managed, repeatable security rule pattern |
| Azure Bastion | `br/public:avm/res/network/bastion-host` | Provides a tested Bastion deployment model with public IP and VNet integration |
| Key Vault | `br/public:avm/res/key-vault/vault` | Ensures RBAC, purge protection, and soft delete are configured consistently |
| Log Analytics | `br/public:avm/res/operational-insights/workspace` | Standardizes retention, log ingestion, and monitoring configuration |
| User-assigned identity | `br/public:avm/res/managed-identity/user-assigned-identity` | Keeps identity lifecycle aligned to cloud platform standards |
| Windows VM | `br/public:avm/res/compute/virtual-machine` | Tested implementation for VM sizing, OS disk, Boot Diagnostics, and security baseline |
| Diagnostic settings | `br/public:avm/res/insights/diagnostic-setting` | Centralizes monitoring for consistency and governance |

## Benefits over hand-authored templates

- Reduced operational drift from the Azure default configuration baseline
- Better consistency across subscriptions and environments
- Better supportability with Microsoft-aligned module semantics
- Faster security review because the module structure reflects tested design patterns
- Easier future updates as Azure capabilities evolve

## Demo note

This repository demonstrates the end-to-end architecture and GitHub cost review flow. The actual Bicep template in `bicep/main.bicep` is intentionally kept explicit so it validates cleanly in CI and is easy to inspect in a demo.
