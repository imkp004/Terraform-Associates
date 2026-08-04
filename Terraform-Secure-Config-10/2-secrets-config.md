# Hiding Sensitive Values in Terraform

## Overview

Terraform often needs sensitive information to create infrastructure.

Examples:

* Database passwords
* API keys
* Tokens
* SSH private keys
* Cloud credentials
* Certificates

The problem is:

Terraform needs these values to create resources, but we do **not** want these values appearing in:

* Terminal output
* Terraform plan output
* Terraform apply output
* Logs
* Screenshots
* CI/CD pipelines

Terraform provides a feature called:

```hcl
sensitive = true
```

to reduce the exposure of sensitive values.

However, an important concept:

> `sensitive = true` does NOT encrypt or remove the secret. It only hides the value from Terraform CLI output.

The value may still exist in the Terraform state file.

---

# The Problem: Secrets Without Sensitive Protection

Imagine creating an RDS database.

Example:

```hcl
variable "db_password" {

  type = string

}
```

You provide:

```hcl
db_password = "MyPassword123"
```

Then use it:

```hcl
resource "aws_db_instance" "database" {

  engine = "mysql"

  username = "admin"

  password = var.db_password

}
```

Now run:

```bash
terraform plan
```

Terraform may show:

```
+ password = "MyPassword123"
```

Problem:

Anyone looking at:

* terminal output
* CI/CD logs
* screenshots
* shared terminal sessions

can see the password.

---

# Solution: Sensitive Variables

You can mark the variable as sensitive.

Example:

```hcl
variable "db_password" {

  type = string

  sensitive = true

}
```

Now Terraform knows:

> "This value should not be displayed."

---

When running:

```bash
terraform plan
```

Instead of:

```
password = "MyPassword123"
```

Terraform shows:

```
password = (sensitive value)
```

or:

```
<sensitive>
```

The actual password is hidden.

---

# How Sensitive Variables Work

The flow:

```
User provides password

        ↓

Terraform variable

        ↓

sensitive = true

        ↓

Terraform hides it in CLI output

        ↓

Resource receives the real password
```

Important:

Terraform still uses the real value.

The resource creation works normally.

Only the display changes.

---

# Example: Complete Sensitive Variable

## variables.tf

```hcl
variable "database_password" {

  description = "Password for database"

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

## terraform.tfvars

```hcl
database_password = "SuperSecretPassword123"
```

Run:

```bash
terraform plan
```

Output:

```
password = (sensitive value)
```

The password is hidden.

---

# Sensitive Outputs

The same concept applies to output blocks.

Imagine:

```hcl
output "database_password" {

  value = aws_db_instance.database.password

}
```

After:

```bash
terraform apply
```

Terraform might display:

```
database_password = SuperSecretPassword123
```

This is dangerous.

---

Use:

```hcl
output "database_password" {

  value = aws_db_instance.database.password

  sensitive = true

}
```

Now:

```
database_password = <sensitive>
```

---

# Important: Sensitive Does Not Mean Encrypted

Many beginners misunderstand this.

They think:

```
sensitive = true

means

password is encrypted
```

That is FALSE.

It only means:

```
Hide from display
```

It does NOT:

* Encrypt the state file
* Remove the value from memory
* Remove the value from Terraform state
* Prevent someone with state access from seeing it

---

# Terraform State Still Contains Secrets

Example:

You create:

```hcl
resource "aws_db_instance" "database" {

 password = var.database_password

}
```

Terraform stores information in:

```
terraform.tfstate
```

The state may contain:

```json
{
 "password": "SuperSecretPassword123"
}
```

Even if:

```hcl
sensitive = true
```

is used.

Why?

Because Terraform needs the information to:

* Compare current infrastructure
* Detect changes
* Update resources
* Manage lifecycle

---

# Example Understanding

Think of sensitive like putting a cover over something.

Without sensitive:

```
Password

VISIBLE
```

With sensitive:

```
Password

[Covered]
```

But:

```
The password still exists underneath.
```

---

# What Sensitive Protects Against

`sensitive = true` protects against:

✅ Accidental terminal exposure

Example:

```
terraform apply
```

Output:

```
password=<sensitive>
```

---

✅ CI/CD log exposure

Example:

GitHub Actions:

```
Terraform Apply Output
```

The password will not appear.

---

✅ Accidental screenshots

Example:

Developer shares terminal screenshot.

The secret is hidden.

---

# What Sensitive Does NOT Protect Against

It does NOT protect against:

❌ Someone with access to Terraform state

Example:

Someone runs:

```bash
terraform show terraform.tfstate
```

They may see sensitive information.

---

❌ Someone with cloud access

Example:

AWS administrator can view the database configuration.

---

❌ Someone with access to your variables file

Example:

```
terraform.tfvars
```

contains:

```hcl
password="secret123"
```

---

# Environment Variables

Another way to avoid storing secrets in Terraform files is using environment variables.

Terraform automatically reads variables starting with:

```
TF_VAR_
```

Format:

```
TF_VAR_<variable_name>
```

---

Example:

Terraform variable:

```hcl
variable "db_password" {

 type = string

 sensitive = true

}
```

Environment variable:

Linux/Mac:

```bash
export TF_VAR_db_password="MyPassword123"
```

Terraform automatically receives:

```
db_password = MyPassword123
```

---

Now your code does not contain:

```hcl
password="MyPassword123"
```

The secret exists only in the environment.

---

# Why Environment Variables Are Better

Your Git repository:

Before:

```
project/

├── main.tf
├── variables.tf
└── terraform.tfvars   ❌
```

The password exists in the repository.

---

After:

```
project/

├── main.tf
├── variables.tf
└── no secrets
```

Secret exists:

```
Developer Environment

or

CI/CD Secret Store
```

---

# Example CI/CD Usage

A company uses GitHub Actions.

The secret is stored in:

```
GitHub Secrets
```

Example:

```
AWS_ACCESS_KEY
DB_PASSWORD
API_TOKEN
```

Pipeline:

```
GitHub Secret

      ↓

Environment Variable

      ↓

Terraform

      ↓

AWS
```

The secret never exists in the Terraform code.

---

# Best Practice: Store Secrets Outside Terraform

For production environments, the best approach is:

> Terraform should retrieve secrets when needed, not store them permanently.

Common secret management systems:

* AWS Secrets Manager
* HashiCorp Vault
* AWS Parameter Store
* Azure Key Vault
* Google Secret Manager

---

# Example: AWS Secrets Manager

Architecture:

```
AWS Secrets Manager

        |
        |
        ↓

Terraform

        |
        |
        ↓

RDS Database
```

Terraform retrieves:

```
database password
```

when needed.

---

Example:

```hcl
data "aws_secretsmanager_secret_version" "db_password" {

 secret_id = "production/database/password"

}
```

Then:

```hcl
resource "aws_db_instance" "database" {

 password =
 data.aws_secretsmanager_secret_version.db_password.secret_string

}
```

The password is not written in:

* Terraform files
* Git
* tfvars files

---

# Sensitive Variable vs External Secret Management

| Method                      | Security Level         |
| --------------------------- | ---------------------- |
| Hardcoded password          | ❌ Very bad             |
| terraform.tfvars            | ⚠️ Better but risky    |
| Sensitive variable          | ✅ Hides output         |
| Environment variable        | ✅ Better               |
| AWS Secrets Manager / Vault | ✅✅ Best for production |

---

# Real Production Pattern

A company usually does:

```
Developer

     |

Git Repository
(no secrets)

     |

Terraform

     |

IAM Role

     |

Secrets Manager

     |

Infrastructure

     |

Encrypted Remote State
```

---

# Important Best Practices

## 1. Always mark sensitive values

Example:

```hcl
variable "api_key" {

 type = string

 sensitive = true

}
```

---

## 2. Never hardcode secrets

Bad:

```hcl
password="123456"
```

---

## 3. Do not commit secret files

Add to `.gitignore`:

```
terraform.tfvars
*.tfstate
*.tfstate.backup
```

---

## 4. Encrypt remote state

Example:

AWS S3:

* Server-side encryption
* IAM permissions
* Versioning
* State locking

---

## 5. Use secret managers in production

Terraform should consume secrets, not become the permanent storage location.

---

# Simple Memory Trick

## `sensitive = true`

Means:

> "Terraform, hide this value when showing output."

It does NOT mean:

> "Terraform, encrypt and remove this value."

---

## Best Security Approach

```
Do not store secrets

        ↓

Use secret managers

        ↓

Use environment variables

        ↓

Use sensitive=true

        ↓

Protect state files
```

---

# Final Key Points

* Secrets are required by Terraform but must be protected.
* `sensitive = true` hides values from CLI output and logs.
* Sensitive values can still exist inside Terraform state.
* Sensitive variables work inside variable blocks.
* Sensitive outputs work inside output blocks.
* Environment variables prevent secrets from being stored in Terraform code.
* Production environments should use dedicated secret management systems.
* Protecting Terraform state is one of the most important security responsibilities.
