# Terraform Data Block

## What is a Data Block?

A **data block** is used to **retrieve information about existing infrastructure** instead of creating new infrastructure.

Unlike a **resource block**, which creates and manages infrastructure, a **data block only reads information** from a provider.

Think of it like this:

* **Resource Block** → "Create something new."
* **Data Block** → "Find something that already exists."

The data block asks the cloud provider for information and makes that information available to your Terraform code.

---

# Why Do We Need a Data Block?

In real-world environments, not everything is created by Terraform.

Many resources may already exist, such as:

* VPCs
* Subnets
* Security Groups
* AMIs
* Availability Zones
* IAM Roles
* Route Tables

Instead of creating these resources again, Terraform can **look them up** and use them.

For example:

Suppose your company already has a production VPC.

Instead of creating another VPC, you simply retrieve the existing VPC ID and launch your EC2 instances inside it.

This saves time and prevents duplicate infrastructure.

---

# Resource Block vs Data Block

## Resource Block

Creates and manages infrastructure.

Example:

```hcl
resource "aws_instance" "web" {

  ami           = "ami-123456"

  instance_type = "t3.micro"

}
```

Terraform creates a **new EC2 instance**.

---

## Data Block

Reads existing infrastructure.

Example:

```hcl
data "aws_vpc" "production" {

  default = true

}
```

Terraform **does not create a VPC**.

It simply asks AWS:

> "Tell me about the default VPC."

---

# Real-World Analogy

Imagine moving into an office.

### Resource Block

You build a brand-new office building.

### Data Block

The office building already exists.

You simply ask the receptionist:

> "What is the building address?"

The receptionist gives you the information.

Nothing new was built.

---

# General Syntax

```hcl
data "<resource_type>" "<local_name>" {

    arguments

}
```

Example:

```hcl
data "aws_vpc" "my_vpc" {

}
```

---

# Three Parts of a Data Block

## 1. Resource Type

Example:

```text
aws_vpc
```

This tells Terraform:

> "Retrieve information about an AWS VPC."

Other examples:

```text
aws_subnet
aws_ami
aws_security_group
aws_caller_identity
aws_availability_zones
```

The resource type is defined by the provider.

---

## 2. Local Name

Example:

```text
my_vpc
```

This is a name you choose.

It is only used inside Terraform.

AWS never sees it.

Choose meaningful names.

Good examples:

```text
production_vpc

default_vpc

public_subnet

latest_amazon_linux
```

Poor examples:

```text
abc

test

thing

vpc1
```

---

## 3. Query Constraints

Terraform needs a way to identify **which resource** you want.

This is done using arguments or filters.

Example:

```hcl
data "aws_vpc" "my_vpc" {

  filter {

    name = "tag:Name"

    values = ["Production"]

  }

}
```

Terraform asks AWS:

> "Find the VPC whose Name tag is 'Production'."

---

# Example 1 – Existing VPC

Suppose AWS already contains:

```text
Production VPC

ID:
vpc-123456789
```

Terraform code:

```hcl
data "aws_vpc" "production" {

  filter {

    name = "tag:Name"

    values = ["Production"]

  }

}
```

Terraform searches AWS.

It finds:

```text
vpc-123456789
```

Nothing is created.

Terraform simply retrieves the VPC information.

---

# Using Retrieved Information

Now you can launch an EC2 instance inside that VPC.

```hcl
resource "aws_subnet" "public" {

  vpc_id = data.aws_vpc.production.id

  cidr_block = "10.0.1.0/24"

}
```

Notice:

```text
data.aws_vpc.production.id
```

Terraform uses the VPC ID returned by the data block.

You never typed:

```text
vpc-123456789
```

This avoids hardcoding.

---

# Example 2 – Existing Security Group

Suppose AWS already contains:

```text
Security Group

web-sg
```

Retrieve it:

```hcl
data "aws_security_group" "web" {

  filter {

    name = "group-name"

    values = ["web-sg"]

  }

}
```

Use it:

```hcl
resource "aws_instance" "web" {

  ami = "ami-123456"

  instance_type = "t3.micro"

  vpc_security_group_ids = [

    data.aws_security_group.web.id

  ]

}
```

Terraform retrieves the Security Group ID automatically.

---

# Example 3 – Latest Amazon Linux AMI

You should never hardcode AMI IDs because they change over time.

Instead:

```hcl
data "aws_ami" "latest_linux" {

  most_recent = true

  owners = ["amazon"]

}
```

Later:

```hcl
resource "aws_instance" "web" {

  ami = data.aws_ami.latest_linux.id

  instance_type = "t3.micro"

}
```

Terraform automatically uses the latest Amazon Linux AMI.

---

# Example 4 – Availability Zones

Instead of hardcoding:

```text
us-east-1a

us-east-1b

us-east-1c
```

Retrieve them:

```hcl
data "aws_availability_zones" "available" {

}
```

Output:

```text
us-east-1a

us-east-1b

us-east-1c
```

Now Terraform always uses the current Availability Zones.

---

# Data Block Referencing

After Terraform retrieves the data, you can reference it anywhere.

General format:

```text
data.<resource_type>.<local_name>.<attribute>
```

Example:

```text
data.aws_vpc.production.id
```

Let's break it down.

```text
data
```

Tells Terraform this is a data source.

---

```text
aws_vpc
```

The type of resource.

---

```text
production
```

The local name you gave the data block.

---

```text
id
```

The attribute you want.

Terraform returns the VPC ID.

---

# More Referencing Examples

## VPC ID

```text
data.aws_vpc.production.id
```

Returns:

```text
vpc-123456789
```

---

## Security Group ID

```text
data.aws_security_group.web.id
```

Returns:

```text
sg-123456789
```

---

## Latest AMI

```text
data.aws_ami.latest_linux.id
```

Returns:

```text
ami-08f9d8b2
```

---

## Availability Zones

```text
data.aws_availability_zones.available.names
```

Returns:

```text
[
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]
```

---

# Why Use Data Blocks?

Without a data block:

```hcl
vpc_id = "vpc-123456789"
```

Problems:

* Hardcoded value.
* Difficult to maintain.
* If the VPC changes, you must manually update your code.

---

With a data block:

```hcl
vpc_id = data.aws_vpc.production.id
```

Benefits:

* No hardcoding.
* More reusable.
* Automatically retrieves the correct value.
* Easier to maintain.
* Safer for teams.

---

# Data Blocks Do NOT Manage Resources

This is very important.

Suppose your company has an existing VPC.

Terraform retrieves it using a data block.

Terraform **does not manage that VPC**.

That means:

* Terraform will not update it.
* Terraform will not delete it.
* Terraform will not track it in the state as a managed resource.

Terraform only reads its information.

If you want Terraform to manage an existing resource, you must **import** it.

---

# Resource vs Data Block

| Resource Block                                  | Data Block                                         |
| ----------------------------------------------- | -------------------------------------------------- |
| Creates infrastructure                          | Reads existing infrastructure                      |
| Managed by Terraform                            | Not managed by Terraform                           |
| Stored in Terraform state as a managed resource | Retrieved when needed for use in the configuration |
| Can be updated and destroyed                    | Read-only                                          |
| Uses `resource` keyword                         | Uses `data` keyword                                |

---

# Best Practices

* Use data blocks whenever infrastructure already exists.
* Avoid hardcoding IDs like VPC IDs, Security Group IDs, and AMI IDs.
* Use meaningful local names.
* Read the provider documentation to see available filters and attributes.
* Use data block references instead of copying values manually.

---

# Key Points to Remember

* A data block retrieves information about existing infrastructure.
* It never creates, updates, or deletes resources.
* It is commonly used to look up VPCs, Subnets, Security Groups, AMIs, IAM Roles, and Availability Zones.
* Data blocks help avoid hardcoding values in your Terraform code.
* Information retrieved from a data block can be referenced using the format:

```text
data.<resource_type>.<local_name>.<attribute>
```

Example:

```text
data.aws_vpc.production.id
```

* Data blocks are read-only and do not place the retrieved resources under Terraform management.
* If you want Terraform to manage an existing resource, you must import it rather than use a data block.

---

# Summary

A **data block** allows Terraform to retrieve information about infrastructure that already exists without creating or managing it. It acts like a lookup mechanism, asking the cloud provider for information such as a VPC ID, Security Group ID, or the latest AMI, and then making that information available to your Terraform configuration. This keeps your code reusable, avoids hardcoding values, and allows new resources to integrate with existing infrastructure safely.
