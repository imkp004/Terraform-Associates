# Terraform Secrets Management

## Why Are Secrets Important in Terraform?

Secrets are some of the **most critical pieces of information** in infrastructure management.

Examples of secrets:

* Database passwords
* API keys
* Cloud access keys
* Tokens
* SSH private keys
* Certificates
* Encryption keys
* Third-party service credentials
* Account IDs and sensitive identifiers

If these values are exposed, attackers could:

* Access your cloud environment
* Create or delete resources
* Steal data
* Increase cloud costs
* Access production systems

Because Terraform manages infrastructure, it often needs these secrets to authenticate and create resources.

The challenge is:

> Terraform needs access to secrets, but humans and unauthorized systems should not have access to them.

---

# Where Can Secrets Be Exposed in Terraform?

Secrets can accidentally appear in many places.

---

# 1. Terraform Configuration Files (`.tf`)

The biggest mistake is hardcoding secrets directly in Terraform files.

Bad example:

```hcl
provider "aws" {

  access_key = "AKIA123456789"

  secret_key = "my-secret-password"

}
```

Problem:

Anyone who can access the code can see the credentials.

If this code is pushed to GitHub:

```text
Developer
     |
     ↓
GitHub
     |
     ↓
Anyone with access
```

The secret is exposed.

---

# Better Approach

Use variables:

```hcl
variable "aws_secret_key" {

  type      = string

  sensitive = true

}
```

Then provide the value separately.

Example:

```hcl
provider "aws" {

  secret_key = var.aws_secret_key

}
```

Now the secret is not stored in the Terraform code.

---

# 2. Terraform State File

## The Biggest Secret Risk

Terraform state is Terraform's memory.

File:

```
terraform.tfstate
```

It stores:

* Resources created
* Resource relationships
* Resource attributes
* Configuration information

Sometimes it also stores sensitive values.

Example:

You create an RDS database:

```hcl
resource "aws_db_instance" "database" {

 username = "admin"

 password = var.database_password

}
```

Terraform needs to remember this.

The state may contain:

```json
{
 "username": "admin",
 "password": "MyPassword123"
}
```

Even if the password is marked sensitive, Terraform may still store it in the state.

Important:

> `sensitive = true` hides output, but it does not remove the value from state.

---

# Protecting the State File

## Local State

Default:

```
terraform.tfstate
```

stored on your computer.

Problems:

* Laptop theft
* Accidental upload
* No team access control
* No locking

Good for:

* Learning
* Small personal projects

---

## Remote State

For teams, store state remotely.

Example:

AWS S3 backend:

```hcl
terraform {

 backend "s3" {

   bucket = "company-terraform-state"

   key = "prod/terraform.tfstate"

   region = "us-east-1"

 }

}
```

Now:

```
Developer Laptop

        |

        ↓

AWS S3

(terraform state)
```

Benefits:

* Central location
* Team collaboration
* Access control
* Encryption
* Version history

---

# State Locking

When multiple engineers work together:

Engineer A:

```bash
terraform apply
```

Engineer B:

```bash
terraform apply
```

at the same time.

Without locking:

```
Engineer A
    |
updates state

Engineer B
    |
updates state
```

Two people modify the same state.

Result:

* Corrupted state
* Conflicting changes
* Infrastructure mistakes

---

With state locking:

```
Engineer A

terraform apply

       ↓

State Locked

       ↓

Changes complete

       ↓

State Unlocked


Engineer B waits
```

Common solution:

AWS:

* S3 → stores state
* DynamoDB → state locking

---

# 3. Terraform Output

Outputs can accidentally expose secrets.

Example:

Bad:

```hcl
output "database_password" {

 value = aws_db_instance.database.password

}
```

After:

```bash
terraform apply
```

The password appears.

---

# Solution: Sensitive Outputs

```hcl
output "database_password" {

 value = aws_db_instance.database.password

 sensitive = true

}
```

Now Terraform hides it:

```
database_password = <sensitive>
```

---

Important:

Sensitive does NOT encrypt the value.

It only prevents displaying it.

---

# 4. Terraform Logs

Terraform can create logs.

Example:

```bash
export TF_LOG=DEBUG
```

Terraform prints detailed information.

Problem:

Logs may contain:

* API requests
* Resource details
* Authentication information

Example:

```
Sending request:

Authorization:
AWS_SECRET_KEY=abc123
```

---

## Solution

Avoid debug logs in production.

If needed:

```bash
export TF_LOG=ERROR
```

or:

```bash
unset TF_LOG
```

Remove logs after troubleshooting.

---

# 5. Terraform Plan Files

Terraform allows saving plans:

```bash
terraform plan -out=myplan
```

Then:

```bash
terraform apply myplan
```

Problem:

The plan file can contain sensitive information.

Example:

```
myplan

contains:

database password
API keys
resource details
```

Protect:

* Do not commit plan files
* Delete after use
* Store securely

Add:

```
*.tfplan
```

to:

```
.gitignore
```

---

# 6. Version Control (Git)

Never commit:

```
terraform.tfstate
terraform.tfstate.backup
terraform.tfvars
*.tfplan
```

Example:

Bad:

```
GitHub Repository

├── main.tf
├── terraform.tfstate  ❌
├── terraform.tfvars   ❌
```

---

Correct:

```
GitHub Repository

├── main.tf
├── variables.tf
├── outputs.tf
├── .gitignore
```

---

Example `.gitignore`:

```text
.terraform/

*.tfstate

*.tfstate.*

*.tfvars

*.tfplan
```

---

# Terraform Tools To Protect Secrets

Terraform provides several features.

---

# 1. Sensitive Variables

Example:

```hcl
variable "db_password" {

 type = string

 sensitive = true

}
```

Terraform hides it from:

* CLI output
* Logs

---

# 2. Environment Variables

Instead of:

```hcl
variable "password" {}
```

Use:

```bash
export TF_VAR_db_password="mypassword"
```

Terraform automatically reads:

```
TF_VAR_<variable_name>
```

Example:

Variable:

```hcl
variable "db_password" {}
```

Environment variable:

```bash
TF_VAR_db_password=password123
```

Terraform receives:

```text
db_password=password123
```

Advantages:

* Not stored in code
* Not pushed to GitHub
* Different value per environment

---

# 3. Secret Management Services

In production, companies rarely store secrets inside Terraform.

They use dedicated secret managers.

Examples:

## AWS Secrets Manager

Stores:

```
Database password

API keys

Tokens
```

Terraform retrieves them when needed.

Example:

```hcl
data "aws_secretsmanager_secret" "db_password" {

 name = "production/database/password"

}
```

---

## HashiCorp Vault

A dedicated secrets management platform.

Architecture:

```
Terraform

     |

     ↓

Vault

     |

     ↓

Secrets
```

Benefits:

* Encryption
* Rotation
* Access policies
* Auditing

---

# 4. IAM Least Privilege

Terraform should not use administrator credentials.

Bad:

```
Terraform User

AdministratorAccess
```

Better:

```
Terraform IAM Role

Only required permissions
```

Example:

Terraform creating S3:

Allow:

```
s3:CreateBucket
s3:PutBucketPolicy
s3:GetBucket
```

Do not allow:

```
iam:*
ec2:*
```

if not needed.

---

# Complete Secure Terraform Workflow

A production environment:

```
Developer

   |

Git Repository

(no secrets)

   |

Terraform

   |

AWS IAM Role

   |

AWS Secrets Manager

   |

Terraform State

(S3 + Encryption + Locking)

```

---

# Best Practices Checklist

## Never:

❌ Hardcode passwords
❌ Commit `.tfstate`
❌ Commit `.tfvars` with secrets
❌ Store AWS keys in code
❌ Share Terraform plan files publicly

---

## Always:

✅ Use sensitive variables
✅ Use environment variables
✅ Use remote encrypted state
✅ Enable state locking
✅ Use IAM least privilege
✅ Use AWS Secrets Manager/Vault
✅ Restrict access to state files
✅ Rotate credentials regularly

---

# Simple Way To Remember

Terraform has three major secret risks:

## 1. Code

Problem:

```
Hardcoded passwords
```

Solution:

```
Variables + environment variables
```

---

## 2. State

Problem:

```
terraform.tfstate contains information
```

Solution:

```
Remote backend + encryption + access control
```

---

## 3. Output and Logs

Problem:

```
Secrets displayed accidentally
```

Solution:

```
Sensitive values + careful logging
```

---

# Final Concept

Terraform does not magically remove secrets.

Terraform needs secrets to create infrastructure.

The goal is:

> Allow Terraform to access secrets while preventing humans, Git repositories, logs, and unauthorized systems from exposing them.

Secure Terraform means controlling:

* Where secrets are stored
* Who can access them
* How they are transferred
* How they are displayed
* How they are rotated
