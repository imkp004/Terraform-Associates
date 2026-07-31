# Terraform Providers

## What is a Provider?

A **provider** is one of the most important concepts in Terraform.

Terraform **does not automatically know** which cloud platform or service you want to manage.

For example, Terraform does not know if you want to create resources in:

* AWS
* Microsoft Azure
* Google Cloud Platform (GCP)
* GitHub
* Kubernetes
* Docker
* Cloudflare
* VMware

You must tell Terraform **which platform to communicate with**. This is the job of a **provider**.

Think of a provider as a **translator** between Terraform and a cloud platform.

---

## Why Do We Need Providers?

Terraform itself does **not know how to create an EC2 instance, an Azure Virtual Machine, or a GitHub repository**.

Instead, Terraform focuses on its core responsibilities:

* Reading your Terraform configuration.
* Building the Resource Graph.
* Managing dependencies.
* Tracking infrastructure in the state file.
* Determining what needs to be created, updated, or destroyed.

The **provider** handles everything related to the platform itself.

For example, the AWS provider knows how to:

* Call AWS APIs.
* Authenticate with AWS.
* Create EC2 instances.
* Create VPCs.
* Create S3 buckets.
* Delete resources.
* Update existing resources.

Terraform tells the provider:

> "Create an EC2 instance."

The provider translates that request into AWS API calls.

Without providers, Terraform would have no way to communicate with cloud platforms.

---

# Real-World Analogy

Imagine you speak only English.

You travel to Japan and need to order food.

You cannot communicate directly with the waiter.

You need a translator.

```text
You (Terraform)
        │
        ▼
Translator (Provider)
        │
        ▼
Restaurant (AWS, Azure, GCP)
```

Terraform tells the provider what it wants.

The provider translates that request into API calls the cloud platform understands.

---

# Provider Block

Providers are configured using a **provider block**.

General syntax:

```hcl
provider "<provider-name>" {

    <argument> = <value>

}
```

Example:

```hcl
provider "aws" {

    region = "us-east-1"

}
```

This tells Terraform:

> "Use the AWS provider and create resources in the US East (N. Virginia) region."

---

# Provider Documentation

Every provider has its own documentation.

The documentation explains:

* Available resources.
* Supported arguments.
* Authentication methods.
* Data sources.
* Examples.
* Best practices.

The official documentation can be found in the **Terraform Registry**.

Examples include:

* AWS Provider
* Azure Provider
* Google Provider
* GitHub Provider
* Kubernetes Provider

The documentation tells you exactly how to configure each provider and what resources it supports.

---

# Authentication

Terraform needs permission to create resources.

Simply writing:

```hcl
provider "aws" {

    region = "us-east-1"

}
```

is **not enough**.

Terraform must authenticate with AWS.

The provider needs credentials to prove:

> "I am allowed to create resources."

Without authentication, AWS rejects the requests.

---

## AWS Authentication Example

Terraform commonly authenticates using:

* AWS Access Key
* AWS Secret Access Key

Example (not recommended):

```hcl
provider "aws" {

  access_key = "YOUR_ACCESS_KEY"

  secret_key = "YOUR_SECRET_KEY"

  region = "us-east-1"

}
```

This works, but **hardcoding credentials is a bad security practice** because anyone who can read the file can see your secrets.

A better approach is to use:

* Environment variables
* AWS CLI credentials
* IAM Roles (for EC2)
* IAM Roles for Tasks (for ECS)
* IAM Roles for Service Accounts (EKS)

These methods keep credentials out of your Terraform code.

---

# One Provider Can Manage Many Resources

You only need **one provider block** to create many resources.

Example:

```hcl
provider "aws" {

  region = "us-east-1"

}
```

Now Terraform can create:

```hcl
resource "aws_vpc" "main" {

}
```

```hcl
resource "aws_subnet" "public" {

}
```

```hcl
resource "aws_instance" "web" {

}
```

```hcl
resource "aws_s3_bucket" "logs" {

}
```

All of these resources use the same AWS provider automatically.

You do **not** need a separate provider block for every resource.

---

# How Does Terraform Get the Provider?

When you define the provider in the `terraform` block:

```hcl
terraform {

  required_providers {

    aws = {

      source  = "hashicorp/aws"

      version = "~> 6.0"

    }

  }

}
```

and run:

```bash
terraform init
```

Terraform automatically:

* Downloads the provider plugin.
* Stores it in the `.terraform` directory.
* Records the provider version in `.terraform.lock.hcl`.

You do not manually install provider plugins.

Terraform manages them for you.

---

# Multiple Providers

Terraform can use **more than one provider** in the same project.

Example:

You want to create:

* An EC2 instance in AWS.
* A GitHub repository.

You can configure both providers:

```hcl
provider "aws" {

  region = "us-east-1"

}

provider "github" {

  token = var.github_token

}
```

Now Terraform can manage resources in **both AWS and GitHub** at the same time.

---

# Multiple AWS Providers (Aliases)

Sometimes you want to use the **same provider multiple times**.

For example:

* One AWS region is `us-east-1`.
* Another AWS region is `us-west-2`.

Terraform cannot distinguish between them unless you give one of them an **alias**.

Example:

```hcl
provider "aws" {

  region = "us-east-1"

}

provider "aws" {

  alias  = "west"

  region = "us-west-2"

}
```

Now you have:

* Default AWS provider → `us-east-1`
* Aliased AWS provider → `us-west-2`

---

# Assigning Resources to a Provider

By default:

```hcl
resource "aws_instance" "east_server" {

  ami           = "ami-123456"

  instance_type = "t3.micro"

}
```

Terraform uses the **default provider**.

This EC2 instance is created in:

```text
us-east-1
```

---

To create an EC2 instance in the second region:

```hcl
resource "aws_instance" "west_server" {

  provider = aws.west

  ami           = "ami-654321"

  instance_type = "t3.micro"

}
```

Terraform now uses the aliased provider.

This instance is created in:

```text
us-west-2
```

---

# Multi-Cloud Example

Terraform can even manage multiple cloud providers in one project.

Example:

```hcl
provider "aws" {

  region = "us-east-1"

}

provider "azurerm" {

  features {}

}
```

Resources:

```hcl
resource "aws_instance" "web" {

}
```

```hcl
resource "azurerm_resource_group" "rg" {

  name     = "demo-rg"

  location = "East US"

}
```

Terraform now manages infrastructure in **AWS and Azure** at the same time.

This is known as a **multi-cloud deployment**.

---

# Default Provider

If you do **not** specify an alias, Terraform treats that provider as the **default provider**.

Example:

```hcl
provider "aws" {

  region = "us-east-1"

}
```

Resource:

```hcl
resource "aws_s3_bucket" "demo" {

}
```

Terraform automatically uses:

```text
provider "aws"
```

because it is the default.

---

# Using an Aliased Provider

If a resource should use a different provider, specify it explicitly.

Example:

```hcl
provider "aws" {

  region = "us-east-1"

}

provider "aws" {

  alias  = "west"

  region = "us-west-2"

}
```

Default resource:

```hcl
resource "aws_s3_bucket" "east_bucket" {

}
```

Uses:

```text
Default AWS Provider
```

---

Second bucket:

```hcl
resource "aws_s3_bucket" "west_bucket" {

  provider = aws.west

}
```

Uses:

```text
Aliased AWS Provider
```

---

# Real-World Example

A company has:

Production:

```text
AWS us-east-1
```

Disaster Recovery:

```text
AWS us-west-2
```

Terraform configuration:

```text
Default Provider
↓

Production Resources
```

```text
Aliased Provider
↓

Disaster Recovery Resources
```

One Terraform project manages both environments.

---

# Best Practices

* Configure providers in `providers.tf`.
* Do not hardcode credentials inside provider blocks.
* Use IAM Roles or environment variables whenever possible.
* Use aliases when working with multiple regions or multiple accounts.
* Keep provider versions pinned using the `terraform` block.
* Always read the provider documentation in the Terraform Registry before using a new provider.

---

# Key Points to Remember

* A provider connects Terraform to a cloud platform or service.
* Terraform manages infrastructure, while providers communicate with the platform using its APIs.
* Providers are configured using a `provider` block written in HCL.
* Terraform downloads provider plugins automatically when you run `terraform init`.
* One provider block can manage many resources.
* Providers require authentication before they can create or modify resources.
* Multiple providers can be used in the same project (for example, AWS and GitHub).
* Aliases allow you to configure multiple instances of the same provider, such as different AWS regions or accounts.
* If no alias is specified, Terraform uses the **default provider** for matching resources.
* Resources can explicitly choose an aliased provider using the `provider` argument.
