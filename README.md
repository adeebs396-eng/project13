# Project 13: Internal Monitoring and Observability Platform

Prometheus and Grafana on Azure, provisioned with Terraform,
deployed with Docker Compose.

## Layout

- `infra/`   Terraform. Resource group, network, firewall and VM
- `stack/`   Docker Compose stack that runs on the VM
- `scripts/` Bash automation
- `docs/`    Documentation

## Setup

1. `cd infra`
2. `cp terraform.tfvars.example terraform.tfvars` and fill in the values
3. `terraform init && terraform apply`

The VM installs Docker and brings the stack up by itself at first boot.
