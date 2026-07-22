# Terraform Resource Block

## What is a Resource Block?

The **resource block** is the **heart of Terraform**.

This is where you define the **actual infrastructure** you want Terraform to create, update, and delete.

If the provider tells Terraform **where** to create resources (AWS, Azure, GCP, GitHub, etc.), the **resource block tells Terraform what to create**.

Think of a resource block as a **blueprint** or **instruction sheet** for a piece of infrastructure.

For example, you can use resource blocks to create:

* EC2 Instances
* S3 Buckets
* VPCs
* Security Groups
* Load Balancers
* RDS Databases
* IAM Roles
* GitHub Repositories
* Kubernetes Clusters

Almost every piece of infrastructure you create in Terraform starts with a **resource block**.

---

# Resource Lifecycle

A resource block does more than create infrastructure.

Terraform manages the resource throughout its entire lifecycle.

This means Terraform can:

* Create the resource
* Update the resource if your code changes
* Delete the resource when it is no longer needed
* Keep track of the resource in the Terraform state file

Example:

```text
You write Terraform code
        │
        ▼
Terraform creates an EC2 instance
        │
        ▼
Later you change the instance type
        │
        ▼
Terraform updates the EC2 instance
        │
        ▼
Later you remove the resource block
        │
        ▼
Terraform deletes the EC2 instance
```

Terraform continues managing the resource until you tell it otherwise.

---

# General Resource Block Syntax

Every resource follows the same structure:

```hcl
resource "<resource_type>" "<resource_name>" {

    argument = value

}
```

Example:

```hcl
resource "aws_instance" "web" {

  ami           = "ami-123456789"

  instance_type = "t3.micro"

}
```

---

# Three Fundamental Parts of a Resource Block

Every resource block has three main parts:

1. Resource Type
2. Resource Name
3. Arguments

---

# 1. Resource Type

Example:

```hcl
resource "aws_instance" "web" {

}
```

The resource type is:

```text
aws_instance
```

This tells Terraform **what kind of resource** to create.

The resource type is defined by the **provider**, not by you.

Examples:

```text
aws_instance
```

Creates an EC2 instance.

```text
aws_s3_bucket
```

Creates an S3 bucket.

```text
aws_vpc
```

Creates a VPC.

```text
aws_security_group
```

Creates a Security Group.

You cannot invent resource types.

They must exist in the provider documentation.

---

# 2. Resource Name

Example:

```hcl
resource "aws_instance" "web" {

}
```

The resource name is:

```text
web
```

This name is created by **you**, the Terraform user.

It is only used **inside Terraform**.

AWS never sees this name.

It is **not** the EC2 instance name shown in the AWS Console.

Its purpose is to give Terraform a way to identify the resource.

Think of it as a variable name in programming.

---

## Good Resource Names

```text
web

database

backend

frontend

public_subnet

private_subnet

production_bucket
```

These names clearly describe the resource.

---

## Poor Resource Names

```text
abc

test

thing

resource1

xyz
```

These names make Terraform code difficult to understand.

Always choose meaningful names.

---

# 3. Arguments

Everything inside the braces `{}` consists of arguments.

Example:

```hcl
resource "aws_instance" "web" {

  ami           = "ami-123456"

  instance_type = "t3.micro"

}
```

Arguments tell Terraform **how the resource should be configured**.

Think of arguments as answering the questions you would normally answer in the AWS Console.

Examples:

* Which AMI?
* Which instance type?
* Which subnet?
* Which security group?
* Which key pair?

Instead of clicking buttons, you write those choices in code.

---

# Required vs Optional Arguments

Some arguments are **required**.

Without them, Terraform cannot create the resource.

Example:

```hcl
resource "aws_instance" "web" {

  ami = "ami-123456"

}
```

Terraform may return an error because `instance_type` is missing.

---

Some arguments are **optional**.

Example:

```hcl
tags = {

  Name = "Web Server"

}
```

Tags are optional, but they help organize resources.

The provider documentation tells you:

* Which arguments are required.
* Which are optional.
* What each argument does.

---

# Resource Block Breakdown

Example:

```hcl
resource "aws_instance" "web" {

  ami           = "ami-123456"

  instance_type = "t3.micro"

}
```

Let's break it down:

```text
resource
```

Terraform keyword indicating that you are defining infrastructure.

---

```text
aws_instance
```

The resource type.

Provided by the AWS provider.

It tells Terraform to create an EC2 instance.

---

```text
web
```

The resource name.

Created by you.

Used only inside Terraform for identification and referencing.

---

```text
ami
```

An argument.

Specifies which Amazon Machine Image to use.

---

```text
instance_type
```

An argument.

Specifies the EC2 instance size.

---

# Resource Referencing

One of Terraform's most powerful features is **resource referencing**.

Instead of hardcoding values, you can use information from one resource inside another.

General format:

```text
resource_type.resource_name.attribute
```

Example:

```text
aws_instance.web.id
```

This means:

> "Give me the ID of the EC2 instance named `web`."

Terraform automatically retrieves the value after the resource is created.

---

# Example 1 – Referencing a VPC

Create a VPC:

```hcl
resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"

}
```

Create a subnet:

```hcl
resource "aws_subnet" "public" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.1.0/24"

}
```

Terraform understands:

```text
VPC
   │
   ▼
Subnet
```

The subnet depends on the VPC.

Terraform creates the VPC first.

You never have to manually copy the VPC ID.

---

# Example 2 – Referencing a Security Group

Create a Security Group:

```hcl
resource "aws_security_group" "web_sg" {

}
```

Create an EC2 instance:

```hcl
resource "aws_instance" "web" {

  ami = "ami-123456"

  instance_type = "t3.micro"

  vpc_security_group_ids = [

    aws_security_group.web_sg.id

  ]

}
```

Terraform automatically inserts the Security Group ID.

---

# Example 3 – Referencing an S3 Bucket

Create an S3 bucket:

```hcl
resource "aws_s3_bucket" "logs" {

  bucket = "my-demo-bucket"

}
```

Output the bucket name:

```hcl
output "bucket_name" {

  value = aws_s3_bucket.logs.bucket

}
```

Terraform prints:

```text
bucket_name = my-demo-bucket
```

---

# Common Resource Attributes

Many resources expose attributes you can reference.

Some common ones include:

```text
.id
```

Unique identifier of the resource.

Example:

```text
aws_vpc.main.id
```

---

```text
.arn
```

Amazon Resource Name.

Example:

```text
aws_s3_bucket.logs.arn
```

---

```text
.bucket
```

S3 bucket name.

Example:

```text
aws_s3_bucket.logs.bucket
```

---

```text
.public_ip
```

Public IP address of an EC2 instance.

Example:

```text
aws_instance.web.public_ip
```

---

```text
.private_ip
```

Private IP address of an EC2 instance.

---

The available attributes depend on the resource type and are listed in the provider documentation.

---

# Resource References Create Dependencies

When one resource references another, Terraform automatically understands the dependency.

Example:

```hcl
resource "aws_vpc" "main" {

}
```

```hcl
resource "aws_subnet" "public" {

  vpc_id = aws_vpc.main.id

}
```

Terraform builds this dependency graph:

```text
VPC
 │
 ▼
Subnet
```

It knows the subnet cannot exist until the VPC exists.

This is called an **implicit dependency**.

You do not need to tell Terraform which resource to create first—it figures it out by following resource references.

---

# AWS Console vs Terraform

When creating an EC2 instance in the AWS Console, AWS asks questions such as:

* Which AMI?
* Which instance type?
* Which VPC?
* Which subnet?
* Which Security Group?
* Which key pair?

You answer these questions by clicking through the web interface.

With Terraform, you answer the same questions in code.

Instead of clicking buttons, you write:

```hcl
resource "aws_instance" "web" {

  ami                    = "ami-123456"

  instance_type          = "t3.micro"

  subnet_id              = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.web_sg.id]

}
```

The AWS provider then takes these values and calls the AWS APIs to create the EC2 instance exactly as specified.

---

# Best Practices

* Use meaningful resource names.
* Avoid hardcoding values whenever possible.
* Use variables for values that may change.
* Use resource references instead of manually copying IDs.
* Read the provider documentation to understand required and optional arguments.
* Keep related resources together in logical files (for example, `network.tf`, `compute.tf`, `database.tf`).

---

# Key Points to Remember

* The resource block is the heart of Terraform because it defines the infrastructure Terraform manages.
* A resource block contains three main parts: the resource type, the resource name, and its arguments.
* The resource type is defined by the provider and determines what kind of infrastructure will be created.
* The resource name is chosen by you and is used only within Terraform for identification and referencing.
* Arguments define how the resource should be configured and correspond to the options you would normally select in a cloud provider's web console.
* Resource references use the format `resource_type.resource_name.attribute` and allow one resource to use information from another.
* Resource references automatically create dependencies, allowing Terraform to build resources in the correct order.
* Terraform continues managing each resource throughout its lifecycle, including creation, updates, and deletion.
