# Terraform `moved` Block

## What is a `moved` Block?

As your Terraform projects grow, your code will also evolve.

You may decide to:

* Use more meaningful resource names.
* Reorganize resources into modules.
* Split a large Terraform file into smaller files.
* Improve the overall structure of your Infrastructure as Code.

When this happens, the **Terraform resource address** changes even though the actual infrastructure has not changed.

The **`moved` block** tells Terraform:

> **"This resource has not been deleted. I only changed its location or name in my Terraform configuration."**

Instead of destroying and recreating the resource, Terraform simply updates its **state file** to point to the new resource address.

---

# Why Do We Need a `moved` Block?

Imagine you created an EC2 instance.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t3.micro"
}
```

Terraform state contains:

```text
aws_instance.web
```

Months later your infrastructure grows.

Now you have:

* frontend
* backend
* database

The name **web** is no longer descriptive.

You rename it.

```hcl
resource "aws_instance" "frontend" {
  ami           = "ami-123456"
  instance_type = "t3.micro"
}
```

Nothing changed in AWS.

The EC2 instance is still exactly the same.

Only the Terraform name changed.

---

# What Happens Without a `moved` Block?

Terraform compares:

### Current State

```text
aws_instance.web
```

### Current Configuration

```text
aws_instance.frontend
```

Terraform thinks:

```text
The old resource disappeared.

A completely new resource appeared.
```

So the plan becomes:

```text
- Destroy aws_instance.web

+ Create aws_instance.frontend
```

That is dangerous.

You could accidentally destroy a production EC2 instance simply because you renamed it.

---

# What Happens With a `moved` Block?

Add:

```hcl
moved {
  from = aws_instance.web
  to   = aws_instance.frontend
}
```

Terraform now understands:

```text
Old Address

aws_instance.web

↓

Same EC2 Instance

↓

New Address

aws_instance.frontend
```

Now the plan becomes:

```text
Move state entry

No infrastructure changes
```

The EC2 instance keeps running.

No recreation.

No downtime.

No data loss.

Only the Terraform state is updated.

---

# Syntax

A moved block has only **two arguments**.

```hcl
moved {

  from = <old_address>

  to = <new_address>

}
```

**from**

The current resource address stored in the state.

**to**

The new resource address in your Terraform configuration.

---

# Example 1 - Renaming an EC2 Instance

Old configuration

```hcl
resource "aws_instance" "web" {

  ami = "ami-123456"

  instance_type = "t3.micro"

}
```

New configuration

```hcl
resource "aws_instance" "frontend" {

  ami = "ami-123456"

  instance_type = "t3.micro"

}
```

Add:

```hcl
moved {

  from = aws_instance.web

  to = aws_instance.frontend

}
```

Terraform updates the state from:

```text
aws_instance.web
```

to

```text
aws_instance.frontend
```

Nothing changes in AWS.

---

# Example 2 - Moving into a Module

Initially:

```text
aws_vpc.main
```

Later your code becomes:

```text
module.network.aws_vpc.main
```

Instead of recreating the VPC:

```hcl
moved {

  from = aws_vpc.main

  to = module.network.aws_vpc.main

}
```

Terraform updates only the state.

The VPC remains exactly the same.

---

# What Actually Changes?

Suppose AWS currently has:

```text
VPC

ID:

vpc-12345
```

Before moving:

State

```text
aws_vpc.main

↓

vpc-12345
```

After moving:

State

```text
module.network.aws_vpc.main

↓

vpc-12345
```

Notice something important.

The VPC ID never changed.

Terraform simply changed **where it keeps the reference**.

---

# The Cloud Infrastructure Never Changes

Many beginners think the moved block changes AWS.

It does **not**.

The only thing Terraform changes is the **state file**.

Think of it like renaming a contact in your phone.

Before:

```text
John
```

After:

```text
John Smith
```

The person never changed.

Only the name stored in your contacts changed.

The moved block works exactly the same way.

---

# Resource Referencing After Renaming

This is one of the most important concepts to understand.

Suppose you originally had:

```hcl
resource "aws_instance" "web" {

}
```

Another resource references it.

```hcl
resource "aws_eip" "public_ip" {

  instance = aws_instance.web.id

}
```

Later you rename the EC2 resource.

```hcl
resource "aws_instance" "frontend" {

}
```

Now every reference must also change.

Instead of:

```hcl
aws_instance.web.id
```

you write:

```hcl
aws_instance.frontend.id
```

The **resource address** has changed.

Terraform uses the moved block to understand that the old address and new address point to the same real EC2 instance.

---

# Why Doesn't the Reference Stay the Same?

Terraform references resources by their **resource address**, not by the AWS resource ID.

The resource address consists of:

```text
<Resource Type>.<Local Name>
```

Example:

```text
aws_instance.web
```

When you rename:

```text
web
```

to

```text
frontend
```

the address changes.

Therefore every reference must use the new address.

---

# Example of Resource Referencing

Before

```hcl
resource "aws_vpc" "main" {

}
```

Subnet:

```hcl
resource "aws_subnet" "public" {

  vpc_id = aws_vpc.main.id

}
```

After renaming:

```hcl
resource "aws_vpc" "production" {

}
```

Reference becomes:

```hcl
resource "aws_subnet" "public" {

  vpc_id = aws_vpc.production.id

}
```

Terraform still connects to exactly the same VPC.

The moved block updates the state.

The reference updates in your code.

Everything continues working.

---

# How Does Terraform Know It Is the Same Resource?

During `terraform apply` Terraform reads:

```hcl
moved {

  from = aws_instance.web

  to = aws_instance.frontend

}
```

Terraform performs these steps:

1. Looks inside the state file.
2. Finds `aws_instance.web`.
3. Changes its address to `aws_instance.frontend`.
4. Updates every dependency that points to the moved resource.
5. Continues planning using the new address.

No AWS API call is made to delete or recreate the EC2 instance.

---

# Can You Move Between Different Resource Types?

No.

For example:

This is **not allowed**.

```text
aws_instance.web

↓

aws_s3_bucket.web
```

An EC2 instance cannot suddenly become an S3 bucket.

The resource type must remain compatible.

---

# The Resource Must Already Exist

A moved block only works if Terraform is already managing the resource.

For example:

State contains:

```text
aws_instance.web
```

Then this works.

```hcl
moved {

  from = aws_instance.web

  to = aws_instance.frontend

}
```

But if Terraform has never managed:

```text
aws_instance.web
```

there is nothing to move.

Terraform will return an error.

A moved block cannot create new resources.

---

# Do I Keep the `moved` Block Forever?

Usually, **no**.

The typical workflow is:

### Step 1

Current configuration

```text
aws_instance.web
```

---

### Step 2

Rename the resource.

```text
aws_instance.frontend
```

---

### Step 3

Add the moved block.

```hcl
moved {

  from = aws_instance.web

  to = aws_instance.frontend

}
```

---

### Step 4

Run:

```bash
terraform apply
```

Terraform updates the state.

---

### Step 5

The move is complete.

The state now stores:

```text
aws_instance.frontend
```

---

### Step 6

The `moved` block has done its job.

You can safely remove it from your configuration because Terraform no longer needs instructions for a move that has already happened.

> **Exception:** If you maintain a reusable module that other teams may upgrade from older versions, you may keep `moved` blocks for longer to help users upgrade safely.

---

# Best Practices

* Use meaningful resource names from the beginning, but don't be afraid to rename them as your project grows.
* Always add a `moved` block when changing a Terraform resource address.
* Update every resource reference (`aws_instance.web.id` → `aws_instance.frontend.id`) to use the new address.
* Run `terraform plan` before applying changes to verify Terraform shows a move instead of a destroy/create operation.
* Remove the `moved` block after it has served its purpose, unless you're intentionally supporting upgrades for users of a shared module.

---

# Key Points to Remember

* A **`moved` block** tells Terraform that a resource has been renamed or relocated in the configuration.
* It updates only the **Terraform state file**—it does **not** modify, delete, or recreate infrastructure in the cloud.
* A moved block has two arguments: `from` (old resource address) and `to` (new resource address).
* After renaming a resource, **all resource references** in your code must also be updated to use the new address.
* The resource must already exist in Terraform state before it can be moved.
* After a successful `terraform apply`, the moved block has completed its job and can usually be removed.
