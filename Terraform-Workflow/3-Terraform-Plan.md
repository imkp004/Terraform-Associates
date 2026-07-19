# Terraform `plan`

## What is `terraform plan`?

`terraform plan` is used to **preview the changes Terraform is going to make** before it actually changes your infrastructure.

Think of it as a **preview** or a **dry run**.

It lets you review the changes and decide whether you want to continue or make corrections first.

Run the command:

```bash
terraform plan
```

Terraform compares:

* **Your Terraform configuration** (the desired state)
* **The current infrastructure** (the current state stored in the Terraform state file and the cloud provider)

It then creates an **execution plan** showing exactly what actions it would perform.

**Important:** During the `terraform plan` stage, **nothing is created, updated, or deleted**. Terraform is only showing you what it intends to do.

---

# What Happens When You Run `terraform plan`?

When you execute:

```bash
terraform plan
```

Terraform performs several steps:

1. Reads all of your `.tf` configuration files.
2. Reads the current Terraform state file (`terraform.tfstate` or the remote state).
3. Connects to the provider (AWS, Azure, GCP, GitHub, etc.).
4. Checks the actual infrastructure that Terraform manages.
5. Compares the desired state with the current state.
6. Calculates the differences.
7. Displays an execution plan.

This is usually the **first command that communicates with your cloud provider**.

Unlike `terraform init`, which only prepares the project, `terraform plan` actually contacts the provider to inspect your existing infrastructure.

---

# What Does Terraform Compare?

Terraform compares two things:

### Desired State

This is what you wrote in your Terraform configuration.

Example:

```hcl
resource "aws_instance" "web" {
  instance_type = "t3.micro"
}
```

---

### Current State

This is what currently exists in your cloud account and what Terraform is tracking.

For example:

```text
EC2 Instance
Instance Type: t2.micro
```

Terraform compares the two and notices:

```text
Desired: t3.micro

Current: t2.micro
```

So it plans to update the EC2 instance.

---

# Understanding the Plan Output

Terraform uses symbols to indicate what it plans to do.

## `+` Create

A plus sign means Terraform will create a new resource.

Example:

```text
+ aws_instance.web
```

Meaning:

> Terraform will create a new EC2 instance.

---

## `~` Update

A tilde means Terraform will modify an existing resource.

Example:

```text
~ aws_instance.web
```

Meaning:

> Terraform will update an existing EC2 instance.

---

## `-` Destroy

A minus sign means Terraform will remove a resource.

Example:

```text
- aws_s3_bucket.logs
```

Meaning:

> Terraform will delete the S3 bucket.

---

## `-/+` Destroy and Recreate

Sometimes Terraform cannot update a resource in place.

Instead, it must:

1. Delete the existing resource.
2. Create a brand-new one.

Example:

```text
-/+ aws_instance.web
```

This is called a **replacement**.

---

# Example Output

```text
Terraform will perform the following actions:

  + aws_s3_bucket.logs
  ~ aws_instance.web
  - aws_security_group.old
  -/+ aws_db_instance.database

Plan: 2 to add, 1 to change, 1 to destroy.
```

This tells you:

* Create one new S3 bucket.
* Update one EC2 instance.
* Delete one Security Group.
* Replace one database.

---

# Why Should You Always Run `terraform plan`?

Running `terraform plan` helps you catch mistakes before they affect your infrastructure.

For example, imagine you accidentally changed:

```hcl
instance_type = "t3.micro"
```

to

```hcl
instance_type = "m7i.48xlarge"
```

A plan would clearly show that Terraform intends to replace or update the instance.

Instead of creating an expensive resource by mistake, you can:

* Stop.
* Fix your configuration.
* Run `terraform plan` again.
* Verify the changes.
* Then run `terraform apply`.

**Best practice:** Always review the plan before applying changes, especially in production environments.

---

# Does `terraform plan` Change Anything?

No.

It only calculates what **would** happen.

Nothing is modified in your cloud account.

No infrastructure is created, updated, or destroyed.

---

# Saving a Plan

Instead of displaying the plan on the screen, you can save it to a file.

Run:

```bash
terraform plan -out=myplan
```

Terraform creates a binary plan file named:

```text
myplan
```

This file contains the exact execution plan that Terraform calculated.

---

# Applying a Saved Plan

Later, you can execute the saved plan.

Run:

```bash
terraform apply myplan
```

Terraform follows the instructions stored in the plan file.

This is commonly used in CI/CD pipelines where:

* One engineer or automation system creates the plan.
* Another engineer reviews and approves it.
* The approved plan is then applied.

This ensures that the infrastructure applied is **exactly** the one that was reviewed.

---

# Important Question

## What happens if I change my Terraform configuration **after** creating a saved plan?

Suppose you do this:

### Step 1

Current configuration:

```hcl
instance_type = "t3.micro"
```

Run:

```bash
terraform plan -out=myplan
```

The plan file now contains instructions to create or update an EC2 instance with `t3.micro`.

---

### Step 2

Before applying the plan, you edit your configuration:

```hcl
instance_type = "t3.large"
```

Now your `.tf` file is different from the plan file.

---

### Step 3

You run:

```bash
terraform apply myplan
```

## What happens?

Terraform **does not read your updated `.tf` files**.

It executes the instructions stored inside the saved plan file.

So Terraform will still use:

```text
t3.micro
```

because that is what was calculated when the plan was created.

Your later changes to the configuration are ignored.

---

# Why?

A saved plan is a **snapshot** of what Terraform intended to do at the time you ran `terraform plan -out`.

The plan already contains:

* The resources to create.
* The resources to update.
* The values to use.
* The order of operations.

Terraform simply executes that snapshot.

It does **not** recalculate the plan.

---

# What If the Infrastructure Changed After the Plan Was Created?

Suppose someone manually changes your infrastructure in AWS after you create the plan.

When you later run:

```bash
terraform apply myplan
```

Terraform performs safety checks.

If the infrastructure has changed in a way that makes the saved plan invalid or unsafe, Terraform will usually stop with an error instead of applying outdated changes.

This helps prevent accidental modifications based on stale information.

---

# Visual Workflow

```text
Write Configuration
        │
        ▼
terraform init
        │
        ▼
terraform plan
        │
        ├──────────────► Review the changes
        │
        ├──────────────► Save the plan
        │                 terraform plan -out=myplan
        │
        ▼
Approved
        │
        ▼
terraform apply myplan
        │
        ▼
Infrastructure Updated
```

---

# Key Points to Remember

* `terraform plan` previews changes without modifying infrastructure.
* It compares your desired configuration with the current infrastructure.
* It is usually the first Terraform command that communicates with your cloud provider.
* `+` means create.
* `~` means update.
* `-` means destroy.
* `-/+` means destroy and recreate (replace).
* Always review the plan before running `terraform apply`.
* You can save a plan using `terraform plan -out=<filename>`.
* Applying a saved plan executes the instructions stored in the plan file, **not** the current `.tf` configuration.
* If you change your Terraform code after creating a saved plan, those changes are **not** included. You must create a **new** plan for Terraform to consider the updated configuration.

---

# Summary

`terraform plan` is one of the most important commands in Terraform because it lets you safely review infrastructure changes before they are made. It compares your desired configuration with the current state of your infrastructure, contacts the cloud provider to verify existing resources, and generates an execution plan showing exactly what Terraform would create, update, destroy, or replace. By reviewing this plan before applying changes, you can catch mistakes early and ensure that only the intended changes are made. If you save the plan to a file, Terraform applies **that exact plan** later, even if the configuration files have changed in the meantime.
