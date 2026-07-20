# Terraform `validate`

## What is `terraform validate`?

`terraform validate` is a Terraform command used to **check whether your Terraform configuration files are written correctly**.

It checks:

* Terraform syntax
* Configuration structure
* Required arguments
* Correct use of Terraform blocks

It helps you find mistakes **before running `terraform plan` or `terraform apply`**.

Run:

```bash
terraform validate
```

---

# What Does `terraform validate` Check?

Terraform validate checks whether your `.tf` files are:

✅ Written using correct Terraform syntax
✅ Using valid Terraform blocks
✅ Using valid arguments inside resources
✅ Structured correctly

Think of it like a **grammar checker for Terraform code**.

---

# Example 1: Syntax Error

Incorrect Terraform:

```hcl
resource "aws_instance" "web" {

  ami = "ami-123456"

  instance_type = "t3.micro"

```

Notice:

The closing `}` is missing.

Run:

```bash
terraform validate
```

Output:

```text
Error: Missing closing brace

Expected a closing brace for this block.
```

Terraform catches this before you try to create anything.

---

# Example 2: Invalid Block Structure

Incorrect:

```hcl
aws_instance "web" {

  ami = "ami-123456"

}
```

Problem:

Terraform resources must start with:

```hcl
resource
```

Correct:

```hcl
resource "aws_instance" "web" {

  ami = "ami-123456"

}
```

`terraform validate` catches the incorrect structure.

---

# Example 3: Missing Required Argument

Incorrect:

```hcl
resource "aws_instance" "web" {

}
```

An AWS EC2 instance requires certain arguments.

Terraform validate may show:

```text
Error: Missing required argument

The argument "ami" is required.
```

---

# What Terraform Validate Does NOT Check

A very important point:

`terraform validate` is an **offline check**.

It does **not communicate with the cloud provider**.

It does not contact:

* AWS
* Azure
* Google Cloud
* GitHub

It only checks your Terraform code locally.

---

# Example: Validate Cannot Detect Everything

Suppose you write:

```hcl
resource "aws_instance" "web" {

  ami = "ami-does-not-exist"

  instance_type = "t3.micro"

}
```

Terraform validate may say:

```text
Success! The configuration is valid.
```

Why?

Because the syntax is correct.

Terraform does not know whether:

* The AMI exists.
* You have permission to use it.
* The region supports it.
* Your AWS credentials work.

Those checks happen later.

---

# Difference Between Validate and Plan

## terraform validate

Checks:

> "Is my Terraform code written correctly?"

Example:

```text
Is the HCL syntax correct?
Are blocks structured correctly?
```

It does not check AWS.

---

## terraform plan

Checks:

> "What will happen if I apply this configuration?"

It:

* Reads your state.
* Contacts the provider.
* Checks existing resources.
* Calculates changes.

---

# Example Workflow

The normal Terraform workflow is:

```text
Write Terraform Code
          |
          ▼
terraform init
          |
          ▼
terraform validate
          |
          ▼
terraform plan
          |
          ▼
terraform apply
          |
          ▼
terraform destroy
```

---

# Step 1: terraform init

Before validate, you normally run:

```bash
terraform init
```

Why?

Because Terraform needs:

* Provider plugins.
* Modules.
* Backend configuration.

Example:

```hcl
provider "aws" {

}
```

Terraform needs the AWS provider installed before it can fully understand your configuration.

---

# Step 2: terraform validate

After initialization:

```bash
terraform validate
```

Example successful output:

```text
Success! The configuration is valid.
```

---

# Step 3: terraform plan

Now Terraform can communicate with AWS:

```bash
terraform plan
```

It checks:

* Current infrastructure.
* Terraform state.
* Desired configuration.

Then shows the changes.

---

# Step 4: terraform apply

Apply the approved changes:

```bash
terraform apply
```

Terraform creates, updates, or deletes infrastructure.

---

# Step 5: terraform destroy

Remove managed infrastructure:

```bash
terraform destroy
```

---

# Does `terraform validate` Require `terraform init`?

Yes, usually.

You should initialize your Terraform directory first.

Example:

You create:

```text
terraform-project/

main.tf
variables.tf
outputs.tf
```

You immediately run:

```bash
terraform validate
```

You may get:

```text
Error: Missing provider plugin
```

because Terraform has not downloaded the required providers yet.

You should run:

```bash
terraform init
```

first.

Then:

```bash
terraform validate
```

---

# Why Is Validate Useful?

Without validate:

You write code:

```hcl
resource "aws_instance" "web" {

 instance_type = "t3.micro"

 ami = "ami-123"

```

Then you run:

```bash
terraform apply
```

Terraform starts processing and discovers the syntax problem.

You wasted time.

---

With validate:

```bash
terraform validate
```

You immediately find the problem.

Fix it.

Then continue.

---

# Common Errors Validate Finds

## Missing Brackets

```hcl
resource "aws_s3_bucket" "example" {

bucket = "mybucket"
```

Missing:

```hcl
}
```

---

## Typo in Terraform Keyword

Wrong:

```hcl
resorce "aws_instance" "web" {

}
```

Correct:

```hcl
resource "aws_instance" "web" {

}
```

---

## Incorrect Attribute Formatting

Wrong:

```hcl
instance_type = t3.micro
```

Correct:

```hcl
instance_type = "t3.micro"
```

---

# What Validate Does Not Find

Examples:

## Wrong AWS Region

```hcl
provider "aws" {

region = "wrong-region"

}
```

---

## Invalid AMI

```hcl
ami = "abc123"
```

---

## Permission Issues

Example:

Your AWS user does not have:

```text
ec2:CreateInstance
```

---

## Resource Already Exists

Example:

Trying to create:

```text
S3 bucket: my-company-bucket
```

when another account already owns it.

---

These require:

```bash
terraform plan
```

because Terraform needs to talk to AWS.

---

# Key Points to Remember

* `terraform validate` checks Terraform code correctness.
* It checks syntax and configuration structure.
* It is an offline command.
* It does not contact cloud providers.
* It should be run after `terraform init`.
* It helps catch mistakes before planning and applying.
* It cannot detect cloud-specific problems like permissions, missing resources, or incorrect IDs.
* The normal workflow is:

```text
init
 ↓
validate
 ↓
plan
 ↓
apply
 ↓
destroy
```

---

# Simple Explanation

Think of Terraform like writing a program:

* `terraform init` = Install the required libraries.
* `terraform validate` = Check if your code has grammar mistakes.
* `terraform plan` = Test what your program will do.
* `terraform apply` = Actually run the program and create infrastructure.
* `terraform destroy` = Remove what the program created.

`terraform validate` is your first safety check before Terraform starts talking to the real world.
