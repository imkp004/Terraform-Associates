# Terraform Resource Graph

## What is the Resource Graph?

The **Terraform Resource Graph** is an internal dependency graph that Terraform builds **behind the scenes**.

You never create or manage this graph yourself. Terraform automatically builds it every time you run commands such as:

```bash
terraform plan
```

or

```bash
terraform apply
```

Its job is to answer one question:

> **"In what order should I create, update, or destroy resources?"**

The Resource Graph ensures that resources are created in the correct order based on their dependencies.

---

# Why Does Terraform Need a Resource Graph?

Imagine you want to create:

* A VPC
* A Subnet
* An EC2 Instance

Can Terraform create the EC2 instance first?

No.

The EC2 instance needs a subnet.

The subnet needs a VPC.

So Terraform must create them in this order:

```text
VPC
 │
 ▼
Subnet
 │
 ▼
EC2 Instance
```

The Resource Graph is what allows Terraform to figure this out automatically.

---

# The Order of Your `.tf` Files Does NOT Matter

One of the biggest beginner misconceptions is that Terraform reads files from top to bottom.

It does **not**.

Suppose you have:

```text
main.tf
network.tf
ec2.tf
security.tf
outputs.tf
```

Terraform scans **every `.tf` file** in the current directory and combines them into **one configuration**.

Then it builds the Resource Graph.

It doesn't matter whether the VPC is defined before or after the EC2 instance.

Terraform determines the correct order based on **resource references**, not file order.

---

# Example

Suppose your code looks like this.

## ec2.tf

```hcl
resource "aws_instance" "web" {

  ami           = "ami-123456"

  instance_type = "t3.micro"

  subnet_id = aws_subnet.public.id

}
```

---

## network.tf

```hcl
resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"

}

resource "aws_subnet" "public" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.1.0/24"

}
```

Notice something interesting.

The EC2 resource is written **before** the VPC.

But Terraform still creates:

```text
VPC
 │
 ▼
Subnet
 │
 ▼
EC2
```

because of the resource references.

---

# What is a Dependency?

A dependency means:

> **One resource must exist before another resource can be created.**

Terraform automatically discovers these relationships.

---

# Two Types of Dependencies

Terraform supports two types of dependencies:

* **Implicit Dependency**
* **Explicit Dependency**

---

# 1. Implicit Dependency

An implicit dependency is created **automatically**.

Terraform detects it by looking at **resource references**.

Whenever one resource uses another resource's value, Terraform knows which one must be created first.

---

## Example

```hcl
resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"

}

resource "aws_subnet" "public" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.1.0/24"

}
```

Look carefully:

```hcl
vpc_id = aws_vpc.main.id
```

Terraform reads this and says:

> "The subnet needs the VPC's ID."

Therefore:

```text
Create VPC
      │
      ▼
Create Subnet
```

You didn't tell Terraform the order.

Terraform figured it out automatically.

This is called an **implicit dependency**.

---

# Another Example

```hcl
resource "aws_security_group" "web" {

  vpc_id = aws_vpc.main.id

}

resource "aws_instance" "web" {

  security_groups = [

    aws_security_group.web.id

  ]

}
```

Terraform understands:

```text
VPC
 │
 ▼
Security Group
 │
 ▼
EC2
```

Again, no manual ordering was required.

---

# 2. Explicit Dependency

Sometimes Terraform **cannot detect a dependency**.

In these situations, you must tell Terraform manually.

This is called an **explicit dependency**.

Terraform uses:

```hcl
depends_on
```

---

# Example

Suppose you have:

```hcl
resource "aws_instance" "web" {

  ami = "ami-123456"

  instance_type = "t3.micro"

}
```

and

```hcl
resource "aws_s3_bucket" "logs" {

  bucket = "my-logs"

}
```

Notice that the EC2 instance never references the S3 bucket.

Terraform thinks:

```text
These resources are unrelated.
```

So Terraform may create them simultaneously.

---

But suppose your application running on the EC2 instance requires the S3 bucket to already exist before startup.

Terraform cannot know that.

You must tell it:

```hcl
resource "aws_instance" "web" {

  ami = "ami-123456"

  instance_type = "t3.micro"

  depends_on = [

    aws_s3_bucket.logs

  ]

}
```

Now Terraform creates:

```text
S3 Bucket
      │
      ▼
EC2 Instance
```

Even though there is no resource reference.

---

# Another Explicit Dependency Example

Suppose you create:

* IAM Role
* EC2 Instance

The EC2 doesn't directly reference the IAM role, but your startup script expects the role to already exist.

You can write:

```hcl
depends_on = [

  aws_iam_role.web_role

]
```

Terraform now waits until the IAM role is created.

---

# What Does the Resource Graph Look Like?

Imagine your infrastructure:

```text
VPC

Subnet

Security Group

EC2

RDS

Load Balancer
```

Terraform builds a graph like this:

```text
          VPC
        /     \
       ▼       ▼
   Subnet   Security Group
       \       /
        ▼     ▼
           EC2
             │
             ▼
     Load Balancer

VPC
 │
 ▼
RDS
```

Every box is a **node**.

Every arrow is a **dependency**.

Terraform follows these arrows when creating resources.

---

# What Is Parallel Execution?

Once Terraform builds the Resource Graph, it checks:

> "Which resources can be created at the same time?"

Resources that have **no dependencies between them** can be created simultaneously.

This makes deployments much faster.

---

# Example

Suppose you have:

```text
VPC

S3 Bucket

IAM Role
```

None of these depend on each other.

Terraform can create all three at the same time.

```text
Start

 ├────────► VPC

 ├────────► S3 Bucket

 └────────► IAM Role
```

This is called **parallel execution**.

---

# Another Example

Suppose you have:

```text
VPC
 │
 ▼
Subnet
 │
 ▼
EC2

S3 Bucket

IAM Role
```

Terraform creates:

Step 1

```text
VPC

S3 Bucket

IAM Role
```

These can run in parallel (where possible).

Then:

Step 2

```text
Subnet
```

Then:

Step 3

```text
EC2
```

Terraform only waits when a dependency exists.

---

# Why Parallel Execution Is Faster

Imagine creating 100 independent S3 buckets.

If Terraform created them one at a time:

```text
Bucket 1

Bucket 2

Bucket 3

...

Bucket 100
```

It would take much longer.

Instead Terraform creates many of them simultaneously, greatly reducing deployment time.

---

# How Many Resources Can Terraform Create in Parallel?

By default, Terraform performs:

```text
10 parallel operations
```

This means Terraform can work on up to **10 resources at the same time**, provided there are no dependency conflicts.

---

# Can You Change the Limit?

**Yes.**

You can change the number of parallel operations using the `-parallelism` flag.

Example:

```bash
terraform apply -parallelism=20
```

Now Terraform can perform up to **20 parallel operations**.

You can also use it with:

```bash
terraform plan -parallelism=20
```

or

```bash
terraform destroy -parallelism=20
```

---

# Should You Always Increase It?

Not necessarily.

Increasing parallelism can speed up deployments, but it also means:

* More API requests are sent to the cloud provider.
* You may hit AWS, Azure, or GCP API rate limits.
* Your computer uses more CPU and memory.
* Some providers recommend keeping the default value unless you have a specific reason to change it.

For most projects, the default value of **10** works well.

---

# Key Points to Remember

* The **Resource Graph** is an internal graph Terraform builds automatically.
* It determines the correct order to create, update, and destroy resources.
* The order of your `.tf` files does **not** matter.
* Terraform scans all `.tf` files and builds one complete dependency graph.
* A **dependency** means one resource must exist before another can be created.
* **Implicit dependencies** are detected automatically through **resource references**.
* **Explicit dependencies** are created manually using the `depends_on` argument when Terraform cannot infer the relationship.
* Resources without dependencies can be created **in parallel**.
* Terraform performs **10 parallel operations by default**.
* You can change this limit using the `-parallelism` flag, such as `terraform apply -parallelism=20`.

---

# Summary

The Terraform Resource Graph is one of the core features that makes Terraform intelligent. Instead of following the order of your `.tf` files, Terraform analyzes every resource and builds a graph of dependencies. This graph tells Terraform exactly which resources must be created first and which resources can be created at the same time. Most dependencies are discovered automatically through resource references (implicit dependencies), while special cases can be handled manually using `depends_on` (explicit dependencies). Once the graph is built, Terraform executes independent resources in parallel—10 at a time by default—making infrastructure deployments both accurate and efficient.
