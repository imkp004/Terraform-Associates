# Infrastructure Drift (When Terraform State Doesn't Match the Real World)

## What is Infrastructure Drift?

Infrastructure drift happens when the **actual infrastructure in the cloud no longer matches what Terraform expects**.

Remember, Terraform works with three things:

1. **Terraform Configuration** (`.tf` files) → What you want your infrastructure to look like (desired state).
2. **Terraform State** (`terraform.tfstate`) → What Terraform believes currently exists.
3. **Cloud Infrastructure** (AWS, Azure, GCP) → What actually exists.

Ideally, all three should match.

```text
Terraform Configuration
        │
        ▼
Terraform State
        │
        ▼
Cloud Infrastructure

Everything matches ✔
```

---

# Example Before Drift

Suppose your Terraform code creates:

* 1 VPC
* 1 Subnet

You run:

```bash
terraform apply
```

Terraform creates both resources.

Now all three match.

```text
Terraform Configuration

VPC
Subnet

        │

        ▼

Terraform State

VPC
Subnet

        │

        ▼

AWS

VPC
Subnet
```

Terraform is happy because everything is in sync.

---

# What Causes Drift?

Infrastructure drift happens when **someone or something changes the cloud infrastructure outside of Terraform**.

Common causes include:

* Someone manually changes resources in the AWS Console.
* Someone uses the AWS CLI.
* Someone uses another Infrastructure as Code tool.
* An automated script modifies resources.
* A cloud service automatically changes a resource.

Terraform does not know about these changes until it checks the real infrastructure.

---

# Example of Drift

Suppose another engineer logs into AWS and manually creates another subnet.

AWS now contains:

* VPC
* Subnet A
* Subnet B

But your Terraform configuration still only defines:

* VPC
* Subnet A

Your state file also still knows only about:

* VPC
* Subnet A

Now you have drift.

```text
Terraform Configuration

VPC
Subnet A

        │

        ▼

Terraform State

VPC
Subnet A

        │

        ▼

AWS

VPC
Subnet A
Subnet B   ← Manual change
```

Terraform's memory no longer matches reality.

---

# Another Example

Suppose Terraform created this security group:

```text
Port 80

Port 443
```

Someone manually deletes Port 443 in AWS.

Now:

Configuration:

```text
80

443
```

State:

```text
80

443
```

AWS:

```text
80
```

Again, Terraform has drift because AWS no longer matches the configuration and state.

---

# What Happens When You Run terraform plan?

When you run:

```bash
terraform plan
```

Terraform performs these steps:

1. Reads your Terraform configuration.
2. Reads the state file.
3. Contacts the cloud provider.
4. Reads the actual infrastructure.
5. Compares all three.

```text
Configuration

↓

State

↓

AWS

↓

Compare Everything

↓

Generate a Plan
```

Terraform detects the differences and shows you what needs to change.

---

# Your Two Choices

Once Terraform detects drift, you generally have two choices.

## Option 1 – Revert the Cloud Back to Your Configuration

If the manual change was **not supposed to happen**, keep your Terraform code as it is.

Run:

```bash
terraform apply
```

Terraform changes the cloud infrastructure so it matches your configuration again.

Example:

Someone manually deleted Port 443.

Terraform sees that your configuration still requires Port 443.

Running:

```bash
terraform apply
```

will recreate that rule.

Result:

```text
Terraform Configuration ✔

↓

Terraform State ✔

↓

AWS ✔
```

Everything matches again.

---

## Option 2 – Accept the Manual Changes

Sometimes the manual change was intentional.

Instead of changing AWS back, you decide that the cloud infrastructure is now the correct version.

First, update your Terraform configuration so it reflects the new infrastructure.

Then run:

```bash
terraform apply -refresh-only
```

This command **refreshes Terraform's state** by reading the current infrastructure and updating the state file **without making infrastructure changes**.

For example, if someone changed an EC2 instance tag directly in AWS and you have also updated your Terraform configuration to match that new tag, `terraform apply -refresh-only` updates the state so Terraform's record matches AWS.

Afterwards:

```text
Terraform Configuration ✔

↓

Terraform State ✔

↓

AWS ✔
```

Everything is back in sync.

> **Important:** `terraform apply -refresh-only` updates the **state**, not your `.tf` files. If you want to permanently accept a manual change, you should also update your Terraform configuration. Otherwise, a future `terraform plan` will detect differences again and may try to change the infrastructure.

---

# Example Workflow

Initial state:

```text
Configuration

EC2 = t3.micro

↓

State

EC2 = t3.micro

↓

AWS

EC2 = t3.micro
```

Someone manually changes the instance type in AWS to:

```text
t3.small
```

Now:

```text
Configuration

t3.micro

↓

State

t3.micro

↓

AWS

t3.small
```

Running:

```bash
terraform plan
```

Terraform detects the drift.

Now you decide.

### Choice 1

Keep your original configuration.

Run:

```bash
terraform apply
```

Terraform changes AWS back to:

```text
t3.micro
```

---

### Choice 2

You decide the new instance type is correct.

Update your Terraform configuration:

```hcl
instance_type = "t3.small"
```

Then run:

```bash
terraform apply -refresh-only
```

Terraform updates the state to match AWS without modifying the infrastructure.

Now all three are consistent again.

---

# Best Practices

* Avoid making manual changes in the cloud console for resources managed by Terraform.
* Let Terraform be the single source of truth.
* Always run `terraform plan` before `terraform apply`.
* If manual changes are necessary, update your Terraform configuration to match them.
* Use `terraform apply -refresh-only` to refresh the state after your configuration has been updated to reflect the real infrastructure.
* Review drift carefully before deciding whether to revert it or accept it.

---

# Key Points to Remember

* Infrastructure drift happens when the real cloud infrastructure no longer matches Terraform's configuration or state.
* Drift is usually caused by manual changes made outside of Terraform.
* `terraform plan` detects drift by comparing your configuration, the state file, and the actual infrastructure.
* If the manual change is unwanted, use `terraform apply` to make the cloud match your configuration again.
* If the manual change should be kept, update your Terraform configuration first, then use `terraform apply -refresh-only` to update the state file without changing the infrastructure.
* The goal is always to keep your **Terraform configuration**, **Terraform state**, and **cloud infrastructure** in sync.
