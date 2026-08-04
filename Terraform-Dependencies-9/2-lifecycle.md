# Terraform `lifecycle` Meta-Argument

## What is the `lifecycle` Meta-Argument?

The **`lifecycle` meta-argument** allows you to customize how Terraform manages the **creation, updating, and destruction behavior** of resources.

By default, Terraform follows its own rules:

* Create resources
* Update resources when possible
* Destroy resources when needed

However, in real-world environments, some resources require special handling.

Examples:

* Production databases should never accidentally be deleted.
* A load balancer should not have downtime during replacement.
* Some values are managed outside Terraform and Terraform should ignore those changes.

The `lifecycle` block gives you control over these behaviors.

---

# Basic Syntax

```hcl
resource "resource_type" "resource_name" {

  # Resource configuration


  lifecycle {

    argument = value

  }

}
```

Example:

```hcl
resource "aws_instance" "server" {

  ami           = "ami-123456"

  instance_type = "t2.micro"


  lifecycle {

    prevent_destroy = true

  }

}
```

---

# Lifecycle Rules

Terraform provides three main lifecycle rules:

1. `create_before_destroy`
2. `prevent_destroy`
3. `ignore_changes`

---

# 1. create_before_destroy

## What does it do?

By default, when Terraform needs to replace a resource, it follows this order:

```
Destroy old resource

↓

Create new resource
```

This can cause downtime.

With:

```hcl
create_before_destroy = true
```

you tell Terraform:

> "Create the new resource first, make sure it works, then remove the old resource."

The order becomes:

```
Create new resource

↓

Switch traffic

↓

Destroy old resource
```

---

# Why is this needed?

Some resources cannot be updated in-place.

Terraform might need to replace them.

Example:

You have an EC2 instance:

```hcl
resource "aws_instance" "web" {

  ami = "ami-old"

}
```

Later you change:

```hcl
resource "aws_instance" "web" {

  ami = "ami-new"

}
```

The AMI cannot be changed on an existing EC2 instance.

Terraform must:

1. Destroy old EC2
2. Create new EC2

Without lifecycle:

```
Old EC2

↓

Destroyed

↓

New EC2 created
```

Your application has downtime.

---

## Using create_before_destroy

```hcl
resource "aws_instance" "web" {

  ami = "ami-new"

  instance_type = "t2.micro"


  lifecycle {

    create_before_destroy = true

  }

}
```

Now Terraform does:

```
Old EC2 running

↓

Create new EC2

↓

Verify new EC2

↓

Remove old EC2
```

Your application stays available.

---

# Real World Example: Load Balancer

Imagine Amazon.com.

You have:

```
Users

↓

Load Balancer

↓

EC2/ECS
```

You update the load balancer configuration.

Without:

```hcl
create_before_destroy = true
```

Terraform might:

```
Delete Load Balancer

↓

Create New Load Balancer
```

During this time:

```
Users cannot access website
```

With:

```hcl
lifecycle {

 create_before_destroy = true

}
```

Terraform:

```
Create new Load Balancer

↓

Move traffic

↓

Delete old Load Balancer
```

No downtime.

---

# Important Note

`create_before_destroy` does not always work.

Some resources cannot have two copies at the same time.

Example:

A resource requiring a unique name:

```
database-prod
```

Terraform cannot create:

```
database-prod
database-prod
```

because the name already exists.

---

# 2. prevent_destroy

## What does it do?

`prevent_destroy` protects important resources from accidental deletion.

Example:

Production database:

```
Customer Data

Payment Information

Orders

Users
```

You do not want someone running:

```bash
terraform destroy
```

and deleting everything.

---

## Example

```hcl
resource "aws_db_instance" "production_database" {

  engine = "mysql"

  allocated_storage = 100


  lifecycle {

    prevent_destroy = true

  }

}
```

Now if someone runs:

```bash
terraform destroy
```

Terraform stops:

```
Error:

Resource cannot be destroyed

because lifecycle.prevent_destroy is set to true
```

---

# Real World Example

Company infrastructure:

```
Production Environment

├── VPC
├── ECS
├── Load Balancer
└── RDS Database
```

You may protect:

```
RDS Database
S3 Bucket
DynamoDB Tables
```

because losing them means losing business data.

---

# Important Notes

`prevent_destroy` does not prevent:

* Manual deletion from AWS Console
* Deletion outside Terraform

It only protects against Terraform destroying the resource.

Example:

Someone goes to AWS Console:

```
RDS
→ Delete Database
```

Terraform cannot stop that.

---

# 3. ignore_changes

## What does it do?

Sometimes resources are managed by both:

* Terraform
* Another system/person

Terraform normally expects the real infrastructure to exactly match your `.tf` files.

If something changes outside Terraform:

Terraform detects drift.

Example:

Terraform says:

```hcl
instance_type = "t2.micro"
```

Someone manually changes AWS:

```
t2.micro

↓

t2.large
```

Terraform plan shows:

```
Change t2.large back to t2.micro
```

But sometimes you do not want Terraform to manage that field.

That is when you use:

```hcl
ignore_changes
```

---

# Example

```hcl
resource "aws_instance" "server" {

  ami = "ami-123456"

  tags = {

    Name = "web-server"

  }


  lifecycle {

    ignore_changes = [

      tags

    ]

  }

}
```

Now Terraform ignores tag changes.

If someone changes:

```
Name = web-server

↓

Name = production-server
```

Terraform does not try to change it back.

---

# Ignore Specific Attributes

Example:

```hcl
lifecycle {

  ignore_changes = [

    instance_type

  ]

}
```

Terraform ignores:

```hcl
instance_type
```

but manages everything else.

---

# Ignore All Changes

You can also do:

```hcl
lifecycle {

  ignore_changes = all

}
```

Meaning:

Terraform creates the resource but ignores every future change.

Example:

```hcl
resource "aws_instance" "server" {

  ami = "ami-123456"


  lifecycle {

    ignore_changes = all

  }

}
```

Terraform will:

Create it:

YES

Update it:

NO

Destroy it:

YES (unless prevent_destroy)

---

# Real World Example: Auto Scaling

Imagine ECS or Auto Scaling changes the number of servers automatically.

Terraform:

```
desired_capacity = 3
```

During high traffic:

Auto Scaling:

```
3 instances

↓

10 instances
```

Terraform sees:

```
Difference detected
```

Normally Terraform would reduce it back to 3.

But that would break autoscaling.

So:

```hcl
lifecycle {

  ignore_changes = [

    desired_capacity

  ]

}
```

Now:

Terraform manages the configuration.

Auto Scaling manages the scaling.

---

# Combining Lifecycle Rules

You can use multiple lifecycle rules together.

Example:

```hcl
resource "aws_db_instance" "database" {

  engine = "mysql"


  lifecycle {

    prevent_destroy = true

    create_before_destroy = true

    ignore_changes = [

      backup_retention_period

    ]

  }

}
```

Meaning:

1. Never delete the database accidentally.
2. Create replacement before removing old one.
3. Ignore backup retention changes.

---

# Lifecycle and Terraform State

Lifecycle rules do not change the resource itself.

They change how Terraform interacts with the resource.

Terraform still:

* Tracks the resource in state
* Manages dependencies
* Compares desired state vs real state

Lifecycle only changes Terraform's behavior.

---

# When To Use Each Lifecycle Rule

## create_before_destroy

Use when:

* Downtime is unacceptable
* Resource replacement is required
* High availability is important

Examples:

* Load balancers
* Web servers
* ECS services

---

## prevent_destroy

Use when:

* Data loss would be dangerous

Examples:

* RDS databases
* S3 buckets
* DynamoDB tables
* Production infrastructure

---

## ignore_changes

Use when:

* Another system manages part of the resource

Examples:

* Auto Scaling
* External tagging systems
* Security tools
* CI/CD systems

---

# Important Best Practices

## Do Not Overuse ignore_changes

Bad:

```hcl
ignore_changes = all
```

on everything.

Why?

Terraform loses control of the infrastructure.

---

## Protect Critical Resources

Production:

```hcl
prevent_destroy = true
```

is commonly used for:

* Databases
* Storage
* Important networking components

---

## Use create_before_destroy Carefully

It may increase cost because temporarily you have:

```
Old resource

+

New resource
```

running together.

---

# Simple Way To Remember

## create_before_destroy

"Build the replacement first, then remove the old one."

```
NEW → OLD DELETE
```

---

## prevent_destroy

"Terraform, never delete this."

```
DELETE ❌
```

---

## ignore_changes

"Terraform, don't care if this part changes."

```
Ignore this field
```

---

# Key Points

* `lifecycle` controls Terraform's default resource behavior.
* It is written inside a resource block.
* `create_before_destroy` prevents downtime by creating replacements first.
* `prevent_destroy` protects critical resources from Terraform deletion.
* `ignore_changes` allows Terraform to ignore selected external modifications.
* Lifecycle rules do not create resources; they only modify Terraform's management behavior.
* These features are heavily used in production environments to make infrastructure safer and more reliable.
