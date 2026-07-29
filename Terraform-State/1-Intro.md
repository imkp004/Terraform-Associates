# Terraform State

## What is Terraform State?

Terraform State is one of the **most important concepts** in Terraform.

It is a file that **keeps track of all the infrastructure Terraform manages**.

Whenever Terraform creates, updates, or deletes a resource, it records information about that resource in the state file.

Think of the state file as **Terraform's memory** or **brain**.

Without the state file, Terraform would have no way of knowing:

* Which resources it previously created.
* What currently exists in the cloud.
* Which resources it is responsible for managing.
* Which resources depend on one another.
* What needs to be created, updated, or destroyed.

Without state, Terraform cannot safely manage your infrastructure.

---

# Why Does Terraform Need a State File?

Imagine you create a VPC.

Terraform creates it successfully.

A week later, you run:

```bash
terraform apply
```

How does Terraform know:

* The VPC already exists?
* It shouldn't create another VPC?
* Which subnets belong to that VPC?
* Which security groups belong to that VPC?

The answer is:

**Terraform reads the state file.**

The state file contains all of this information.

---

# Real-World Analogy

Imagine you're building a city.

Every building has:

* Address
* Owner
* Type
* Utilities
* Roads connected to it

You keep all of this information in a city planning database.

Without that database, you would never know:

* Which buildings already exist.
* Where roads connect.
* Which buildings should be demolished.
* Which new buildings should be constructed.

Terraform State works exactly like that planning database.

---

# What Information Does the State File Store?

Terraform stores much more than just resource names.

For every managed resource it records information such as:

* Resource ID
* Resource Name
* Resource Type
* Provider Information
* Current Configuration
* Current Attribute Values
* Resource Dependencies
* Metadata
* Output Values
* Module Information

Example:

Suppose Terraform creates an EC2 instance.

The state file remembers things like:

```text
EC2 Instance

Resource Type:
aws_instance

Terraform Name:
web

Instance ID:
i-0123456789abcdef

AMI:
ami-123456

Instance Type:
t3.micro

Availability Zone:
us-east-1a

Public IP:
54.100.20.15

Private IP:
10.0.1.25
```

Now Terraform knows exactly which EC2 instance belongs to your configuration.

---

# Where Is the State File Stored?

By default, Terraform stores the state file locally.

Example:

```text
Project/

main.tf

variables.tf

outputs.tf

terraform.tfstate
```

The filename is always:

```text
terraform.tfstate
```

This file is automatically created after the first successful:

```bash
terraform apply
```

You do not create or edit it manually.

Terraform manages it for you.

---

# Terraform Sits Between Your Code and the Cloud

A good way to think about Terraform is like this:

```text
Terraform Configuration (.tf Files)

               │

               ▼

           Terraform

               │

        Terraform State

               │

               ▼

        AWS / Azure / GCP
```

Your `.tf` files describe the **desired state**.

The cloud contains the **actual infrastructure**.

Terraform State remembers what Terraform has already created.

Terraform compares all three before making changes.

---

# Example

Suppose your configuration contains:

```hcl
resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"

}
```

You run:

```bash
terraform apply
```

Terraform:

1. Reads the configuration.
2. Creates the VPC in AWS.
3. Receives the new VPC ID.
4. Writes the VPC information into the state file.

The state now contains something like:

```text
aws_vpc.main

↓

vpc-08f3a12bc456def78
```

Terraform now remembers:

* The VPC exists.
* It created it.
* It manages it.

---

# What Happens During terraform apply?

Every time you run:

```bash
terraform apply
```

Terraform performs several steps.

```text
Read Configuration

↓

Read State File

↓

Contact AWS

↓

Compare Current Infrastructure

↓

Determine Differences

↓

Apply Changes

↓

Update State File
```

Notice that Terraform updates the state **after** successfully creating or modifying resources.

The state file always reflects what Terraform currently manages.

---

# Resource Relationships and Dependencies

The state file also stores resource relationships.

Suppose your project contains:

```text
VPC

↓

Subnet

↓

EC2 Instance
```

Terraform knows:

* The subnet belongs to the VPC.
* The EC2 instance belongs to the subnet.

This allows Terraform to:

* Create resources in the correct order.
* Update resources correctly.
* Destroy resources safely.

---

# Resource Referencing

Suppose you have:

```hcl
resource "aws_vpc" "main" {

}

resource "aws_subnet" "public" {

  vpc_id = aws_vpc.main.id

}
```

Terraform sees:

```text
Subnet

↓

Depends on

↓

VPC
```

This dependency is recorded in the state.

Terraform understands:

Create:

```text
VPC

↓

Subnet
```

Destroy:

```text
Subnet

↓

VPC
```

You do not need to specify the order manually.

Terraform calculates it automatically.

---

# Why Is the State File So Important?

Without the state file, Terraform would not know:

* Which resources exist.
* Which resources it manages.
* Which resources belong together.
* What has changed.
* What needs updating.

Imagine deleting the state file.

Terraform would think:

> "I don't manage anything."

The resources would still exist in AWS, but Terraform would no longer know about them.

This is why the state file is considered Terraform's brain.

---

# State Locking

One of the most important features of Terraform State is **state locking**.

State locking prevents multiple people from modifying the same infrastructure at the same time.

---

## Why Is Locking Needed?

Imagine two engineers.

Alice:

```bash
terraform apply
```

Bob:

```bash
terraform apply
```

Both commands start at exactly the same time.

Without locking:

```text
Alice

↓

Reads State

↓

Creates EC2

↓

Updates State
```

At the same time:

```text
Bob

↓

Reads the old State

↓

Creates another EC2

↓

Updates State
```

Now several problems can happen:

* Duplicate resources
* Conflicting updates
* Corrupted state
* Lost changes
* Infrastructure drift

Terraform can no longer accurately describe the real infrastructure.

---

## How State Locking Works

When someone starts:

```bash
terraform apply
```

Terraform locks the state.

```text
Alice

↓

terraform apply

↓

State Locked

↓

Create Resources

↓

Update State

↓

Unlock State
```

If another engineer runs:

```bash
terraform apply
```

Terraform detects that the state is already locked.

Instead of continuing, it waits or returns an error similar to:

```text
Error

State is locked by another operation.

Please wait until the current operation finishes.
```

This guarantees that only **one Terraform operation can modify the state at a time**.

State locking prevents race conditions and keeps your infrastructure consistent.

---

# Local State

By default, Terraform stores the state file on your computer.

Example:

```text
Project

main.tf

terraform.tfstate
```

Advantages

* Simple
* Easy to learn
* No AWS setup required
* Great for labs
* Great for personal projects

Disadvantages

* Not shared
* Easy to lose
* Cannot collaborate easily
* No automatic locking
* If your laptop fails and you have no backup, you lose the state file

Because of these limitations, local state is generally recommended only for:

* Learning Terraform
* Small personal projects
* Experiments
* Practice labs

---

# Remote State

In real companies, the state file is almost never stored locally.

Instead, it is stored in a shared location called a **remote backend**.

Benefits include:

* Shared by the entire team
* Automatic backups (depending on backend)
* Centralised storage
* State locking
* Better security
* Easier collaboration
* Available from any authorised workstation

A very common remote backend is **Amazon S3**.

---

# Remote Backend with Amazon S3

Terraform can store its state file inside an S3 bucket.

Example:

```hcl
terraform {

  backend "s3" {

    bucket = "company-terraform-state"

    key = "production/terraform.tfstate"

    region = "us-east-1"

  }

}
```

---

## Understanding Each Setting

### backend "s3"

```hcl
backend "s3"
```

This tells Terraform:

> "Store my state file inside an Amazon S3 bucket."

Terraform supports other backend types as well, but S3 is one of the most common when using AWS.

---

### bucket

```hcl
bucket = "company-terraform-state"
```

This is the name of the S3 bucket where the state file will be stored.

Example:

```text
S3

↓

company-terraform-state

↓

terraform.tfstate
```

---

### key

```hcl
key = "production/terraform.tfstate"
```

The **key** is the path and filename inside the S3 bucket.

Think of it like a folder.

Example:

```text
company-terraform-state

│

├── production

│      terraform.tfstate

│

├── staging

│      terraform.tfstate

│

└── development

       terraform.tfstate
```

This allows different environments to keep separate state files while using the same S3 bucket.

---

### region

```hcl
region = "us-east-1"
```

This tells Terraform which AWS Region contains the S3 bucket.

Terraform must know where to find the bucket before it can read or update the state file.

---

# Remote State Workflow

Instead of:

```text
Terraform

↓

Local State File

↓

AWS
```

You now have:

```text
Terraform

↓

Amazon S3

↓

AWS Infrastructure
```

Every engineer reads and writes the same state file.

Everyone sees the same infrastructure.

---

# State Locking with S3

Although the state file is stored in S3, **S3 itself does not provide state locking**.

In AWS, state locking is commonly implemented using a lock service (historically Amazon DynamoDB, with newer Terraform versions also supporting S3 lockfiles in certain configurations).

The workflow looks like this:

```text
Engineer A

↓

terraform apply

↓

Acquire State Lock

↓

Read State

↓

Create Resources

↓

Update State

↓

Release Lock
```

If Engineer B starts another `terraform apply` while the lock is held, Terraform detects the lock and prevents simultaneous changes until the first operation completes.

The important idea is that **only one person can modify the shared state at a time**, preventing corruption and conflicting updates.

---

# Why Run terraform init Again?

After adding or changing a backend configuration, Terraform must initialise the backend.

Run:

```bash
terraform init
```

Terraform will:

* Detect the new backend.
* Configure the remote backend.
* Offer to migrate your existing local state to the remote backend.
* Download any required backend components.

Without running `terraform init`, Terraform will continue using the previous backend configuration.

---

# State File Example

Imagine Terraform creates:

* VPC
* Public Subnet
* EC2 Instance
* Security Group

The state file remembers:

```text
terraform.tfstate

↓

VPC ID

Subnet ID

EC2 Instance ID

Security Group ID

Relationships

Dependencies

Output Values

Provider Information
```

The next time you run `terraform plan` or `terraform apply`, Terraform uses this information to calculate exactly what needs to change.

---

# Best Practices

* Never manually edit the `terraform.tfstate` file unless absolutely necessary.
* Do not delete the state file while Terraform is managing infrastructure.
* Use a remote backend for team projects.
* Protect the state file because it may contain sensitive information.
* Use state locking to prevent multiple engineers from making changes at the same time.
* Back up your state file regularly if using local state.
* Keep separate state files for different environments such as Development, Testing, and Production.

---

# Key Points to Remember

* Terraform State is Terraform's memory and keeps track of all managed infrastructure.
* The state file records resource IDs, attributes, dependencies, relationships, outputs, and metadata.
* Terraform compares your configuration, the state file, and the actual cloud infrastructure before making changes.
* By default, the state file is stored locally as `terraform.tfstate`.
* State locking ensures only one Terraform operation can modify the infrastructure at a time, preventing conflicts and corruption.
* Remote backends allow teams to share a single state file safely and consistently.
* Amazon S3 is a common remote backend for storing Terraform state, while a locking mechanism is used to coordinate concurrent operations.
* Whenever you add or change a backend configuration, you must run `terraform init` again so Terraform can initialise or migrate the backend.
* The state file is critical to Terraform's operation and should always be protected and managed carefully.
