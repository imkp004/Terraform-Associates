# Terraform Validation Workflow

Terraform validation is the process of making sure your infrastructure code is **correct, safe, and follows your expected rules before making real changes in the cloud**.

Terraform has multiple layers of validation:

1. **Syntax and configuration validation**
2. **Variable validation**
3. **Resource preconditions**
4. **Resource postconditions**
5. **Check blocks**

Each layer catches different types of problems.

---

# Terraform Validation Flow

A typical Terraform workflow:

```
terraform init

        ↓

terraform validate

        ↓

terraform plan

        ↓

terraform apply
```

But validation can happen at different levels:

```
Configuration
      |
      |
      ↓
Variable Validation
      |
      |
      ↓
Resource Preconditions
      |
      |
      ↓
Resource Creation
      |
      |
      ↓
Resource Postconditions
      |
      |
      ↓
Check Blocks
```

---

# 1. terraform validate

Before understanding the advanced validation, remember:

```bash
terraform validate
```

checks:

* Terraform syntax
* Correct HCL structure
* Valid resource arguments
* Correct block structure
* References to existing resources

Example:

Wrong:

```hcl
resource "aws_instance" "server" {

 ami = "ami-123"

 instance_type = t2.micro

}
```

Problem:

```hcl
instance_type = t2.micro
```

Terraform thinks:

`t2.micro`

is a variable, not a string.

Correct:

```hcl
instance_type = "t2.micro"
```

Running:

```bash
terraform validate
```

will catch this.

---

# Important Limitation of terraform validate

`terraform validate` does NOT check:

* Whether the AMI exists
* Whether the AWS region is correct
* Whether you have permissions
* Whether the resource can actually be created

Why?

Because it does not contact AWS.

It only checks your Terraform code.

---

# 2. Variable Validation

## What is Variable Validation?

Variables allow users to provide values.

Example:

```hcl
variable "environment" {

  type = string

}
```

Someone can enter:

```
production
```

or:

```
banana
```

Terraform does not know if the value makes sense.

Variable validation allows us to create rules.

It says:

> "Only allow values that match my requirements."

---

# Syntax

```hcl
variable "name" {

  type = string


  validation {

    condition = expression

    error_message = "message"

  }

}
```

---

# Example 1: Environment Validation

Without validation:

```hcl
variable "environment" {

  type = string

}
```

Allowed:

```
dev
test
prod
banana
hello
anything
```

---

With validation:

```hcl
variable "environment" {

  type = string


  validation {

    condition = contains(
      ["dev", "test", "prod"],
      var.environment
    )


    error_message = "Environment must be dev, test, or prod."

  }

}
```

Now:

Allowed:

```
dev
test
prod
```

Rejected:

```
development
production
random
```

---

# How It Works

Example:

```hcl
environment = "prod"
```

Terraform checks:

```hcl
contains(
["dev","test","prod"],
"prod"
)
```

Result:

```
true
```

Terraform continues.

---

Example:

```hcl
environment = "banana"
```

Result:

```
false
```

Terraform stops:

```
Error:
Environment must be dev, test, or prod.
```

---

# Example 2: Instance Type Validation

```hcl
variable "instance_type" {

  type = string


  validation {

    condition = contains(
      [
        "t2.micro",
        "t3.micro",
        "t3.small"
      ],
      var.instance_type
    )


    error_message = "Unsupported instance type."

  }

}
```

This prevents users from creating expensive instances accidentally.

---

# Example 3: Number Validation

Example:

You want at least 2 servers.

```hcl
variable "server_count" {

  type = number


  validation {

    condition = var.server_count >= 2


    error_message = "Server count must be at least 2."

  }

}
```

Input:

```
server_count = 1
```

Result:

```
FAILED
```

---

# Why Variable Validation is Important

It prevents:

* Wrong values
* Typing mistakes
* Bad deployments
* Expensive mistakes

Used heavily in:

* Production environments
* Shared Terraform modules
* Enterprise projects

---

# 3. Preconditions

## What are Preconditions?

A precondition checks something **before Terraform creates or updates a resource**.

It answers:

> "Before creating this resource, are the requirements satisfied?"

---

Example:

You want an EC2 instance only in a specific region.

Terraform should check first.

---

# Syntax

Inside resource:

```hcl
resource "resource_type" "name" {


 lifecycle {

    precondition {

      condition = expression

      error_message = "message"

    }

 }

}
```

---

# Example: EC2 Instance Type Check

```hcl
resource "aws_instance" "server" {


  ami = "ami-123456"

  instance_type = var.instance_type


  lifecycle {

    precondition {

      condition = contains(
        [
          "t2.micro",
          "t3.micro"
        ],
        var.instance_type
      )


      error_message =
      "Only approved instance types are allowed."

    }

  }

}
```

---

If:

```hcl
instance_type = "t3.micro"
```

Terraform continues.

---

If:

```hcl
instance_type = "m5.24xlarge"
```

Terraform stops.

---

# Real Production Example

Company policy:

```
Production databases must have encryption enabled.
```

Terraform:

```hcl
resource "aws_db_instance" "database" {


 storage_encrypted = var.encrypted


 lifecycle {

   precondition {

     condition = var.encrypted == true


     error_message =
     "Production databases must use encryption."

   }

 }

}
```

---

# Variable Validation vs Preconditions

## Variable Validation

Checks input values.

Example:

```
Is environment name valid?
```

---

## Preconditions

Checks resource requirements.

Example:

```
Can this resource safely be created?
```

---

# 4. Postconditions

## What are Postconditions?

Postconditions check something **after Terraform creates or updates a resource**.

It answers:

> "After creating this resource, did it become what I expected?"

---

# Syntax

```hcl
resource "resource_type" "name" {


 lifecycle {

   postcondition {

     condition = expression

     error_message = "message"

   }

 }

}
```

---

# Example: Verify EC2 Public IP

```hcl
resource "aws_instance" "server" {


 ami = "ami-123456"


 instance_type = "t2.micro"


 lifecycle {

   postcondition {

     condition = self.public_ip != ""


     error_message =
     "Instance does not have a public IP."

   }

 }

}
```

---

Terraform creates EC2.

Then checks:

```
Does it have public IP?
```

If:

```
YES
```

continue.

If:

```
NO
```

Terraform reports failure.

---

# Why Postconditions Matter

They verify:

* Resource was created correctly
* Cloud provider returned expected values
* Security requirements are met

---

# Real Example: S3 Bucket Encryption

After creating bucket:

Check:

```
Is encryption enabled?
```

If not:

```
Fail deployment
```

---

# 5. Check Blocks

## What are Check Blocks?

Check blocks are used for **general health checks**.

Unlike preconditions and postconditions:

* They do not stop deployment by default
* They monitor and warn you

They are used for continuous validation.

---

# Syntax

```hcl
check "name" {


  data "resource" {

  }


  assert {

    condition = expression

    error_message = "message"

  }

}
```

---

# Example: Check S3 Bucket Exists

```hcl
check "bucket_check" {


  assert {

    condition =
    aws_s3_bucket.demo.id != ""


    error_message =
    "S3 bucket was not created."

  }

}
```

---

# Example: Security Check

Company rule:

```
All S3 buckets must not be public.
```

```hcl
check "s3_security" {


 assert {

   condition =
   aws_s3_bucket.demo.acl != "public-read"


   error_message =
   "S3 bucket is publicly accessible."

 }

}
```

---

# Difference Between All Validation Methods

| Feature             | When It Runs                | Purpose              |
| ------------------- | --------------------------- | -------------------- |
| terraform validate  | Before plan                 | Check Terraform code |
| Variable validation | When variables are provided | Check input values   |
| Preconditions       | Before resource creation    | Check requirements   |
| Postconditions      | After resource creation     | Verify results       |
| Check blocks        | During plan/apply           | Monitor conditions   |

---

# Complete Example

```hcl
variable "environment" {

 type = string


 validation {

   condition =
   contains(
    ["dev","prod"],
    var.environment
   )


   error_message =
   "Environment must be dev or prod."

 }

}



resource "aws_instance" "server" {


 instance_type = "t2.micro"


 ami = "ami-123456"


 lifecycle {


   precondition {

    condition =
    var.environment == "prod"


    error_message =
    "Server only allowed in production."

   }


   postcondition {

    condition =
    self.id != ""


    error_message =
    "Instance creation failed."

   }


 }

}
```

---

# Real-World Enterprise Terraform Validation Strategy

A company might use:

## Variable Validation

For:

* Allowed regions
* Environment names
* Instance sizes

## Preconditions

For:

* Security requirements
* Compliance rules
* Architecture rules

## Postconditions

For:

* Verify resources created correctly
* Ensure required outputs exist

## Check Blocks

For:

* Continuous monitoring
* Best-practice checks
* Security checks

---

# Simple Memory Trick

### Variable Validation

"Is the input allowed?"

```
User input
     ↓
Validation
```

---

### Precondition

"Can I create this safely?"

```
Before creation
```

---

### Postcondition

"Did creation succeed correctly?"

```
After creation
```

---

### Check Block

"Is everything healthy?"

```
Continuous check
```

---

# Key Points

* Terraform validation prevents bad infrastructure deployments.
* Validation happens at multiple stages.
* Variable validation protects against bad inputs.
* Preconditions protect resources before creation.
* Postconditions verify resources after creation.
* Check blocks provide ongoing infrastructure health checks.
* Enterprise Terraform projects heavily use these features for security, reliability, and compliance.
