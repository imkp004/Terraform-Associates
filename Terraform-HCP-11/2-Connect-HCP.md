# Connecting Terraform to HCP Terraform

## Overview

Before Terraform can use **HCP Terraform (HashiCorp Cloud Platform)**, your local Terraform CLI needs to know **which HCP organization and workspace it should communicate with**.

By default, Terraform works locally. It has no idea that you want to use HCP Terraform until you explicitly configure it.

Connecting Terraform to HCP Terraform consists of two main steps:

1. Configure the **Cloud Block** in your Terraform configuration.
2. Authenticate your local Terraform CLI with HCP Terraform.

---

# Step 1 - Configure the Cloud Block

Inside the `terraform` block, add a **cloud block**.

This tells Terraform:

* Which HCP Terraform organization to use
* Which workspace to use
* Where Terraform operations should be managed

Example:

```hcl
terraform {

  cloud {

    organization = "my-company"

    workspaces {
      name = "production"
    }

  }

}
```

---

## Explanation

### `cloud`

```hcl
cloud {

}
```

The `cloud` block tells Terraform that this project will use **HCP Terraform** instead of only working locally.

Without this block, Terraform assumes it should use local state or another configured backend.

---

### `organization`

```hcl
organization = "my-company"
```

An **organization** is the top-level container inside HCP Terraform.

Think of it like a company account.

Example:

```text
Organization

my-company

├── Development Workspace
├── Testing Workspace
├── Production Workspace
└── Networking Workspace
```

All workspaces belong to an organization.

---

### `workspaces`

```hcl
workspaces {

}
```

A workspace is where Terraform stores:

* State
* Variables
* Run history
* Plans
* Applies

Each workspace manages a separate infrastructure.

---

### Workspace Name

```hcl
name = "production"
```

This tells Terraform exactly which workspace to connect to.

For example:

```text
Organization

my-company

├── dev
├── test
├── staging
└── production
```

If your configuration specifies:

```hcl
name = "production"
```

Terraform connects only to the **production** workspace.

---

## Using Workspace Tags

Instead of connecting to one workspace, you can connect to multiple workspaces using tags.

Example:

```hcl
terraform {

  cloud {

    organization = "my-company"

    workspaces {
      tags = ["aws"]
    }

  }

}
```

Now any workspace tagged with:

```text
aws
```

can use this configuration.

This is useful for larger organizations that manage many workspaces.

---

# Step 2 - Authenticate Terraform

After Terraform knows **where** to connect, it still needs permission to access your HCP Terraform account.

Authentication proves your identity.

The easiest method is:

```bash
terraform login
```

---

## What Happens During `terraform login`

When you run:

```bash
terraform login
```

Terraform opens your web browser.

You log into your HCP Terraform account.

After logging in:

* HCP generates an API token.
* Terraform securely stores the token on your local computer.
* Future Terraform commands automatically use that token.

You only need to do this once on a machine unless the token is removed or expires.

---

## Where Is the Token Stored?

Terraform stores the token in a credentials file on your local machine.

Typical location:

Linux/macOS:

```text
~/.terraform.d/credentials.tfrc.json
```

Windows:

```text
%APPDATA%\terraform.d\credentials.tfrc.json
```

Example:

```json
{
  "credentials": {
    "app.terraform.io": {
      "token": "xxxxxxxxxxxxxxxxxxxxxxxx"
    }
  }
}
```

From this point forward, Terraform automatically uses this token whenever it communicates with HCP Terraform.

---

# Workflow After Authentication

```text
terraform init

        │

Reads cloud block

        │

Connects to HCP Terraform

        │

Reads stored API token

        │

Authentication Successful

        │

Downloads workspace information

        │

Ready to run Terraform
```

---

# Authentication in CI/CD Pipelines

Running:

```bash
terraform login
```

works well on your laptop because a web browser is available.

However, CI/CD systems such as:

* GitHub Actions
* Jenkins
* GitLab CI
* Azure DevOps
* CircleCI

usually do **not** have a browser.

Terraform cannot ask someone to log in interactively.

Instead, Terraform uses an environment variable.

Example:

```bash
export TF_TOKEN_app_terraform_io="xxxxxxxxxxxxxxxxxxxxxxxx"
```

Terraform automatically detects this environment variable and uses it to authenticate with HCP Terraform.

No browser is required.

---

## Why Use an Environment Variable?

Environment variables provide several advantages:

* No interactive login
* Ideal for automation
* Works in containers
* Works on build servers
* Token is not hardcoded into Terraform configuration
* Easy to rotate or replace

This makes it the preferred authentication method for automated deployments.

---

# Typical CI/CD Workflow

```text
GitHub Actions

        │

Reads TF_TOKEN_app_terraform_io

        │

Authenticates to HCP Terraform

        │

Runs terraform init

        │

Runs terraform plan

        │

Runs terraform apply

        │

HCP Terraform

        │

AWS Infrastructure
```

Everything happens automatically without requiring a browser or manual login.

---

# Best Practices

✅ Use `terraform login` for your personal development machine.

✅ Use `TF_TOKEN_app_terraform_io` in CI/CD pipelines and automation.

✅ Never hardcode API tokens inside Terraform configuration files.

❌ Never commit API tokens to Git.

✅ Store CI/CD tokens securely using your platform's secret management (for example, GitHub Actions Secrets, GitLab CI Variables, or Jenkins Credentials).

✅ Create separate tokens for different users or automation systems instead of sharing one token across the entire team.

---

# Simple Way to Remember

Terraform needs two things before it can use HCP Terraform:

1. **Where should I connect?**

   * Configure the `cloud` block with your organization and workspace.

2. **Who are you?**

   * Authenticate using `terraform login` (local development) or `TF_TOKEN_app_terraform_io` (CI/CD).

Think of it like logging into an online service:

* The **cloud block** is the destination (the account and workspace).
* The **API token** is your identity (proof that you're allowed to access it).
