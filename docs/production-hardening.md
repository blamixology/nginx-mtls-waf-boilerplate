# Production hardening checklist

This repository is intentionally local and self-contained. A production design should add:

- CA lifecycle automation, short-lived certificates, rotation overlap, and revocation.
- Authorization that maps a verified SAN/SPIFFE identity to specific actions; a certificate alone is not authorization.
- A maintained WAF such as AWS WAF, ModSecurity with tested rules, or a managed edge service. The included denylist only demonstrates request gating.
- Secrets mounted from a managed secret store rather than generated in or copied through CI.
- Centralized immutable access logs, alerting on handshake failures/429s/403s, and request correlation.
- Resource limits, image digest pinning, signed-image verification, patch policy, and SBOM/provenance.
- End-to-end TLS if the upstream crosses a host or trust boundary.
- Certificate subject/SAN validation rules; never trust a forwarded identity header from an untrusted proxy path.

## AWS placement options

- **ALB mTLS:** managed termination and trust-store integration for HTTP workloads; verify current regional/features and certificate-chain limits.
- **NLB TLS pass-through:** Nginx retains the TLS handshake and client-certificate policy; useful for protocol-level control.
- **Private API Gateway:** managed API policy and authentication, with different cost and feature trade-offs.
- **Service mesh:** strong workload identity at large service counts, at the price of control-plane and debugging complexity.

