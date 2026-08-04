# Never Commit Secrets to Version Control

## Overview

One of the most common security mistakes in Terraform is accidentally committing secrets into a Git repository.

Examples of secrets:

* Database passwords
* API keys
* AWS access keys
* Private keys
* Tokens
* Certificates
* Cloud credentials

The main rule:

> **Never store secrets inside your Terraform code or commit them to version control.**

---

# The Problem With Committing Secrets

Imagine you create a Terraform variable file:

```hcl
# terraform.tfvars

db_password = "MySecretPassword123"
```

Then you commit:

```bash
git add .
git commit -m "Add terraform configuration"
git push
```

Now the secret exists in GitHub/GitLab/Bitbucket.

The problem:

Even if you delete the file later:

```bash
git rm terraform.tfvars

git commit -m "Remove secret"
```

The secret is still available in Git history.

---

# Why Deleting the File Does Not Fix It

Git does not only store the current version.

Git stores the complete history of changes.

Example:

```
Commit 1
 |
 |-- terraform.tfvars
 |      |
 |      password="Secret123"
 |
Commit 2
 |
 |-- file deleted
 |
Commit 3
 |
 |-- updated code
```

The password still exists in:

```
Commit 1
```

Anyone who has repository history can find it.

Example:

```bash
git log
```

or:

```bash
git checkout <old-commit>
```

They can recover the deleted file.

---

# Why This Is Dangerous

If an attacker gets your Git repository:

They may find:

```
AWS Access Key
Database Password
API Token
Private SSH Key
```

They can use those credentials to:

* Access cloud resources
* Read databases
* Create expensive resources
* Delete infrastructure
* Steal data

---

# The Correct Approach: Environment Variables

Instead of storing secrets in Terraform files, provide them through environment variables.

Terraform automatically understands variables with this format:

```
TF_VAR_<variable_name>
```

---

# Example

## Terraform Variable

variables.tf:

```hcl
variable "db_password" {

  description = "Database password"

  type = string

}
```

Notice:

There is no default value.

Why?

Because the value will come from the environment.

---

## Set Environment Variable

Linux/Mac:

```bash
export TF_VAR_db_password="MySecretPassword123"
```

Terraform automatically sees:

```
TF_VAR_
      |
      ↓
Terraform variable
      |
      ↓
db_password
```

Terraform internally receives:

```
db_password = MySecretPassword123
```

---

# How Terraform Matches Variables

Terraform follows this rule:

Environment variable:

```
TF_VAR_variable_name
```

Terraform variable:

```hcl
variable "variable_name"
```

Example:

Environment:

```bash
export TF_VAR_region="us-east-1"
```

Terraform:

```hcl
variable "region" {

 type = string

}
```

Terraform connects them automatically.

---

# Complete Example

## variables.tf

```hcl
variable "database_password" {

  description = "RDS database password"

  type = string

  sensitive = true

}
```

---

## main.tf

```hcl
resource "aws_db_instance" "database" {

  engine = "mysql"

  username = "admin"

  password = var.database_password

}
```

---

## Terminal

```bash
export TF_VAR_database_password="Password123"
```

Run:

```bash
terraform plan
```

Terraform uses the password.

No password exists inside:

```
main.tf
variables.tf
terraform.tfvars
Git repository
```

---

# Why Environment Variables Are Better

## Before:

```
Terraform Project

├── main.tf
├── variables.tf
└── terraform.tfvars

        |
        ↓

Password stored in Git ❌
```

---

## After:

```
Terraform Project

├── main.tf
├── variables.tf

        |
        ↓

Environment Variable

TF_VAR_db_password

        |
        ↓

Terraform
```

The secret exists only in the user's environment.

---

# Important: Environment Variables Do NOT Protect Terraform State

A common misunderstanding:

> "If I use environment variables, my password is completely safe."

Not true.

Environment variables only prevent storing secrets in code.

The flow is:

```
Environment Variable

        ↓

Terraform

        ↓

AWS Resource

        ↓

Terraform State File
```

Terraform still needs to track the resource.

Example:

```
terraform.tfstate
```

may contain:

```json
{
  "password": "MySecretPassword123"
}
```

---

# Environment Variables Solve One Problem

They protect:

✅ Git repositories
✅ Terraform files
✅ Code sharing
✅ Accidental commits

---

# Environment Variables Do NOT Solve

They do not protect:

❌ Terraform state files
❌ Terraform logs
❌ Terraform plan files
❌ Someone with access to your machine
❌ Someone with access to remote state

---

# Protecting the State File

Because state may contain secrets:

## Local State

Example:

```
terraform.tfstate
```

Risk:

* Laptop access
* Accidental upload
* No team control

---

## Remote State

Production teams use:

AWS S3 backend:

```hcl
terraform {

 backend "s3" {

   bucket = "company-terraform-state"

   key = "prod/state.tfstate"

   region = "us-east-1"

 }

}
```

With:

* Encryption
* IAM permissions
* Versioning
* State locking

---

# Production Secret Management

Large companies usually do not rely only on environment variables.

They use:

* AWS Secrets Manager
* HashiCorp Vault
* AWS Parameter Store
* Azure Key Vault

Architecture:

```
Secret Manager

      ↓

Terraform

      ↓

AWS Resources
```

The secret is retrieved when needed.

---

# Best Practices

## Never:

❌ Put passwords in `.tf` files
❌ Put secrets in `.tfvars` committed to Git
❌ Commit `terraform.tfstate`
❌ Assume deleting a file removes it from Git history

---

## Always:

✅ Use environment variables

Example:

```bash
export TF_VAR_db_password="password"
```

---

✅ Mark sensitive values

```hcl
sensitive = true
```

---

✅ Protect state files

Use:

* Remote backend
* Encryption
* IAM controls
* State locking

---

✅ Rotate secrets if exposed

If a secret reaches Git:

1. Remove it from the repository
2. Clean Git history if needed
3. Immediately rotate the credential
4. Check cloud access logs

---

# Simple Way To Remember

Environment variables solve:

> "How do I stop secrets from being stored in my Terraform code?"

State protection solves:

> "How do I protect secrets Terraform already needs to remember?"

Secret managers solve:

> "How do I securely store and provide secrets in production?"

A secure Terraform setup uses all three.
