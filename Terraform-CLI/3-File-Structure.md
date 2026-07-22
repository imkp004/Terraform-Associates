# Organizing Terraform Projects

As your Terraform projects grow, putting everything into one file becomes difficult to read and maintain.

Instead of having one huge `main.tf` file with hundreds of lines of code, it is a best practice to split your configuration into multiple `.tf` files.

This makes your project:

* Easier to read
* Easier to maintain
* Easier to debug
* Easier to collaborate with other engineers

The important thing to remember is:

> **Terraform automatically reads every `.tf` file in the current directory.**

It does **not** matter which file a resource is in. Terraform combines all the `.tf` files into one configuration before creating its Resource Graph.

For example, if you have:

```text
main.tf
variables.tf
outputs.tf
providers.tf
network.tf
ec2.tf
database.tf
```

Terraform reads **all of them together**.

This also means **resource referencing works across files**.

Example:

`network.tf`

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```

`ec2.tf`

```hcl
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
}
```

Even though these resources are in different files, Terraform understands the dependency automatically.

---

# Common Terraform Files

## `main.tf`

Usually contains the **primary infrastructure** or acts as the starting point of your project.

Example:

* EC2 Instances
* VPC
* Security Groups

Example:

```hcl
resource "aws_instance" "web" {

}
```

---

## `providers.tf`

Contains provider configuration.

This tells Terraform which cloud provider to connect to.

Example:

```hcl
provider "aws" {

  region = "us-east-1"

}
```

You may also configure:

* Azure
* Google Cloud
* GitHub
* Kubernetes

---

## `variables.tf`

Contains all input variables.

Instead of hardcoding values throughout your project, define them once.

Example:

```hcl
variable "region" {

  type = string

}
```

Later:

```hcl
provider "aws" {

  region = var.region

}
```

This makes your code reusable.

---

## `terraform.tfvars`

Contains the **actual values** for variables.

Example:

`variables.tf`

```hcl
variable "region" {

}
```

`terraform.tfvars`

```hcl
region = "us-east-1"
```

Instead of editing Terraform code, you simply change the values in one place.

You can even have different variable files:

```text
dev.tfvars
test.tfvars
prod.tfvars
```

Example:

```bash
terraform apply -var-file="prod.tfvars"
```

This allows the same Terraform code to deploy different environments.

### Should `terraform.tfvars` be in Git?

It depends.

If the file contains:

* Passwords
* API Keys
* Access Keys
* Database Passwords

then **do not commit it to GitHub**.

Many teams add it to:

```text
.gitignore
```

to prevent accidentally exposing sensitive information.

If the file only contains non-sensitive values (such as regions or instance sizes), some teams choose to commit it. However, secrets should never be stored in version control.

---

## `outputs.tf`

Contains Terraform outputs.

Outputs display useful information after Terraform finishes.

Example:

```hcl
output "instance_ip" {

  value = aws_instance.web.public_ip

}
```

Terraform prints:

```text
instance_ip = 18.201.55.120
```

Outputs can also be consumed by other Terraform configurations using remote state, making them useful for sharing information between projects.

---

# Terraform-Managed Files

Terraform creates several files automatically. You should **not edit these manually**.

---

## `terraform.tfstate`

This is Terraform's **state file**.

It stores:

* Every managed resource
* Resource IDs
* Current infrastructure state
* Dependencies
* Metadata

Terraform uses this file to determine:

* What already exists
* What needs to change
* What needs to be created
* What needs to be destroyed

Think of it as Terraform's memory.

---

## `terraform.tfstate.backup`

Before Terraform updates the state file, it creates a backup.

If something goes wrong, you still have the previous state.

Think of it as a recovery copy of your state file.

---

## `.terraform.lock.hcl`

Stores the exact provider versions used.

Example:

```text
AWS Provider

Version 6.55.0
```

Every team member downloads the exact same provider version.

This prevents unexpected behavior caused by version differences.

Terraform manages this file automatically.

You should commit this file to Git.

---

# Large Projects

For small labs, one directory is enough.

Real-world projects are much larger.

A common approach is to separate environments into different directories.

Example:

```text
terraform/

    dev/

    test/

    prod/
```

Each directory contains its own:

* `.tf` files
* State file
* Variables
* Resources

For example:

```text
terraform/

    dev/

        main.tf

        terraform.tfstate

    prod/

        main.tf

        terraform.tfstate
```

The **development environment is completely separate from production**.

If you destroy resources inside:

```text
dev/
```

only the development resources are removed.

The production infrastructure is unaffected because it has its own configuration and state.

This separation reduces risk and makes it much safer to test infrastructure changes.

---
