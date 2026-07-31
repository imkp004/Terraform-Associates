# Terraform `destroy`

## What is `terraform destroy`?

`terraform destroy` is the command used to **delete all infrastructure that is currently managed by Terraform**.

It is used when you no longer need the resources created by your Terraform project and want to clean up everything.

Run:

```bash
terraform destroy
```

Terraform will find all resources recorded in the Terraform state file and remove them.

Examples of resources it can destroy:

* EC2 instances
* S3 buckets
* VPCs
* Subnets
* Security groups
* Databases
* Load balancers
* IAM roles
* Any other resources managed by Terraform

---

# What Happens When You Run `terraform destroy`?

When you execute:

```bash
terraform destroy
```

Terraform performs several steps.

---

## Step 1 - Read the Terraform Configuration

Terraform reads your `.tf` files.

It identifies the resources that belong to the project.

---

## Step 2 - Read the State File

Terraform checks the state file:

```text
terraform.tfstate
```

The state file tells Terraform:

* What resources it created.
* The IDs of those resources.
* What resources it currently manages.

Example:

```text
terraform.tfstate

Resources:

aws_vpc.main
aws_subnet.public
aws_instance.web
aws_s3_bucket.logs
```

---

## Step 3 - Connect to the Provider

Terraform communicates with your cloud provider:

Example:

* AWS
* Azure
* Google Cloud
* GitHub

It verifies the resources that currently exist.

---

## Step 4 - Create a Destruction Plan

Before deleting anything, Terraform shows you what it plans to destroy.

Example:

```text
Terraform will perform the following actions:

  - destroy aws_instance.web

  - destroy aws_subnet.public

  - destroy aws_vpc.main


Plan: 0 to add, 0 to change, 3 to destroy.
```

Terraform then asks:

```text
Do you really want to destroy all resources?

Enter a value:
```

You must type:

```text
yes
```

to continue.

If you type:

```text
no
```

Terraform cancels the operation.

---

# What Does Terraform Destroy?

Terraform destroys **everything it manages in the current state file**.

Example:

Your Terraform project created:

```text
VPC

Subnet

EC2 Instance

S3 Bucket
```

Your state file contains:

```text
terraform.tfstate

VPC
Subnet
EC2
S3
```

When you run:

```bash
terraform destroy
```

Terraform deletes all of them.

---

# Destroy Order (Reverse Dependency Order)

Terraform does not randomly delete resources.

It uses the Resource Graph and destroys resources in the **opposite order of creation**.

Why?

Because dependencies must be removed safely.

---

## Example Creation Order

Terraform creates:

```text
VPC
 |
 ▼
Subnet
 |
 ▼
EC2 Instance
```

The EC2 instance depends on the subnet.

The subnet depends on the VPC.

---

## Destroy Order

Terraform destroys:

```text
EC2 Instance
 |
 ▼
Subnet
 |
 ▼
VPC
```

It removes the resources that depend on others first.

---

# Real AWS Example

Imagine you have:

```text
Internet Gateway
        |
        ▼
VPC
        |
        ▼
Subnet
        |
        ▼
EC2 Instance
```

Terraform destroys:

1. EC2 Instance
2. Subnet
3. Internet Gateway
4. VPC

This prevents dependency errors.

---

# Does Terraform Destroy the State File?

No, Terraform does not delete the state file itself.

Instead, Terraform removes the resources from the state.

Before destroy:

```text
terraform.tfstate

aws_vpc.main
aws_subnet.public
aws_instance.web
```

After destroy:

```text
terraform.tfstate

(empty)
```

The state file still exists, but Terraform is no longer managing any resources because they no longer exist.

---

# What Happens After Destroy?

After a successful destroy:

Your cloud account:

```text
No Terraform-managed resources
```

Your state file:

```text
No tracked resources
```

Terraform now has nothing to manage.

If you run:

```bash
terraform plan
```

Terraform will show:

```text
No changes.
```

because there is no infrastructure to manage.

---

# Is `terraform destroy` Reversible?

No.

`terraform destroy` is a destructive operation.

Once resources are deleted:

* EC2 instances are gone.
* Databases may be deleted.
* Storage may be removed.
* Network configuration disappears.

Terraform does not have an "undo" button.

Example:

You run:

```bash
terraform destroy
```

Your database is deleted.

Terraform cannot restore your data automatically.

---

# Important: Backup Before Destroy

Before destroying important infrastructure:

* Backup databases.
* Export important files.
* Verify snapshots exist.
* Confirm the resources are not needed anymore.

Example:

Before destroying an RDS database:

```text
Create database snapshot
Verify backup exists
Then destroy
```

---

# Safer Alternative: Remove Specific Resources

Sometimes you do not want to delete everything.

Example:

Your Terraform project manages:

```text
EC2
S3 Bucket
RDS Database
```

You only want to remove the EC2 instance.

Instead of:

```bash
terraform destroy
```

you can:

1. Remove the EC2 resource block from your Terraform code.

Example:

Before:

```hcl
resource "aws_instance" "web" {

}
```

After:

```hcl
# EC2 resource removed
```

2. Run:

```bash
terraform plan
```

Terraform shows:

```text
- aws_instance.web
```

3. Apply:

```bash
terraform apply
```

Terraform deletes only the EC2 instance.

The S3 bucket and database remain.

---

# Why Is This Safer?

Because you control exactly what Terraform removes.

You avoid accidentally deleting:

* Production databases.
* Networking infrastructure.
* Important storage.
* Security configurations.

---

# `terraform destroy` vs Removing Resource Blocks

| Method                                    | Result                                      |
| ----------------------------------------- | ------------------------------------------- |
| `terraform destroy`                       | Deletes everything Terraform manages        |
| Remove resource block + `terraform apply` | Deletes only that resource                  |
| `terraform destroy -target`               | Deletes a specific resource (use carefully) |

---

# Destroy Specific Resource

Terraform allows targeting a specific resource:

Example:

```bash
terraform destroy -target aws_instance.web
```

This destroys only:

```text
aws_instance.web
```

However, HashiCorp recommends avoiding `-target` for normal workflows because it can create unexpected state situations.

Prefer modifying your configuration and applying changes normally.

---

# Best Practices

Before running `terraform destroy`:

* Confirm you are in the correct Terraform directory.
* Run `terraform plan -destroy` first.
* Review exactly what will be deleted.
* Make backups of important data.
* Never run destroy commands directly in production without approval.
* Use separate environments (development, staging, production).
* Use version control so infrastructure changes are tracked.

---

# Preview Destroy Without Actually Destroying

You can see what Terraform would delete without performing it:

```bash
terraform plan -destroy
```

Example output:

```text
Plan:

- aws_instance.web
- aws_vpc.main
- aws_s3_bucket.logs
```

Nothing is deleted.

It is only a preview.

---

# Key Points to Remember

* `terraform destroy` deletes all resources managed by Terraform.
* It only deletes resources stored in the Terraform state.
* Terraform creates a destruction plan before deleting anything.
* It requires confirmation unless using `-auto-approve`.
* Resources are destroyed in reverse dependency order.
* Terraform removes destroyed resources from the state file.
* The state file itself is not deleted.
* Destroy is irreversible; deleted resources may not be recoverable.
* Always backup important data before destroying infrastructure.
* If you only want to delete specific resources, remove their Terraform blocks and run `terraform apply`.

---

# Summary

`terraform destroy` is Terraform's cleanup command. It removes all infrastructure that Terraform currently manages by reading the state file, creating a destruction plan, and deleting resources in the correct dependency order. It safely removes dependent resources first, such as deleting an EC2 instance before deleting its subnet or VPC. Because destruction is permanent, it should always be reviewed carefully, tested in non-production environments, and used only when you are certain the resources are no longer needed.
