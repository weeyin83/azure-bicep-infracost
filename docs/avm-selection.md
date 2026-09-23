# AVM module selection and rationale

Azure Verified Modules were selected wherever the module surface was practical and the design goal was to align to Microsoft guidance. The production-ready module mapping is documented in `modules/README.md` and is the recommended pattern for a live platform reuse scenario.

## Selected module mapping

### `resource-group`

Why selected:
- Standardizes naming and tags for all landing zone resources
- Reduces drift that occurs when resource groups are manually created by different teams
- Aligns with Microsoft CAF guidance for platform resource ownership and governance

### `virtual-network`

Why selected:
- Ensures a repeatable VNet definition, subnet layout, and address plan
- Reduces Azure networking configuration drift
- Reduces the risk of reusing mis-sized address spaces or subnet overlaps

### `network-security-group`

Why selected:
- Keeps security rules explicit, reviewed, and auditable
- Enables a clear rule set for required administrative traffic without exposing the VM publicly
- Supports a consistent secure baseline across workload families

### `bastion-host`

Why selected:
- Provides a Microsoft-supported Bastion deployment model
- Configures the required public IP and VNet integration in a tested, repeatable pattern
- Aligns with Azure security guidance to minimize direct administrative exposure

### `key-vault`

Why selected:
- Enforces RBAC authorization instead of secret access policies where possible
- Ensures purge protection and soft delete settings are enabled as standard
- Keeps credentials out of source control and outside the deployment template itself

### `operational-insights/workspace`

Why selected:
- Standardizes log and metric ingestion from supported workloads
- Simplifies retention and workspace cost tuning for FinOps review
- Aligns with Azure Monitor best practices for enterprise observability

### `managed-identity`

Why selected:
- Minimizes credential sprawl for service-to-service access
- Encourages the least-privilege model recommended by Microsoft
- Simplifies future use of Azure platform services that support managed identity

### `compute/virtual-machine`

Why selected:
- Standardizes OS configuration, disk strategy, and VM deployment patterns
- Reduces risk from bespoke, hand-maintained VM templates
- Aligns with Azure Well-Architected recommendations for security and reliability

## Benefits over manual Bicep coding

- Identity and lifecycle semantics are standardized
- Microsoft release updates are easier to absorb through module versions
- Security defaults are easier to enforce and explain to reviewers
- The template structure is easier to review and maintain across teams

## Production recommendation

For an enterprise production platform, the AVM approach is preferred because it codifies the Microsoft recommendations directly in a reusable module model. This demo intentionally uses explicit ARM/Bicep resources so the GitHub validation and Infracost diff remain clear and deterministic for the demonstration flow.
