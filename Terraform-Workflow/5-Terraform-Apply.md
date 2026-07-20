# Terraform `apply`

## What is `terraform apply`?

`terraform apply` is the command that **creates, updates, or destroys your real infrastructure**.

This is the command where Terraform actually makes changes to your cloud environment.

Until this point:

* `terraform init` prepared your project.
* `terraform plan` showed you what Terraform **would** do.

Now, `terraform apply` takes that plan and executes it.

Run:

```bash
terraform apply
```

This is the command that provisions real infrastructure in AWS, Azure, GCP, GitHub, Docker, or whichever provider you are using.

---

# The Terraform Workflow

The normal Terraform workflow is:

```text
Write Configuration
        │
        ▼
terraform init
        │
        ▼
terraform plan
        │
        ▼
Review the Changes
        │
        ▼
terraform apply
        │
        ▼
Infrastructure Created
```

---

# What Happens When You Run `terraform apply`?

When you execute:

```bash
terraform apply
```

Terraform performs several steps.

### Step 1 - Read the Configuration

Terraform reads every `.tf` file in the current directory.

It builds your desired infrastructure.

---

### Step 2 - Read the State File

Terraform reads the current Terraform state.

For example:

```text
terraform.tfstate
```

or

a remote state stored in:

* AWS S3
* Terraform Cloud
* Azure Storage
* Google Cloud Storage

The state tells Terraform what infrastructure it currently manages.

---

### Step 3 - Contact the Cloud Provider

Terraform connects to your provider.

For example:

* AWS
* Azure
* Google Cloud
* GitHub

It checks the current infrastructure to make sure everything is up to date.

---

### Step 4 - Generate an Execution Plan

If you didn't supply a saved plan file, Terraform generates a plan automatically.

You'll see something similar to:

```text
Plan: 3 to add, 1 to change, 0 to destroy.
```

Terraform then asks:

```text
Do you want to perform these actions?

  Terraform will perform the actions described above.

  Enter a value:
```

You answer:

```text
yes
```

or

```text
no
```

If you type:

```text
yes
```

Terraform begins creating, modifying, or deleting resources.

If you type:

```text
no
```

Terraform exits without making any changes.

---

# What Does Terraform Compare?

Terraform compares two things.

## Current State

What currently exists.

Example:

```text
Current Infrastructure

EC2 Instance

S3 Bucket
```

---

## Desired State

What your Terraform code says should exist.

Example:

```text
EC2 Instance

S3 Bucket

RDS Database
```

Terraform notices:

```text
Current

EC2

S3

Desired

EC2

S3

RDS
```

The difference is:

```text
Create RDS
```

Terraform creates only the missing resource.

---

# This Is the Command That Creates Real Infrastructure

Unlike:

```bash
terraform init
```

or

```bash
terraform plan
```

`terraform apply` performs real operations.

For example, it can:

* Create EC2 instances
* Create S3 buckets
* Create VPCs
* Create IAM roles
* Create Kubernetes clusters
* Delete resources
* Modify existing infrastructure

This is why you should always review the plan carefully before applying.

---

# State Locking

One of Terraform's most important safety features is **state locking**.

When Terraform starts an `apply`, it **locks the state file**.

The purpose is to prevent multiple people from modifying the same infrastructure at the same time.

---

## Why Is State Locking Needed?

Imagine two engineers working on the same project.

### Engineer A

Runs:

```bash
terraform apply
```

Terraform starts creating resources.

---

### Engineer B

One minute later runs:

```bash
terraform apply
```

Without state locking:

Both engineers would be modifying the same infrastructure simultaneously.

Problems could include:

* Duplicate resources
* Corrupted state
* Lost updates
* Infrastructure drift
* Unexpected failures

---

## What Actually Happens?

When Engineer A starts:

```bash
terraform apply
```

Terraform places a **lock** on the state file.

Think of it like locking a door.

```text
State File

🔒 Locked

Engineer A is making changes...
```

Now Engineer B runs:

```bash
terraform apply
```

Terraform responds with an error similar to:

```text
Error:

Error acquiring the state lock.
```

Terraform refuses to continue because another operation is already in progress.

Engineer B must wait until Engineer A finishes.

Once Engineer A completes successfully, Terraform unlocks the state.

Now Engineer B can run:

```bash
terraform apply
```

---

## Where Is the Lock Stored?

It depends on your backend.

Examples:

| Backend              | Lock Location                        |
| -------------------- | ------------------------------------ |
| Local State          | Local lock file (limited protection) |
| AWS S3 + DynamoDB    | DynamoDB table                       |
| Terraform Cloud      | Managed automatically                |
| Azure Storage        | Blob lease                           |
| Google Cloud Storage | Generation-based locking             |

---

## Real-World Example

Suppose a team has five DevOps engineers.

Everyone works on the same infrastructure.

If all five engineers could apply changes at the same time:

```text
Engineer A → Creating EC2

Engineer B → Deleting VPC

Engineer C → Updating IAM

Engineer D → Creating Database

Engineer E → Updating Security Groups
```

The infrastructure could become inconsistent.

Instead Terraform allows only one active operation at a time.

Everyone else waits until the lock is released.

---

# Updating the State File

After Terraform successfully creates a resource, it immediately updates the state file.

For example:

Terraform creates:

```text
EC2 Instance
```

Then updates:

```text
terraform.tfstate
```

Terraform creates:

```text
S3 Bucket
```

Then updates:

```text
terraform.tfstate
```

Terraform creates:

```text
VPC
```

Again, the state file is updated.

The state file always reflects what Terraform successfully created.

---

# What Happens If `terraform apply` Fails?

Suppose Terraform needs to create four resources.

```text
1. VPC

2. Subnet

3. EC2

4. RDS
```

Terraform starts:

```text
✔ VPC Created

✔ Subnet Created

❌ EC2 Failed

RDS Never Started
```

What happens?

Terraform updates the state file with the resources that were successfully created.

So the state now contains:

```text
VPC

Subnet
```

The failed EC2 instance is **not** added because it was never created successfully.

---

# Does Terraform Roll Back?

**No.**

Terraform does **not** automatically roll back successful resources if a later resource fails.

This is a very important concept.

Suppose:

```text
Create VPC

✔ Success

Create Subnet

✔ Success

Create EC2

❌ Failed
```

Terraform leaves:

```text
VPC

Subnet
```

in your AWS account.

It does **not** delete them automatically.

Why?

Because Terraform follows a **declarative model**.

Its goal is to make the infrastructure match your desired configuration—not to automatically undo partial success.

After you fix the problem, you simply run:

```bash
terraform apply
```

again.

Terraform sees that the VPC and subnet already exist (because they are in the state file) and only retries creating the missing EC2 instance.

---

# Different Ways to Run `terraform apply`

## Standard Apply

```bash
terraform apply
```

Terraform creates a plan, shows it to you, and asks for confirmation.

---

## Apply a Saved Plan

Earlier you can save a plan:

```bash
terraform plan -out=myplan
```

Later you apply it:

```bash
terraform apply myplan
```

Terraform executes the exact instructions stored in the saved plan file.

It does **not** regenerate the plan or reread your updated configuration files.

---

## Auto Approve

```bash
terraform apply -auto-approve
```

Terraform skips the confirmation prompt.

Instead of asking:

```text
Do you want to perform these actions?
```

Terraform immediately begins making changes.

### Why Is This Dangerous?

If your configuration contains a mistake, Terraform will still execute it.

For example, if the plan includes deleting a production database, `-auto-approve` will not stop to ask for confirmation.

Because of this, `-auto-approve` should be used carefully, typically in trusted automation such as CI/CD pipelines where the plan has already been reviewed.

---

# Best Practices

Before running `terraform apply`, follow these best practices:

* Always run `terraform plan` first and carefully review the output.
* Make sure you are in the correct project directory before applying changes.
* Test your Terraform code in a development or staging environment before deploying to production.
* Be patient with large applies—some resources (such as databases, Kubernetes clusters, or load balancers) can take several minutes to provision.
* After the apply completes, verify that the resources were created successfully in your cloud provider's console or using CLI commands.
* Store your Terraform code in version control (such as GitHub) so changes are tracked and can be reviewed by your team.
* Use a remote backend with state locking when working in a team environment.

---

# Key Points to Remember

* `terraform apply` is the command that creates, updates, or destroys real infrastructure.
* It compares the desired configuration with the current infrastructure and Terraform state.
* By default, Terraform shows the execution plan and asks for confirmation before making changes.
* Terraform locks the state file during an apply so only one operation can modify the infrastructure at a time.
* After successfully creating or updating resources, Terraform immediately updates the state file.
* If an apply fails partway through, successfully created resources remain in place and are recorded in the state file.
* Terraform **does not** automatically roll back successful resources when a later resource fails.
* You can apply a previously saved plan using `terraform apply <plan-file>`.
* The `-auto-approve` option skips the confirmation prompt and should be used with caution.

---

# Summary

`terraform apply` is the command that turns your Terraform configuration into real infrastructure. It reads your configuration, compares it with the current state of your infrastructure, generates (or uses) an execution plan, and then creates, updates, or destroys resources to match your desired state. During the operation, Terraform locks the state file to prevent other users from making simultaneous changes, updates the state as resources are successfully created, and leaves successful resources in place if a later step fails. This predictable and declarative approach is one of the reasons Terraform is widely used to manage cloud infrastructure safely and consistently.
