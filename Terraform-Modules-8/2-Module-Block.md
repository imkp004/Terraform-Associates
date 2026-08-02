# Terraform Module Block

## What is a Module Block?

A **module block** is how you **use (call)** a Terraform module in your configuration.

Think of it this way:

* A **module** is a reusable package of Terraform code.
* A **module block** is the instruction that tells Terraform to use that package.

It is very similar to calling a function in a programming language.

Instead of rewriting the same infrastructure over and over, you create it once inside a module and call it whenever you need it.

---

# Why Do We Use Module Blocks?

Imagine you work at Amazon.

Every application needs:

* A VPC
* Public and Private Subnets
* Internet Gateway
* NAT Gateway
* Security Groups
* Route Tables

If every engineer writes this from scratch, everyone will have:

* Different naming
* Different security settings
* Different tags
* Different CIDR ranges
* Different configurations

Lots of mistakes happen.

Instead, one team creates a **Networking Module**.

Everyone else simply calls that module.

The module block makes this possible.

---

# Benefits of Module Blocks

## Reusability

Write the infrastructure once.

Reuse it hundreds of times.

Instead of:

```text
Copy

Paste

Modify

Copy

Paste

Modify
```

You simply write:

```hcl
module "network" {
  source = "./modules/network"
}
```

Terraform creates everything inside that module.

---

## Better Organization

Instead of one massive project:

```text
main.tf

3000 lines
```

You organize it into:

```text
modules/

network/

ecs/

database/

monitoring/

security/
```

Every module has one responsibility.

This makes projects much easier to understand.

---

## Easier Maintenance

Suppose your networking module is used in:

* Project A
* Project B
* Project C
* Project D

One day you discover a security issue.

Without modules:

You must update every project.

With modules:

Update the module once.

Every project can use the updated version.

---

## Consistency

Every engineer uses exactly the same networking module.

That means:

* Same security
* Same naming convention
* Same tagging
* Same architecture

Everything stays standardized across the company.

---

# Basic Module Block

```hcl
module "network" {

  source = "./modules/network"

}
```

This tells Terraform:

> "Go into the `modules/network` folder and create everything inside it."

---

# Complete Module Block

```hcl
module "network" {

  source = "./modules/network"

  project_name = "ecommerce"

  environment = "dev"

  vpc_cidr = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnets = [
    "10.0.10.0/24",
    "10.0.20.0/24"
  ]

}
```

---

# Explaining Every Part

## module

```hcl
module
```

Tells Terraform:

> "I'm using another Terraform module."

---

## "network"

```hcl
module "network"
```

This is the **local name**.

You choose this name.

It only exists inside Terraform.

It is used for resource referencing.

Example:

```hcl
module.network.vpc_id
```

Terraform understands:

```
module

↓

network

↓

output called vpc_id
```

---

## source

```hcl
source = "./modules/network"
```

This tells Terraform where the module is located.

Modules can come from many places.

### Local Folder

```hcl
source = "./modules/network"
```

Most common when learning Terraform.

---

### GitHub

```hcl
source = "git::https://github.com/company/network-module.git"
```

Used when teams share modules.

---

### Terraform Registry

```hcl
source = "terraform-aws-modules/vpc/aws"
```

Downloads public modules.

---

### Private Registry

Many companies have private Terraform registries where they publish approved modules for internal use.

---

# Everything Else is a Variable

Look at this:

```hcl
environment = "dev"
```

This is **not special syntax**.

It is simply passing a value into a variable inside the module.

Inside the module you might have:

```hcl
variable "environment" {

  type = string

}
```

Terraform passes:

```
dev
```

into that variable.

Exactly like passing parameters to a function.

---

# Real-Life Example

Imagine you built this networking module.

Inside it:

```
VPC

Public Subnets

Private Subnets

Internet Gateway

NAT Gateway

Security Groups

Route Tables
```

Now your company has three environments.

Development

Testing

Production

Instead of copying everything three times:

```hcl
module "dev_network" {

  source = "./modules/network"

  environment = "dev"

  vpc_cidr = "10.0.0.0/16"

}
```

```hcl
module "test_network" {

  source = "./modules/network"

  environment = "test"

  vpc_cidr = "10.1.0.0/16"

}
```

```hcl
module "prod_network" {

  source = "./modules/network"

  environment = "prod"

  vpc_cidr = "10.2.0.0/16"

}
```

Same module.

Three different environments.

No duplicated code.

---

# Parent and Child Relationship

Terraform modules follow a parent-child relationship.

```
Root Module

│

├── Network Module

├── ECS Module

├── Database Module

└── IAM Module
```

The **Root Module** is the folder where you run:

```
terraform init

terraform plan

terraform apply
```

Every module it calls becomes a **Child Module**.

---

# Module Inputs and Outputs

A module has two ways of communicating.

## Inputs

Variables that go into the module.

Example:

```hcl
module "network" {

  source = "./modules/network"

  environment = "dev"

}
```

Inside the module:

```hcl
variable "environment" {

  type = string

}
```

Terraform sends the value `"dev"` into the module.

---

## Outputs

Outputs send information back to the parent module.

Inside the module:

```hcl
output "vpc_id" {

  value = aws_vpc.main.id

}
```

Back in the root module:

```hcl
module.network.vpc_id
```

Now another resource can use that VPC.

Example:

```hcl
resource "aws_subnet" "public" {

  vpc_id = module.network.vpc_id

}
```

This is how modules communicate with each other.

---

# Variable Scope

Variable scope is one of the most important Terraform concepts.

A variable only exists **inside the module where it is declared**.

Think of each module as its own room.

Variables inside one room cannot automatically be seen from another room.

---

## Example 1

Root Module

```hcl
variable "environment" {

  default = "dev"

}
```

Network Module

```hcl
resource "aws_vpc" "main" {

}
```

Can the network module see this variable?

**No.**

Variables are **not shared automatically**.

You must pass them.

---

## Correct Way

Root Module

```hcl
module "network" {

  source = "./modules/network"

  environment = var.environment

}
```

Network Module

```hcl
variable "environment" {

  type = string

}
```

Now the module receives the value.

---

# Think of Variable Scope Like a Classroom

Imagine three classrooms.

```
Room A

Room B

Room C
```

Each room has its own whiteboard.

Students inside Room A cannot read Room B's whiteboard.

Someone has to carry the information across.

Terraform works the same way.

Variables stay inside their own module.

If another module needs the value, the parent module must pass it.

---

# Example of Variable Scope

Root Module

```hcl
variable "region" {

  default = "us-east-1"

}

module "network" {

  source = "./modules/network"

  aws_region = var.region

}
```

Network Module

```hcl
variable "aws_region" {

  type = string

}
```

Now the networking module knows the region.

Without passing it, the module would have no idea what region to use.

---

# Can Child Modules Share Variables?

No.

Example:

```
Network Module

↓

Variable

↓

Database Module
```

The Database Module **cannot** directly access variables from the Network Module.

Instead:

```
Root Module

↓

Network Module

↓

Output

↓

Root Module

↓

Database Module
```

The Root Module acts as the middleman.

---

# Complete Example

```
terraform-project/

main.tf

modules/

    network/

        main.tf

        variables.tf

        outputs.tf
```

Root Module

```hcl
module "network" {

  source = "./modules/network"

  environment = "dev"

}
```

Inside the Network Module

```hcl
variable "environment" {

  type = string

}
```

```hcl
resource "aws_vpc" "main" {

  tags = {

    Environment = var.environment

  }

}
```

Terraform passes the variable into the module.

The module creates the VPC.

---

# Best Practices

* Design each module to perform **one specific task** (networking, ECS, RDS, IAM, etc.).
* Pass values into modules using **variables**, not hardcoded values.
* Return only the information other modules need by using **outputs**.
* Keep variables local to their module and pass them explicitly through the module block.
* Reuse modules instead of copying and pasting Terraform code.
* Version shared modules so teams can upgrade safely and consistently.
* Keep modules independent and loosely coupled so they are easier to maintain and test.

---

# Key Points to Remember

* A **module block** is how you call and use a Terraform module.
* Modules help you build reusable, organized, and maintainable Infrastructure as Code.
* The `source` argument tells Terraform where the module is located.
* Everything else inside the module block is typically an input variable passed to the module.
* The **Root Module** calls **Child Modules**.
* Variables are **scoped to the module where they are declared** and are not automatically shared.
* Child modules receive information through **variables** and return information through **outputs**.
* Modules are one of the most powerful Terraform features for building large, real-world infrastructure projects.
