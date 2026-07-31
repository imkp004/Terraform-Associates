# Terraform Core Components

Terraform is made up of several important components that work together to create and manage infrastructure.

The main components are:

1. **Terraform Core**
2. **Providers**
3. **Resources**
4. **State**
5. **Modules**

Understanding these components is essential because they are the foundation of how Terraform works.

---

# 1. Terraform Core

## What is Terraform Core?

**Terraform Core** is the main engine of Terraform.

It is responsible for understanding your Terraform code and deciding what needs to be created, changed, or deleted.

When you run Terraform commands like:

```bash
terraform plan
```

or:

```bash
terraform apply
```

Terraform Core reads your configuration files and figures out what actions need to happen.

---

## What Does Terraform Core Do?

Terraform Core:

* Reads your `.tf` files.
* Understands your desired infrastructure.
* Creates an execution plan.
* Compares your code with the current infrastructure.
* Determines what changes are required.
* Communicates with providers.

Think of Terraform Core as the **brain or manager of your infrastructure**.

---

## Example

You write:

```hcl
resource "aws_instance" "web" {

}
```

Terraform Core understands:

> "The user wants an EC2 instance."

Then Terraform Core asks the AWS provider to create it.

---

# 2. Providers

## What are Providers?

Providers are plugins that allow Terraform to communicate with external platforms.

Terraform itself does not know how to create an AWS EC2 instance or an Azure Virtual Machine.

Providers give Terraform the ability to interact with different platforms.

---

## Examples of Providers

Common Terraform providers:

| Provider            | Platform              |
| ------------------- | --------------------- |
| AWS Provider        | Amazon Web Services   |
| Azure Provider      | Microsoft Azure       |
| Google Provider     | Google Cloud Platform |
| Kubernetes Provider | Kubernetes            |
| Docker Provider     | Docker                |
| GitHub Provider     | GitHub                |

---

## Example

AWS Provider:

```hcl
provider "aws" {

  region = "us-east-1"

}
```

This tells Terraform:

> "Use AWS as the platform where resources will be created."

---

## Simple Explanation

Think of Terraform as a universal remote.

The remote itself does not control every TV.

It needs different connections.

Providers are those connections.

---

# 3. Resources

## What are Resources?

Resources are the actual infrastructure components that Terraform creates and manages.

They are the things you want to build.

Examples:

AWS Resources:

* EC2 Instances
* S3 Buckets
* VPCs
* Subnets
* Security Groups
* Load Balancers
* Databases

---

## Example

Creating an EC2 instance:

```hcl
resource "aws_instance" "web" {

  ami = "ami-123456"

  instance_type = "t2.micro"

}
```

Here:

* `resource` → Tells Terraform we are creating a resource.
* `aws_instance` → Type of resource.
* `web` → Name of the resource.

---

## Simple Explanation

If Terraform is building a house:

* Terraform Core = The architect
* Provider = The construction company
* Resource = The actual house components

Resources are the final things that get created.

---

# 4. Terraform State

## What is Terraform State?

Terraform State is how Terraform remembers what it has already created.

Terraform stores this information in a file called:

```text
terraform.tfstate
```

---

## Why Does Terraform Need State?

Terraform needs to know:

* What resources currently exist.
* What resources are managed by Terraform.
* What changes need to be made.

Without state, Terraform would not know what it created previously.

---

## Example

First deployment:

You create:

```
EC2 Instance
VPC
S3 Bucket
```

Terraform saves this information in:

```
terraform.tfstate
```

Later you add:

```
RDS Database
```

Terraform checks the state file and understands:

Existing:

```
EC2 Instance
VPC
S3 Bucket
```

New:

```
RDS Database
```

So Terraform only creates the database.

---

# Terraform State Tracks History

The state file keeps track of the current infrastructure state.

It records:

* Resource IDs
* Resource attributes
* Dependencies
* Current configuration

Every time you change infrastructure, Terraform updates the state.

---

# Important Note About State

In real production environments, teams usually store state remotely.

Examples:

* AWS S3
* Terraform Cloud
* Azure Storage

Why?

Because:

* Teams can share the same state.
* State can be backed up.
* State locking prevents conflicts.

---

# 5. Modules

## What are Modules?

Modules are reusable groups of Terraform code.

Instead of writing the same code again and again, you create a module once and reuse it.

---

## Example Without Modules

Imagine every project needs:

* VPC
* Subnets
* Security Groups

You write the same code for:

Development

```
VPC code
Subnet code
Security code
```

Testing

```
VPC code
Subnet code
Security code
```

Production

```
VPC code
Subnet code
Security code
```

This creates duplicate code.

---

## With Modules

You create:

```
network-module
```

Inside:

```
VPC
Subnets
Security Groups
```

Then reuse it:

```
Development
      |
      ▼
network-module


Testing
      |
      ▼
network-module


Production
      |
      ▼
network-module
```

---

## Example Module Usage

```hcl
module "vpc" {

 source = "./modules/vpc"

}
```

Terraform loads and uses the reusable code.

---

# Why Use Modules?

Modules provide:

* Code reuse
* Less duplication
* Easier maintenance
* Standardized infrastructure
* Faster development

---

# How All Components Work Together

The complete Terraform workflow:

```
              Terraform Code
                    |
                    ▼
             Terraform Core
                    |
                    ▼
              Provider
                    |
                    ▼
              Resources
                    |
                    ▼
          Cloud Infrastructure
```

Terraform State keeps track of everything:

```
Resources
    |
    ▼
terraform.tfstate
```

Modules help organize and reuse the code:

```
Module
   |
   ├── VPC
   ├── Subnets
   └── Security Groups
```

---

# Real-World Example

A company wants to deploy an application.

They need:

* VPC
* EC2 Instances
* Load Balancer
* Database
* S3 Bucket

The process:

1. Engineer writes Terraform code.
2. Terraform Core reads the code.
3. AWS Provider communicates with AWS.
4. Resources are created.
5. Terraform stores information in the state file.
6. Modules allow the same architecture to be reused for different environments.

---

# Key Points to Remember

## Terraform Core

* The main engine of Terraform.
* Understands configuration files.
* Creates plans and manages changes.

## Providers

* Allow Terraform to communicate with platforms.
* Examples: AWS, Azure, GCP.

## Resources

* The actual infrastructure components.
* Examples: EC2, VPC, S3.

## State

* Terraform's memory.
* Tracks what Terraform created and manages.

## Modules

* Reusable Terraform code.
* Helps avoid repeating code.

---

# Final Summary

Terraform works because these components work together. Terraform Core acts as the brain that understands your configuration. Providers connect Terraform to cloud platforms. Resources are the actual infrastructure components being created. State allows Terraform to remember and manage existing infrastructure. Modules allow engineers to reuse code and create consistent environments quickly. Together, these components make Terraform a powerful tool for managing cloud infrastructure using code.
