# Storing Secrets Externally

## Overview

One of the best practices in Terraform is **not storing secrets inside your Terraform project at all**.

Instead of putting passwords, API keys, or tokens inside:

* `.tf` files
* `.tfvars` files
* Environment variables

you can store them in a **dedicated secrets management service** and let Terraform retrieve them only when needed.

For AWS, the most common service is **AWS Secrets Manager**.

The idea is simple:

> Terraform does not own the secrets. It simply asks a trusted service for the secret when it needs it to provision infrastructure.

This greatly improves security and makes secret management much easier.

---

# Why Store Secrets Externally?

Imagine you have a database password.

Without a secrets manager:

```text
Terraform Code

↓

Database Password
```

The password may exist in:

* `.tf` files
* `.tfvars`
* Environment variables
* Git (if someone accidentally commits it)

---

With a secrets manager:

```text
AWS Secrets Manager

↓

Terraform

↓

AWS Resource
```

Terraform retrieves the secret only when it needs it.

The secret is managed separately from your infrastructure code.

---

# Benefits of External Secret Management

## 1. Secrets Are Managed by a Dedicated Tool

Terraform is an Infrastructure as Code (IaC) tool.

It is designed to:

* Create infrastructure
* Update infrastructure
* Destroy infrastructure

It is **not designed to be a secure password vault**.

Services like AWS Secrets Manager are specifically built for storing sensitive information.

This separation of responsibilities makes your infrastructure more secure.

---

## 2. Centralized Secret Storage

Instead of secrets being scattered across different projects:

```text
Project A

password.txt

Project B

terraform.tfvars

Project C

.env
```

everything is stored in one secure location.

Example:

```text
AWS Secrets Manager

├── production/database
├── production/api
├── dev/database
├── test/database
```

Now every application and Terraform configuration can retrieve secrets from the same place.

Benefits:

* Easier management
* Easier auditing
* Easier updates
* Consistent security

---

## 3. Secret Rotation

Passwords should not stay the same forever.

Over time they should be changed (rotated).

Example:

Old password:

```text
Database123
```

New password:

```text
SecurePassword2026!
```

AWS Secrets Manager can automatically rotate supported secrets.

Instead of manually changing passwords on every server and application:

```text
Administrator

↓

Changes password once

↓

Secrets Manager updates it

↓

Applications retrieve the new secret
```

Terraform does not need to know what the password changed to.

It simply retrieves the current version.

---

## 4. No Secrets in Terraform Code

Instead of writing:

```hcl
variable "db_password" {
  default = "MyPassword123"
}
```

or

```hcl
password = "MyPassword123"
```

you simply retrieve the secret.

Your Terraform files never contain the actual password.

If someone opens your Git repository, they will not see any passwords.

---

# Using a Data Block to Retrieve Secrets

Terraform uses a **data block** to retrieve existing information from a provider.

AWS Secrets Manager already contains the secret.

Terraform simply reads it.

Example:

```hcl
data "aws_secretsmanager_secret_version" "database_password" {
  secret_id = "production/database/password"
}
```

Explanation:

* `data` → We are reading existing information.
* `aws_secretsmanager_secret_version` → Read the latest version of a secret from AWS Secrets Manager.
* `database_password` → Local Terraform name used for referencing.
* `secret_id` → The name (or ARN) of the secret stored in AWS Secrets Manager.

Terraform contacts AWS and retrieves the latest value.

---

# Using the Secret During Resource Creation

After retrieving the secret, it can be used just like any other Terraform value.

Example:

```hcl
resource "aws_db_instance" "database" {

  engine   = "mysql"
  username = "admin"

  password = data.aws_secretsmanager_secret_version.database_password.secret_string

}
```

How Terraform processes this:

```text
Terraform

↓

Read secret from AWS Secrets Manager

↓

Receives password

↓

Creates the RDS database

↓

Uses the password
```

No password is written directly in your Terraform configuration.

---

# Resource Referencing

Notice this line:

```hcl
data.aws_secretsmanager_secret_version.database_password.secret_string
```

Let's break it down.

```text
data
```

We are referencing a data block.

```text
aws_secretsmanager_secret_version
```

The type of data source.

```text
database_password
```

The local Terraform name.

```text
secret_string
```

The attribute containing the actual secret value.

The format is:

```text
data.<data_type>.<local_name>.<attribute>
```

Exactly the same idea as resource referencing:

```text
resource.<type>.<name>.<attribute>
```

---

# Does This Keep Secrets Out of the State File?

This is one of the biggest beginner questions.

The answer is:

**No—not necessarily.**

Terraform still needs to manage the infrastructure it creates.

Because of that, some secrets may still end up in the Terraform state file.

Example:

```text
AWS Secrets Manager

↓

Terraform

↓

terraform.tfstate

↓

AWS RDS
```

The password is no longer in your Terraform code, but Terraform may still store it in the state if it is required to manage that resource.

So using AWS Secrets Manager does **not automatically eliminate secrets from the state file**.

---

# Why Does Terraform Store Secrets in State?

Terraform must compare:

* The desired configuration
* The current infrastructure
* The last known state

Without this information Terraform would not know:

* Whether something changed
* Whether a resource needs updating
* Whether the infrastructure matches the configuration

The state file is Terraform's memory, so some sensitive values may still be stored there.

---

# How Do We Protect the State File?

Since the state file may contain secrets, protecting it is extremely important.

Production teams typically:

* Store state in an encrypted S3 bucket.
* Restrict access using IAM policies.
* Enable versioning.
* Use state locking (usually with DynamoDB or the backend's locking mechanism).
* Allow only trusted engineers and automation pipelines to access the state.

The goal is:

> Even if Terraform stores sensitive information, only authorized users should be able to access it.

---

# Complete Workflow

```text
Developer

      │

      ▼

Terraform Configuration
(No passwords)

      │

      ▼

AWS Secrets Manager

      │

Retrieve Secret

      ▼

Terraform

      │

Creates Resource

      ▼

AWS Infrastructure

      │

Updates State File
```

The password never appears in:

* `.tf` files
* `.tfvars` files
* Git repositories

The only sensitive locations are:

* AWS Secrets Manager (where it is meant to live)
* Terraform state (which must be protected)

---

# Best Practices

✅ Store secrets in AWS Secrets Manager or another dedicated secrets manager.

✅ Retrieve secrets using Terraform data blocks.

✅ Never hardcode passwords in Terraform code.

✅ Never commit secrets to Git.

✅ Restrict access to the Terraform state file using IAM permissions.

✅ Encrypt remote state.

✅ Rotate secrets regularly.

✅ Grant Terraform only the permissions it needs to read specific secrets.

---

# Simple Way to Remember

There are three common ways to provide secrets to Terraform:

| Method                | Secrets in Code? | Secrets in Git? | Secrets in State? | Recommended            |
| --------------------- | ---------------- | --------------- | ----------------- | ---------------------- |
| Hardcoded values      | Yes              | Yes             | Yes               | ❌ Never                |
| Environment variables | No               | No              | Usually Yes       | ✅ Good                 |
| AWS Secrets Manager   | No               | No              | Possibly Yes      | ✅✅ Best for production |

The key idea is:

> **External secret managers protect your Terraform code and version control by keeping secrets in a dedicated, secure service. However, because Terraform needs certain values to manage infrastructure, those values may still appear in the Terraform state file. This is why securing the state file with encryption, access controls, and a remote backend is just as important as protecting the secrets themselves.**
