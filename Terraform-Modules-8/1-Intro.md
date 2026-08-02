# Terraform Modules

## What are Terraform Modules?

A **Terraform module** is a **container (folder)** that groups together Terraform configuration files that perform a specific job.

Instead of placing hundreds or thousands of lines of code into one directory, you organize related resources into modules.

Think of a module as a **reusable building block** for your infrastructure.

A module can contain:

* Providers
* Resources
* Variables
* Outputs
* Data sources
* Local values
* Other Terraform configuration files

Terraform treats everything inside the module as one reusable unit.

---

# Why Do We Need Modules?

Imagine you're building infrastructure for an e-commerce application.

Without modules, your project might contain hundreds of resources in one folder:

* VPC
* Subnets
* Internet Gateway
* NAT Gateway
* Route Tables
* Security Groups
* EC2
* ECS
* RDS
* IAM
* S3
* CloudFront
* Route53
* CloudWatch
* SNS

Eventually the project becomes difficult to understand and maintain.

Instead, we divide the infrastructure into smaller logical pieces called **modules**.

For example:

```text
terraform-project/

├── main.tf
├── variables.tf
├── outputs.tf
│
└── modules/
    ├── networking/
    ├── ecs/
    ├── rds/
    ├── iam/
    └── monitoring/
```

Each module has one responsibility.

---

# Think of Modules Like LEGO Blocks

Imagine building a LEGO city.

You don't build the entire city as one giant piece.

Instead you build:

* Houses
* Roads
* Schools
* Hospitals
* Airports

Each one is built separately.

Then you connect them together.

Terraform modules work exactly the same way.

---

# Benefits of Modules

## 1. Better Organization

Instead of one huge configuration file, everything is organized into folders.

Instead of:

```text
main.tf

2500 lines
```

You get

```text
modules/

network/

ecs/

database/

security/
```

This makes projects much easier to navigate.

---

## 2. Reusability

One of the biggest advantages of modules is that you write the code **once** and reuse it many times.

Imagine you have three environments:

* Development
* Testing
* Production

Without modules:

```text
Copy

Paste

Modify
```

three different times.

Lots of duplicated code.

With modules:

```text
One module

↓

Used three times

↓

Different variables
```

Same code.

Different results.

This follows one of the most important Infrastructure as Code principles:

> **Don't Repeat Yourself (DRY).**

---

## 3. Easier Collaboration

Suppose your company has 40 Cloud Engineers.

Instead of everyone writing their own VPC configuration, one engineer creates a well-tested VPC module.

Everyone else simply uses it.

Benefits:

* Less code duplication
* Fewer mistakes
* Faster deployments
* Standardized infrastructure

---

## 4. Consistency

Suppose every EC2 instance in your company must have:

* Encryption enabled
* Monitoring enabled
* Specific security groups
* Required tags
* Company naming convention

Instead of relying on every engineer to remember these settings, you put them inside a module.

Now everyone gets the same secure configuration automatically.

---

## 5. Easier Maintenance

Suppose your networking module is used in 50 projects.

One day your company changes its tagging standard.

Without modules:

You must edit 50 different projects.

With modules:

Update the module once.

Every project can use the updated version.

---

# Modules Are Built Using Resource Blocks

Terraform resources create infrastructure.

Example:

```hcl
resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"

}
```

A module is simply a collection of many resource blocks.

Example:

```text
network module

↓

VPC

↓

Public Subnets

↓

Private Subnets

↓

Internet Gateway

↓

NAT Gateway

↓

Route Tables

↓

Security Groups
```

Instead of creating each resource separately every time, you call the module once.

---

# Example Project Without Modules

```text
main.tf

VPC

Subnets

Internet Gateway

NAT Gateway

Route Tables

Security Groups

ECS

ALB

RDS

IAM

CloudWatch

S3

CloudFront

Route53

SNS
```

Everything is mixed together.

Hard to read.

Hard to maintain.

---

# Example Project With Modules

```text
main.tf

Calls:

Network Module

Database Module

ECS Module

IAM Module

Monitoring Module
```

Each module is responsible for one part of the infrastructure.

Much cleaner.

---

# Parent and Child Modules

Terraform follows a **parent-child relationship**.

The configuration where you run Terraform commands is called the **root (parent) module**.

Every module that the root module calls is called a **child module**.

Example:

```text
Root Module

↓

Network Module

↓

Database Module

↓

ECS Module
```

The parent module controls the overall deployment.

The child modules perform specific jobs.

---

# Example Directory Structure

```text
terraform-project/

main.tf
variables.tf
outputs.tf

modules/

    network/
        main.tf
        variables.tf
        outputs.tf

    ecs/
        main.tf
        variables.tf
        outputs.tf

    rds/
        main.tf
        variables.tf
        outputs.tf
```

Each folder is an independent Terraform module.

---

# Calling a Module

Suppose you have this folder:

```text
modules/network
```

Inside it:

```text
main.tf

variables.tf

outputs.tf
```

In the root module:

```hcl
module "network" {

  source = "./modules/network"

  vpc_cidr = "10.0.0.0/16"

}
```

---

# Complete Module Block

```hcl
module "network" {

  source = "./modules/network"

  vpc_cidr          = "10.0.0.0/16"

  public_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]

  private_subnets   = ["10.0.10.0/24", "10.0.20.0/24"]

  environment       = "dev"

  project_name      = "ecommerce"

}
```

Let's explain every part.

---

## module

This tells Terraform that you are using another Terraform module.

---

## "network"

This is the local name of the module.

It is only used inside your Terraform configuration.

Later you can reference outputs using:

```hcl
module.network.vpc_id
```

---

## source

```hcl
source = "./modules/network"
```

This tells Terraform where the module lives.

It can point to:

Local folder

```text
./modules/network
```

GitHub repository

```text
github.com/company/network-module
```

Terraform Registry

```text
terraform-aws-modules/vpc/aws
```

Private registry

```text
company-registry/network
```

---

## Remaining Arguments

Everything else is simply input variables for the module.

Example:

```hcl
vpc_cidr = "10.0.0.0/16"
```

This value is received by:

```hcl
variable "vpc_cidr" {

  type = string

}
```

inside the module.

---

# How Data Flows

```text
Root Module

↓

Module Inputs (Variables)

↓

Resources Created

↓

Module Outputs

↓

Root Module Uses Outputs
```

Example:

Root module

```hcl
module "network" {

  source = "./modules/network"

}
```

Network module output

```hcl
output "vpc_id" {

  value = aws_vpc.main.id

}
```

Back in the root module:

```hcl
resource "aws_subnet" "public" {

  vpc_id = module.network.vpc_id

}
```

Notice the reference:

```text
module.network.vpc_id
```

This means:

```
module
↓

network

↓

output named vpc_id
```

---

# Module Versioning

Modules can have versions, just like software.

Instead of downloading the newest version every time, you can lock your configuration to a specific version.

Example:

```hcl
module "vpc" {

  source  = "terraform-aws-modules/vpc/aws"

  version = "5.21.0"

}
```

Terraform always downloads version **5.21.0**.

---

## Why Version Modules?

Suppose today you use:

```text
Version 5.2
```

Next month the module author releases:

```text
Version 6.0
```

Version 6 may include:

* New features
* Bug fixes
* Breaking changes
* Different variable names

If Terraform automatically upgraded everyone to version 6, many deployments could fail.

By locking the version:

```hcl
version = "5.21.0"
```

everyone on your team uses the exact same module version until you intentionally upgrade.

This makes deployments predictable and avoids the classic problem:

> "It works on my machine, but not on yours."

---

# Module Sources

Modules can come from several places:

### Local Module

```hcl
source = "./modules/network"
```

Used for your own project.

---

### Terraform Registry

```hcl
source = "terraform-aws-modules/vpc/aws"
```

Downloads community modules from the Terraform Registry.

---

### GitHub

```hcl
source = "git::https://github.com/company/network-module.git"
```

Useful for sharing modules within a company.

---

### Private Registry

Many organizations host their own private module registry so teams can share approved, secure modules internally.

---

# Best Practices

* Design each module to do **one specific job** (for example, networking, ECS, RDS, or IAM).
* Keep modules small and focused instead of creating one massive "everything" module.
* Use variables instead of hardcoding values.
* Expose only the outputs that other modules need.
* Version shared modules to ensure consistent deployments.
* Document your module's inputs, outputs, and purpose so other engineers can use it easily.
* Reuse modules instead of copying and pasting Terraform code.

---

# Key Points to Remember

* A **Terraform module** is a reusable container of Terraform configuration files.
* Modules improve organization by grouping related resources together.
* They help eliminate duplicated code by allowing the same infrastructure to be reused with different variables.
* The root (parent) module calls child modules, creating a parent-child relationship.
* Modules receive information through **variables** and return useful information through **outputs**.
* Modules can be stored locally, in Git repositories, or in the Terraform Registry.
* Versioning modules ensures that every team member uses the same tested version, making deployments more stable and predictable.
* Modules are one of the most important features for building clean, scalable, and maintainable Terraform projects.
