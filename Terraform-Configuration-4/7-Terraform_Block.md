# Terraform Block

## What is the Terraform Block?

The **Terraform block** is where you configure **Terraform itself**.

It does **not** create infrastructure.

Instead, it tells Terraform **how it should behave** before it starts creating resources.

Think of it as the **settings menu** for your Terraform project.

Just like before installing software you choose:

* Which version to install
* Where to save files
* Which plugins to use

The Terraform block does the same thing for Terraform.

---

# What Does the Terraform Block Do?

The Terraform block can configure things like:

* Which Terraform version is required
* Which provider versions should be used
* Where the Terraform state file should be stored (Backend)
* Experimental features (rare)
* Required Terraform settings

Notice something?

None of these create AWS resources.

Instead, they configure **Terraform itself**.

---

# Real-World Analogy

Imagine you are building a house.

Before construction begins, you decide:

* Which building code to follow
* Which architect's blueprint version to use
* Where all project documents will be stored
* Which construction company will build it

Those settings happen **before** the workers begin building.

The Terraform block works exactly like that.

---

# General Syntax

```hcl
terraform {

  ...

}
```

Everything inside this block configures Terraform.

---

# A Complete Terraform Block

```hcl
terraform {

  required_version = ">= 1.5.0"

  required_providers {

    aws = {

      source  = "hashicorp/aws"

      version = "~> 6.0"

    }

    random = {

      source  = "hashicorp/random"

      version = "~> 3.0"

    }

  }

  backend "s3" {

    bucket = "company-terraform-state"

    key    = "production/terraform.tfstate"

    region = "us-east-1"

  }

}
```

Let's understand every part.

---

# required_version

```hcl
required_version = ">= 1.5.0"
```

This tells Terraform:

> **"Do not run this project unless Terraform is at least version 1.5.0."**

If someone tries:

```text
Terraform Version

1.3.0
```

Terraform stops immediately.

Example:

```text
Error:

Terraform version 1.3.0 is not supported.

Please install Terraform 1.5.0 or later.
```

This prevents compatibility problems.

---

## Why Is This Important?

Imagine your project uses a feature introduced in Terraform 1.6.

Your teammate still has Terraform 1.2 installed.

Without version checking:

* Your code works.
* Their code fails.
* Nobody knows why.

This leads to the classic problem:

> **"It works on my machine."**

Using `required_version` prevents this.

Everyone uses a compatible Terraform version.

---

# required_providers

Terraform itself cannot communicate with AWS.

It needs a provider.

Example:

```hcl
required_providers {

  aws = {

    source = "hashicorp/aws"

    version = "~> 6.0"

  }

}
```

This tells Terraform:

* Download the AWS provider.
* Download it from HashiCorp.
* Use version 6.x.

When you run:

```bash
terraform init
```

Terraform downloads this provider automatically.

---

# source

```hcl
source = "hashicorp/aws"
```

This tells Terraform where the provider comes from.

Format:

```text
publisher/provider-name
```

Examples:

```text
hashicorp/aws

hashicorp/random

hashicorp/azurerm

hashicorp/google
```

Think of it like downloading an app from an official app store.

---

# version

```hcl
version = "~> 6.0"
```

This tells Terraform which provider version may be used.

We'll cover version constraints in detail shortly.

---

# Backend Configuration

Example:

```hcl
backend "s3" {

  bucket = "company-terraform-state"

  key = "prod/terraform.tfstate"

  region = "us-east-1"

}
```

This tells Terraform:

> "Store my state file inside an S3 bucket instead of on my computer."

Without a backend:

```text
terraform.tfstate

↓

Stored locally
```

With an S3 backend:

```text
terraform.tfstate

↓

Stored securely inside Amazon S3
```

---

# Why Use a Backend?

Imagine five engineers work on the same project.

If everyone stores their own local state file:

```text
Engineer A

terraform.tfstate
```

```text
Engineer B

terraform.tfstate
```

```text
Engineer C

terraform.tfstate
```

Now there are multiple different state files.

Terraform no longer knows the real infrastructure.

This causes:

* Drift
* Conflicts
* Accidental deletions
* Duplicate resources

Instead, everyone shares one remote state file.

```text
Engineer A

↓

Engineer B

↓

Engineer C

↓

Shared S3 State File
```

Now everyone uses exactly the same state.

---

# Global Configuration

Everything inside the Terraform block affects the **entire project**.

Examples:

* Terraform version
* Provider versions
* Backend
* Required features

You only define these once.

Every resource automatically follows these settings.

---

# Avoiding Team Errors

Imagine a team of four engineers.

Engineer A

```text
Terraform 1.10
```

Engineer B

```text
Terraform 1.8
```

Engineer C

```text
Terraform 0.14
```

Engineer D

```text
Terraform 1.6
```

Without version constraints:

Everyone runs different versions.

One engineer may see errors that nobody else sees.

By specifying:

```hcl
required_version = "~> 1.10"
```

Everyone must use Terraform 1.10.x.

Now everyone works in the same environment.

---

# Version Constraints

Terraform supports several ways to specify versions.

Each has a different purpose.

---

# Exact Version

Example:

```hcl
required_version = "1.5.0"
```

Meaning:

Only Terraform **1.5.0** is allowed.

Allowed:

```text
1.5.0
```

Not allowed:

```text
1.4.9

1.5.1

1.6.0

2.0.0
```

This is the strictest option.

It guarantees every developer uses exactly the same version.

---

## When Should You Use It?

Usually:

* Production systems
* Critical environments
* Very controlled deployments

---

# Greater Than or Equal

Example:

```hcl
required_version = ">= 1.5.0"
```

Meaning:

Terraform must be at least version 1.5.0.

Allowed:

```text
1.5.0

1.6.0

1.7.4

2.0.0
```

Not allowed:

```text
1.4.8

1.3.2
```

This is much more flexible.

However, allowing version 2.0 could introduce breaking changes if Terraform makes incompatible updates.

---

# Pessimistic Constraint (~>)

This is one of Terraform's most commonly used version constraints.

Example:

```hcl
version = "~> 6.0"
```

Meaning:

Use version **6.0 or newer**, but **do not upgrade to version 7.0**.

Allowed:

```text
6.0.0

6.1.0

6.5.2

6.99.0
```

Not allowed:

```text
5.9.0

7.0.0
```

This lets you receive new features and bug fixes within the same major version while avoiding potentially breaking major upgrades.

---

## Another Example

```hcl
version = "~> 6.4"
```

Allowed:

```text
6.4.0

6.4.5

6.4.20
```

Not allowed:

```text
6.5.0

7.0.0
```

Because the **right-most version number** is locked.

Terraform can update only the number to its right.

---

## Another Example

```hcl
version = "~> 1.2.3"
```

Allowed:

```text
1.2.3

1.2.4

1.2.9
```

Not allowed:

```text
1.3.0

2.0.0
```

Only the last number (patch version) can increase.

---

# Comparison Table

| Constraint   | Meaning                 | Allowed Versions     | Not Allowed     |
| ------------ | ----------------------- | -------------------- | --------------- |
| `"1.5.0"`    | Exactly this version    | 1.5.0                | Everything else |
| `">= 1.5.0"` | Version 1.5.0 or newer  | 1.5.0, 1.6.0, 2.0.0  | 1.4.x           |
| `"~> 6.0"`   | Any 6.x version         | 6.0.0, 6.5.0, 6.99.0 | 7.0.0           |
| `"~> 6.4"`   | Any 6.4.x version       | 6.4.0, 6.4.9         | 6.5.0           |
| `"~> 1.2.3"` | Any 1.2.x patch version | 1.2.3, 1.2.8         | 1.3.0           |

---

# Why Are Version Constraints Important?

Imagine your project was tested using AWS Provider 6.0.

One day HashiCorp releases Provider 7.0 with breaking changes.

Without a version constraint:

```text
terraform init

↓

Downloads Provider 7.0

↓

Your code breaks
```

With:

```hcl
version = "~> 6.0"
```

Terraform continues downloading only version 6.x.

Your project remains stable until you are ready to upgrade.

---

# Best Practices

* Always specify a `required_version` for Terraform.
* Always specify provider versions in `required_providers`.
* Use meaningful version constraints instead of allowing any version.
* Store your state remotely (such as an S3 backend) when working in teams.
* Let Terraform manage provider downloads through `terraform init`.
* Avoid changing version constraints unless you have tested the newer versions.

---

# Key Points to Remember

* The Terraform block configures **Terraform itself**, not your cloud resources.
* It acts like the **settings menu** for your Terraform project.
* Common settings include the required Terraform version, required providers, and backend configuration.
* The `required_version` setting ensures everyone uses a compatible version of Terraform, reducing "works on my machine" problems.
* The `required_providers` block tells Terraform which provider plugins to download, where to get them from, and which versions are allowed.
* A backend configuration tells Terraform where to store the state file, making collaboration much safer for teams.
* Version constraints help keep projects stable by controlling when upgrades are allowed.
* Using a well-configured Terraform block improves consistency, collaboration, security, and long-term maintainability.
