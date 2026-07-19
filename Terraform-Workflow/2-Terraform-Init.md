 # Terraform `init`

## What is `terraform init`?

`terraform init` is the command used to **set up your Terraform working directory**.

It prepares your project so Terraform is ready to run commands such as:

```bash
terraform plan
terraform apply
terraform destroy
```

Think of `terraform init` as preparing your workspace before you start building your infrastructure.

You will usually run it:

* At the beginning of a new Terraform project.
* After cloning a Terraform project from GitHub.
* After adding a new provider.
* After adding a new module.
* After changing the backend configuration.
* After upgrading or changing provider versions.
* After upgrading Terraform itself (in many cases).

---

# What Does `terraform init` Do?

When you run:

```bash
terraform init
```

Terraform performs several setup tasks automatically.

It will:

* Read all the `.tf` configuration files in the current directory.
* Check the required Terraform version.
* Find all required providers.
* Download provider plugins.
* Download any required modules.
* Initialize the backend (if one is configured).
* Create or update the `.terraform.lock.hcl` file.
* Create or update the `.terraform/` directory.

**Important:** `terraform init` does **not** create any cloud resources.

No EC2 instances, S3 buckets, VPCs, or databases are created during this step.

It only prepares your project.

---

# The `.terraform.lock.hcl` File

After running `terraform init`, Terraform creates a file named:

```text
.terraform.lock.hcl
```

You will find it in the **root of your project**, alongside your `.tf` files.

Example:

```text
terraform-project/

├── main.tf
├── variables.tf
├── outputs.tf
├── .terraform.lock.hcl
└── .terraform/
```

---

## What Does the Lock File Do?

The lock file records the exact versions of the providers your project is using.

For example:

```text
AWS Provider
Version: 6.55.0

Random Provider
Version: 3.7.2
```

It also stores security checksums for each provider to verify that the downloaded provider has not been modified or corrupted.

Terraform manages this file automatically.

You should **never edit it manually**.

If you update a provider version in your Terraform configuration and run:

```bash
terraform init
```

Terraform updates the lock file automatically.

---

## Why Is the Lock File Important?

Imagine three engineers are working on the same project.

Without a lock file:

* Engineer A downloads AWS Provider 6.55.0.
* Engineer B downloads AWS Provider 6.56.0.
* Engineer C downloads AWS Provider 6.60.0.

Now everyone is using different versions, which can lead to unexpected behavior.

With the lock file, everyone downloads the exact same provider versions, making the project consistent across all environments.

---

## Should You Commit the Lock File to GitHub?

**Yes.**

The `.terraform.lock.hcl` file **should always be committed** to your version control system (GitHub, GitLab, Azure DevOps, etc.).

This ensures every team member uses the same provider versions.

---

# The `.terraform/` Directory

`terraform init` also creates a hidden directory named:

```text
.terraform/
```

Example:

```text
terraform-project/

├── .terraform/
├── .terraform.lock.hcl
├── main.tf
├── variables.tf
└── outputs.tf
```

This directory is Terraform's **working directory**.

It stores files that Terraform needs while running your project.

---

## What Is Stored Inside `.terraform/`?

Common contents include:

```text
.terraform/

├── providers/
├── modules/
└── terraform.tfstate (backend metadata in some cases)
```

### Providers

The `providers/` folder contains the downloaded provider plugins.

For example:

```text
.terraform/providers/

└── registry.terraform.io/

    └── hashicorp/

        ├── aws/
        ├── random/
        └── github/
```

Each provider contains an executable plugin that allows Terraform to communicate with a platform such as AWS, Azure, GitHub, or Docker.

---

### Modules

If your project uses modules, Terraform downloads remote modules into:

```text
.terraform/modules/
```

This prevents Terraform from downloading the same modules every time you run a command.

---

## Can You Delete the `.terraform/` Directory?

**Yes.**

The `.terraform/` directory only contains downloaded dependencies and working files.

If you delete it, nothing happens to your infrastructure.

Simply run:

```bash
terraform init
```

again, and Terraform will recreate the directory and download everything it needs.

---

## Should You Commit `.terraform/` to GitHub?

**No.**

The `.terraform/` directory should **never** be committed to version control.

It is considered a temporary working directory and can always be recreated by running `terraform init`.

Most Terraform projects include it in the `.gitignore` file.

---

# Difference Between `.terraform.lock.hcl` and `.terraform/`

This is one of the most common beginner questions.

Although both are created by `terraform init`, they serve completely different purposes.

| `.terraform.lock.hcl`                                     | `.terraform/` Directory                                       |
| --------------------------------------------------------- | ------------------------------------------------------------- |
| A single file                                             | A directory (folder)                                          |
| Stores the exact provider versions and security checksums | Stores downloaded providers, modules, and other working files |
| Ensures everyone uses the same dependency versions        | Gives Terraform the files it needs to run locally             |
| Managed automatically by Terraform                        | Managed automatically by Terraform                            |
| Should be committed to GitHub                             | Should **not** be committed to GitHub                         |
| Small text file                                           | Can become quite large                                        |
| Keeps projects consistent across different computers      | Can be deleted and recreated at any time                      |

---

# Think of It Like Building a House

Imagine you're building a house.

### `.terraform.lock.hcl`

This is like your **shopping list**.

It says:

* Buy this exact brand of cement.
* Buy this exact size of lumber.
* Buy these exact materials.

Everyone on the team follows the same list, ensuring consistency.

---

### `.terraform/`

This is like your **garage or storage room**.

It contains:

* The tools.
* The equipment.
* The materials.
* The supplies.

If the garage burns down, you don't lose the house plans—you simply buy the tools again.

That's exactly what `terraform init` does.

---

# Visual Example

Before running `terraform init`:

```text
terraform-project/

├── main.tf
├── variables.tf
└── outputs.tf
```

After running `terraform init`:

```text
terraform-project/

├── .terraform/
│   ├── providers/
│   └── modules/
│
├── .terraform.lock.hcl
├── main.tf
├── variables.tf
└── outputs.tf
```

---

# Key Points to Remember

* `terraform init` prepares your Terraform project for use.
* It downloads providers and modules required by your configuration.
* It creates the hidden `.terraform/` working directory.
* It creates or updates the `.terraform.lock.hcl` dependency lock file.
* `.terraform.lock.hcl` records the exact provider versions and should be committed to Git.
* `.terraform/` stores downloaded providers and modules and should **not** be committed to Git.
* If `.terraform/` is deleted, running `terraform init` recreates it.
* Terraform manages both the lock file and the `.terraform/` directory automatically.

---

# Summary

Although `.terraform.lock.hcl` and `.terraform/` are both created by `terraform init`, they serve different purposes. The **lock file** is a small text file that records the exact versions of the providers your project depends on, ensuring consistency across all team members and environments. The **`.terraform/` directory** is Terraform's local workspace, where it stores downloaded providers, modules, and other temporary files needed to run the project. In short, **the lock file records what versions should be used, while the `.terraform/` directory stores the actual downloaded files that Terraform uses to do its work.**
