# HCP Terraform Workspaces

## Overview

An **HCP Terraform Workspace** is the main place where Terraform manages one deployment of your infrastructure.

Think of a workspace as a **container** that holds everything Terraform needs to manage a specific environment.

Each workspace contains its own:

* Terraform state
* Variables
* Terraform version
* Run history
* Plan history
* Apply history
* Outputs
* Settings
* Permissions

A workspace represents **one instance of your infrastructure**.

---

# What Does a Workspace Manage?

For example, suppose you have a production environment.

Everything related to that environment is stored inside one workspace.

```text
Production Workspace

├── terraform.tfstate
├── Variables
├── Outputs
├── Plan History
├── Apply History
├── Terraform Version
├── Providers
└── Settings
```

If you also have development:

```text
Development Workspace

├── terraform.tfstate
├── Variables
├── Outputs
├── Run History
└── Settings
```

Each workspace is completely independent.

---

# Think of It Like Separate Computers

Imagine three different laptops.

```text
Laptop 1

Development

--------------

Laptop 2

Testing

--------------

Laptop 3

Production
```

Each laptop has:

* Different files
* Different settings
* Different data

HCP Terraform workspaces are very similar.

Each workspace has its own state and configuration values.

Nothing is shared unless you intentionally share it.

---

# Why Are Workspaces Useful?

Suppose your Terraform code creates:

* VPC
* EC2
* RDS

You want exactly the same infrastructure for:

* Development
* Testing
* Production

Instead of copying the entire project three times:

```text
dev/

main.tf

test/

main.tf

prod/

main.tf
```

you can use one Terraform configuration with multiple workspaces.

The code stays the same.

Only the workspace (and usually the input variables) changes.

---

# Example

Suppose your code contains:

```hcl
variable "environment" {
  default = "dev"
}

resource "aws_s3_bucket" "storage" {

  bucket = "company-${var.environment}"

}
```

Workspace:

```text
Development
```

Variable:

```text
environment = dev
```

Terraform creates:

```text
company-dev
```

Switch to another workspace.

Variable:

```text
environment = prod
```

Terraform creates:

```text
company-prod
```

Same code.

Different infrastructure.

---

# Each Workspace Has Its Own State

One of the biggest advantages is that every workspace has its own Terraform state.

Example:

```text
Development Workspace

terraform.tfstate

----------------------

Testing Workspace

terraform.tfstate

----------------------

Production Workspace

terraform.tfstate
```

This means:

Changing production never affects development.

Changing development never affects production.

Everything stays isolated.

---

# Workspace Isolation

Imagine you run:

```bash
terraform apply
```

while connected to the **Development** workspace.

Terraform only modifies:

```text
Development Infrastructure
```

Production remains untouched.

Later you switch:

```text
Workspace

↓

Production
```

Now:

```bash
terraform apply
```

updates only:

```text
Production Infrastructure
```

Each workspace operates independently.

---

# Variables Per Workspace

Each workspace can have different input variables.

Example:

Development:

```text
instance_type = t3.micro

database_size = 20 GB
```

Production:

```text
instance_type = m5.large

database_size = 500 GB
```

The Terraform configuration remains identical.

Only the variables change.

This makes environments much easier to manage.

---

# Run History

Every Terraform run is stored.

Example:

```text
Workspace

Production

-----------------

Run #1

Created VPC

-----------------

Run #2

Created ECS Cluster

-----------------

Run #3

Updated RDS
```

You can review:

* Who started the run
* When it happened
* What changed
* Whether it succeeded
* Whether it failed

This provides an audit trail for your infrastructure.

---

# Outputs

Outputs are also stored per workspace.

Example:

Development:

```text
ALB DNS

dev-alb.amazonaws.com
```

Production:

```text
ALB DNS

prod-alb.amazonaws.com
```

Each workspace has its own output values.

---

# Workspace Permissions

HCP Terraform allows different permissions for different users.

Example:

```text
Developers

Read + Plan

--------------------

Senior Engineers

Read + Plan + Apply

--------------------

Administrators

Full Access
```

This helps prevent accidental production changes.

---

# Terraform Versions

Each workspace can specify which Terraform version it uses.

Example:

Workspace A:

```text
Terraform 1.6
```

Workspace B:

```text
Terraform 1.8
```

This avoids the classic:

> "It works on my machine."

Everyone uses the version configured for that workspace.

---

# VCS Integration

One of HCP Terraform's biggest features is Git integration.

Example:

```text
GitHub

↓

Push Code

↓

HCP Terraform Workspace

↓

terraform init

↓

terraform plan

↓

terraform apply
```

Every Git push can automatically trigger a Terraform run.

No one has to manually execute Terraform commands.

---

# Notifications

A workspace can notify other systems when something happens.

Example:

```text
Terraform Apply Finished

↓

Slack

↓

Microsoft Teams

↓

Email
```

The team immediately knows whether a deployment succeeded or failed.

---

# CLI Workspaces vs HCP Workspaces

Many beginners confuse these two.

## CLI Workspaces

Created with:

```bash
terraform workspace new dev
```

These exist only inside your Terraform working directory.

They mainly provide separate **state files**.

---

## HCP Terraform Workspaces

Created inside the HCP Terraform web interface (or via the API).

They provide much more than state separation.

They include:

* Remote state
* Remote execution
* Variables
* Run history
* Team permissions
* Policy enforcement
* VCS integration
* Notifications
* Cost estimation (depending on plan)
* Drift detection

Think of them as complete Terraform projects managed in the cloud.

---

# Typical Workflow

```text
Developer

      │

Pushes Code

      │

GitHub

      │

Triggers

      ▼

HCP Terraform Workspace

      │

terraform init

      │

terraform plan

      │

Policy Checks

      │

terraform apply

      ▼

AWS Infrastructure
```

The workspace becomes the central place where all Terraform operations occur.

---

# Best Practices

✅ Create one workspace per environment (Development, Testing, Production).

✅ Use the same Terraform configuration across environments whenever possible.

✅ Use workspace variables instead of hardcoding environment-specific values.

✅ Give production workspaces stricter permissions than development workspaces.

✅ Connect workspaces to your Git repository for automated deployments.

✅ Review plans before applying changes to production.

---

# Simple Way to Remember

A **CLI workspace** is mainly **another Terraform state file** on your local machine.

An **HCP Terraform workspace** is an entire managed Terraform environment in the cloud.

It stores:

* State
* Variables
* Outputs
* Run history
* Team permissions
* Terraform version
* Policy checks
* Remote execution
* Git integration

Think of an HCP Terraform workspace as **a dedicated project folder in the cloud that manages one complete environment from start to finish**.
