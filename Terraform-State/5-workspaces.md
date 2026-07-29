# Terraform Workspaces

## What Problem Do Workspaces Solve?

Imagine you have finished building your **development (dev)** environment.

Your working directory looks like this:

```text
terraform-project/

├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfstate
```

You run:

```bash
terraform apply
```

Terraform creates your infrastructure.

Now you have:

* Your Terraform configuration (`.tf` files)
* Your Terraform state file (`terraform.tfstate`)
* Your AWS infrastructure

Everything matches.

```text
Terraform Configuration (.tf)

        │

        ▼

Terraform State

        │

        ▼

AWS Dev Environment
```

---

# Now You Need Three Environments

Most real-world companies don't have only one environment.

Instead they have:

* Development (Dev)
* Testing (Test)
* Production (Prod)

Each environment is completely separate.

For example:

Development

```text
VPC
2 EC2 Instances
Small Database
```

Testing

```text
VPC
2 EC2 Instances
Small Database
```

Production

```text
VPC
10 EC2 Instances
Large Database
Load Balancer
Auto Scaling
```

The infrastructure is almost identical.

Only some values are different.

---

# Option 1 – Separate Directories

A beginner solution is creating three separate folders.

```text
project/

├── dev/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfstate
│
├── test/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfstate
│
└── prod/
    ├── main.tf
    ├── variables.tf
    └── terraform.tfstate
```

Each directory has its own:

* Configuration
* State file
* Infrastructure

This works perfectly.

---

## The Problem

Suppose you add a new security group.

You now need to edit:

```text
dev/main.tf

test/main.tf

prod/main.tf
```

The same change has to be made three times.

Now imagine your project contains:

* 30 Terraform files
* 400 resources

Every change has to be copied to three directories.

That becomes difficult to maintain.

This violates one of the main principles of Infrastructure as Code:

> **Don't Repeat Yourself (DRY).**

Duplicating code increases:

* Maintenance
* Human error
* Bugs
* Time spent updating infrastructure

---

# Option 2 – Terraform Workspaces

Terraform provides a better solution.

Instead of creating three directories, you keep **one Terraform configuration** and create multiple **workspaces**.

Think of a workspace as:

> **A separate container for Terraform's state.**

Each workspace has:

* Its own state file
* Its own infrastructure
* Its own resources

But they all use the **same Terraform code**.

```text
One Configuration

main.tf
variables.tf
outputs.tf

        │
        │
        ▼

Workspace: dev

terraform.tfstate

↓

AWS Dev

-------------------------

Workspace: test

terraform.tfstate

↓

AWS Test

-------------------------

Workspace: prod

terraform.tfstate

↓

AWS Production
```

The code is shared.

Only the state is different.

---

# Why Is This Useful?

You write your Terraform configuration once.

Instead of copying code three times, you simply switch workspaces.

Example:

Current workspace:

```text
dev
```

Run:

```bash
terraform apply
```

Terraform creates:

```text
Development Infrastructure
```

Switch workspace:

```bash
terraform workspace select test
```

Run:

```bash
terraform apply
```

Terraform creates:

```text
Testing Infrastructure
```

Switch again:

```bash
terraform workspace select prod
```

Run:

```bash
terraform apply
```

Terraform creates:

```text
Production Infrastructure
```

Notice that you never copied your Terraform code.

Only the active workspace changed.

---

# Why Doesn't It Mix the Environments?

Because every workspace has its own completely separate state file.

Example:

Workspace:

```text
dev
```

State:

```text
VPC

EC2

Database
```

Workspace:

```text
test
```

State:

```text
VPC

EC2

Database
```

Workspace:

```text
prod
```

State:

```text
VPC

Load Balancer

10 EC2

Large Database
```

Each workspace tracks only its own infrastructure.

Terraform never mixes the states together.

---

# Think of Workspaces Like Git Branches

If you've used Git, this is a good comparison.

Git:

```text
main

development

feature-login
```

Each branch has different code.

Similarly, Terraform workspaces are like separate branches, except instead of different code they hold different **state files**.

```text
Workspace

↓

Separate State

↓

Separate Infrastructure
```

Changing resources in one workspace does **not** affect the others.

---

# Real Example

Suppose your configuration creates an EC2 instance.

```hcl
resource "aws_instance" "web" {

  ami           = "ami-123456"

  instance_type = "t3.micro"

}
```

Current workspace:

```bash
terraform workspace show
```

Output:

```text
dev
```

Run:

```bash
terraform apply
```

Terraform creates:

```text
Dev EC2 Instance
```

Switch:

```bash
terraform workspace select test
```

Run:

```bash
terraform apply
```

Terraform creates another EC2 instance for the test environment.

Switch:

```bash
terraform workspace select prod
```

Run:

```bash
terraform apply
```

Terraform creates another EC2 instance for production.

Even though the Terraform code is identical, each workspace manages its own infrastructure because each workspace has its own state.

---

# Workspace Commands

## List Workspaces

Shows every workspace in the current Terraform project.

```bash
terraform workspace list
```

Example:

```text
default
dev
test
prod
```

The `*` indicates the current workspace.

Example:

```text
default

* dev

test

prod
```

---

## Create a Workspace

Creates a new workspace.

```bash
terraform workspace new dev
```

Terraform creates:

* A new workspace.
* A new state file for that workspace.

Initially, the state is empty because no infrastructure has been created yet.

---

## Select a Workspace

Switches to another workspace.

```bash
terraform workspace select prod
```

Terraform now uses the **prod** state instead of the **dev** state.

Every command after that uses the selected workspace.

Example:

```bash
terraform plan

terraform apply

terraform destroy
```

All of them operate only on the currently selected workspace.

---

## Show Current Workspace

Displays the active workspace.

```bash
terraform workspace show
```

Example output:

```text
prod
```

This is useful to verify you're working in the correct environment before making changes.

---

## Delete a Workspace

Deletes a workspace.

```bash
terraform workspace delete test
```

Terraform removes the workspace and its state.

Restrictions:

* You cannot delete the **default** workspace.
* You cannot delete the workspace you're currently using.

If you're currently in `test`, first switch to another workspace:

```bash
terraform workspace select dev
```

Then delete it:

```bash
terraform workspace delete test
```

---

# How Workspaces Store State

Suppose you have four workspaces.

```text
default

dev

test

prod
```

Terraform internally maintains a different state for each one.

Conceptually, it looks like this:

```text
Workspace

default

↓

terraform.tfstate

--------------------

Workspace

dev

↓

terraform.tfstate

--------------------

Workspace

test

↓

terraform.tfstate

--------------------

Workspace

prod

↓

terraform.tfstate
```

Each state file tracks only the resources created in that workspace.

---

# When Should You Use Workspaces?

Workspaces are a good choice when:

* The infrastructure is almost identical across environments.
* Only values change (such as instance sizes or tags).
* You want to avoid duplicating Terraform code.
* You are managing small to medium-sized projects.

---

# When Are Separate Directories Better?

Many large organisations use separate directories or separate Terraform projects instead of workspaces.

For example:

```text
terraform/

├── dev/

├── test/

└── prod/
```

This is preferred when:

* Production is very different from development.
* Different teams manage different environments.
* Each environment has its own backend and access controls.
* Separate CI/CD pipelines are required.

For enterprise-scale infrastructure, separate directories (or separate repositories) are often easier to manage than relying solely on workspaces.

---

# Terraform CLI Workspaces vs HCP Terraform Workspaces

This is a common point of confusion.

There are **two different kinds of workspaces**.

### Terraform CLI Workspaces

These are the workspaces you've learned above.

They exist on your local machine and simply provide separate Terraform state while sharing the same configuration.

Examples:

* default
* dev
* test
* prod

These are managed with commands like:

```bash
terraform workspace new
terraform workspace select
terraform workspace list
```

---

### HCP Terraform Workspaces

HCP Terraform (formerly Terraform Cloud) also uses the word **workspace**, but it means something different.

An HCP Terraform workspace is a complete remote project that includes:

* Terraform configuration
* Remote state storage
* State locking
* Variables
* Version history
* Remote execution
* Team collaboration
* CI/CD integration
* Policy enforcement

You don't switch between HCP workspaces like CLI workspaces.

Instead, each HCP workspace is usually its own independent Terraform project.

Think of it like this:

CLI Workspace:

> "A different state file using the same local project."

HCP Workspace:

> "A complete remote Terraform project with collaboration and automation features."

Although they share the same name, they solve different problems.

---

# Key Points to Remember

* A Terraform workspace is a separate instance of Terraform state.
* Multiple workspaces allow one Terraform configuration to manage multiple environments.
* Each workspace has its own independent state file.
* Workspaces prevent code duplication while keeping environments isolated.
* Switching workspaces changes which infrastructure Terraform manages.
* The default workspace is created automatically when you initialise a project.
* CLI workspaces are different from HCP Terraform workspaces—they are related concepts but not the same feature.
