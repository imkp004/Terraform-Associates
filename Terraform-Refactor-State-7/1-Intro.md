# Terraform State Refactoring

## What is State Refactoring?

As your Terraform project grows, your infrastructure will change over time.

You may:

* Rename resources.
* Move resources into modules.
* Remove resources from Terraform management.
* Bring existing infrastructure under Terraform management.
* Reorganize your code into multiple files or modules.

These changes are called **state refactoring**.

State refactoring means:

> **Changing how Terraform tracks resources without unnecessarily destroying and recreating them.**

The goal is to keep your infrastructure running while updating Terraform's understanding of where resources belong.

---

# Why Do We Need State Refactoring?

Imagine you created an EC2 instance.

```hcl
resource "aws_instance" "web" {
  ...
}
```

Terraform state now contains:

```text
aws_instance.web
```

Later you decide a better name would be:

```hcl
resource "aws_instance" "frontend" {
  ...
}
```

If you simply change the name and run:

```bash
terraform plan
```

Terraform thinks:

```text
Destroy:

aws_instance.web

Create:

aws_instance.frontend
```

But nothing actually changed in AWS.

Only the Terraform name changed.

Without state refactoring, Terraform cannot know that these are actually the same resource.

---

# What State Refactoring Does

Instead of destroying the EC2 instance and creating a new one, state refactoring tells Terraform:

> "This resource already exists. It simply has a new address."

Terraform updates its state instead of recreating infrastructure.

---

# Old Way (CLI Commands)

Older versions of Terraform mainly used CLI commands.

Examples include:

```text
terraform state mv

terraform state rm

terraform import
```

These commands directly modified the Terraform state file.

Although they still work today, they have several disadvantages.

---

# Problems with the Old CLI Method

Imagine you rename:

```text
aws_instance.web
```

to

```text
aws_instance.frontend
```

You would run:

```bash
terraform state mv aws_instance.web aws_instance.frontend
```

This changes the state file.

But there are problems.

### Problem 1

The command is **not stored** in your Terraform code.

A teammate cloning the repository will never know you executed it.

---

### Problem 2

It is easy to forget.

Someone else may simply run:

```bash
terraform apply
```

Terraform may now attempt to destroy and recreate resources.

---

### Problem 3

The history is lost.

Git stores your `.tf` files.

Git does **not** store commands you executed weeks ago.

---

### Problem 4

Harder for teams.

Everyone must remember which commands to run.

Large teams can easily make mistakes.

---

# New Way (Configuration Driven)

Modern Terraform allows state refactoring directly inside the configuration.

Instead of running commands manually, you simply write blocks such as:

* `moved`
* `removed`
* `import`

These blocks become part of your Terraform code.

They are version controlled.

Everyone receives them through Git.

Terraform automatically performs the state changes during `terraform apply`.

---

# Why Is the New Way Better?

Instead of remembering commands, everything becomes code.

Benefits include:

* Version controlled in Git.
* Easy for teammates.
* Self-documenting.
* Easier to review in pull requests.
* Repeatable.
* Less chance of human error.
* Fits the Infrastructure as Code philosophy.

Instead of saying:

> "Run these three commands after pulling the repository."

You simply commit the new configuration.

Everyone receives exactly the same state changes automatically.

---

# Moved Block

## What is it?

A `moved` block tells Terraform:

> "This resource has moved to a different address."

It prevents Terraform from destroying and recreating the resource.

Only the state is updated.

---

## Example 1 - Renaming a Resource

Old configuration

```hcl
resource "aws_instance" "web" {
  ...
}
```

New configuration

```hcl
resource "aws_instance" "frontend" {
  ...
}
```

Without a moved block:

Terraform plans:

```text
Destroy:

aws_instance.web

Create:

aws_instance.frontend
```

Instead write:

```hcl
moved {
  from = aws_instance.web
  to   = aws_instance.frontend
}
```

Terraform now understands:

```text
Old Resource

↓

Same Resource

↓

New Name
```

No EC2 instance is recreated.

Only the state entry changes.

---

## Example 2 - Moving into a Module

Old

```text
aws_vpc.main
```

New

```text
module.network.aws_vpc.main
```

Add:

```hcl
moved {
  from = aws_vpc.main
  to   = module.network.aws_vpc.main
}
```

Terraform updates the state instead of recreating the VPC.

---

# Removed Block

## What is it?

Sometimes a resource still exists in AWS, but you no longer want Terraform to manage it.

A `removed` block tells Terraform:

> "Forget about this resource."

Terraform removes it from the state without deleting it from the cloud.

---

## Example

Suppose Terraform manages:

```text
aws_s3_bucket.logs
```

The bucket must remain in AWS.

You no longer want Terraform to manage it.

You can use a removed block so Terraform removes it from the state.

Result:

```text
Terraform

❌ Stops managing bucket

AWS

✅ Bucket still exists
```

This is useful when:

* Another team takes ownership.
* Manual management is preferred.
* The resource is managed by another Terraform project.

---

# Import Block

## What is it?

An import block brings existing infrastructure under Terraform management.

Terraform does **not** create the resource.

It simply starts managing a resource that already exists.

---

## Example

Imagine someone manually created an S3 bucket.

AWS already has:

```text
company-logs
```

Terraform knows nothing about it.

Instead of creating another bucket, use an import block.

```hcl
import {
  to = aws_s3_bucket.logs
  id = "company-logs"
}
```

Terraform now understands:

```text
Existing AWS Resource

↓

Imported

↓

Managed by Terraform
```

No new bucket is created.

Terraform simply adds it to the state.

---

# Real World Example

Suppose your company has:

* 1 VPC
* 15 EC2 instances
* 8 Security Groups
* 10 S3 buckets

All created manually.

You decide to use Terraform.

Without importing:

Terraform sees nothing.

It wants to create everything again.

After importing:

Terraform learns about every existing resource.

Now Terraform can safely manage them.

---

# Comparison

| Feature                   | Old CLI     | New Configuration Blocks |
| ------------------------- | ----------- | ------------------------ |
| Stored in Git             | ❌ No        | ✅ Yes                    |
| Easy for teams            | ❌ No        | ✅ Yes                    |
| Repeatable                | ❌ No        | ✅ Yes                    |
| Reviewed in Pull Requests | ❌ No        | ✅ Yes                    |
| Infrastructure as Code    | ❌ Partially | ✅ Fully                  |
| Less human error          | ❌ No        | ✅ Yes                    |

---

# When to Use Each

### Use a `moved` block when:

* Renaming resources.
* Moving resources into modules.
* Reorganizing Terraform code.
* Changing resource addresses.

---

### Use a `removed` block when:

* Terraform should stop managing a resource.
* The resource must remain in the cloud.
* Ownership moves to another team or another Terraform project.

---

### Use an `import` block when:

* Infrastructure already exists.
* Terraform needs to begin managing it.
* Migrating manually created resources into Terraform.

---

# Key Points to Remember

* **State refactoring** means changing how Terraform tracks resources without unnecessarily destroying infrastructure.
* The old approach relied on CLI commands like `terraform state mv`, `terraform state rm`, and `terraform import`.
* The modern approach uses configuration blocks (`moved`, `removed`, and `import`) directly in `.tf` files.
* Configuration-based refactoring is preferred because it is version controlled, repeatable, easier to review, and works better in team environments.
* A **moved block** updates a resource's address in the state without recreating the resource.
* A **removed block** tells Terraform to stop managing a resource while leaving it intact in the cloud.
* An **import block** brings an existing cloud resource under Terraform management without creating a duplicate resource.
