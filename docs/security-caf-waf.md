# Security, CAF, and Well-Architected rationale

## Security principles

This landing zone is designed around the core principles of Zero Trust and least-privilege access:

- No public IP on the Windows VM
- Remote administration through Azure Bastion only
- Secure secret handling in Key Vault
- RBAC authorization enabled for Key Vault
- User-assigned managed identity instead of shared credentials
- Trusted Launch with Secure Boot and vTPM enabled
- Azure Monitor Agent installed for operational telemetry
- NSG control for management traffic ingress

## Key Vault design decisions

The Key Vault is configured with:

- RBAC authorization enabled
- Purge protection enabled
- Soft delete enabled
- Secrets stored for the VM admin user and password

This keeps credentials under Azure-managed secret control instead of hardcoding or exposing them in source control.

## Cloud Adoption Framework alignment

This pattern aligns with the CAF principles for:

- Standardized landing zone design
- Secure-by-default network controls
- Environment-specific resource naming and tagging
- Repeatable platform engineering practices
- Clear separation between management and workload traffic

## Azure Well-Architected Framework alignment

### Reliability

- The workload is deployed with Azure-native resource topology and managed services
- Azure Monitor Agent and diagnostics help operational resilience
- Bastion provides a stable management path

### Security

- Private-only workload access
- Azure Bastion reduces direct attack surface
- Secrets remain in Key Vault
- Trusted Launch hardens the VM baseline

### Cost optimization

- Size and disk variables are parameterized for review and optimization
- Log Analytics retention is adjustable to match actual observability goals
- Platform design is intentionally simple and cost-transparent

### Operational excellence

- Same structure can be reused across environments
- Pull request automation improves governance and review
- Clear parameterization encourages repeatable deployments and faster reviews

### Performance efficiency

- VM size is easy to change with explicit cost impact
- Managed identity and Azure Monitor reduce configuration overhead
- Network and storage design is right-sized for a secure workload baseline

## Governance recommendation

For enterprise adoption, use:

- Policy enforcement on naming and tagging
- Azure Defender or Defender for Cloud review
- Budget alerts on the subscription or resource group
- RBAC reviews for the Key Vault and admin roles
- Periodic review of Log Analytics retention and VM size choices
