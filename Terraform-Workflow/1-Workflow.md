# The Terraform Workflow

Terraform follows a simple workflow to create and manage infrastructure. Understanding this workflow is one of the most important concepts when learning Terraform.

The **official Terraform workflow** consists of three main steps:

1. **Write**
2. **Plan**
3. **Apply**

However, before you can use `plan` or `apply`, there is one important setup step that almost every Terraform project requires:

**Initialize (`terraform init`)**

Although `terraform init` is not considered one of the three official workflow stages, you will almost always run it first.

---

# 1. Write

The first step is to **write your Terraform configuration**.

In this step, you describe the **desired state** of your infrastructure using **HashiCorp Configuration Language (HCL)**.

You are simply telling Terraform:

> "This is the infrastructure I want."

You are **not** telling Terraform **how** to create it.

For example, you might define:

* An EC2 instance
* An S3 bucket
* A VPC
* A Load Balancer
* A Security Group

Terraform reads your configuration and understands what your desired infrastructure should look like.

---

# 2. Initialize (`terraform init`)

Before Terraform can plan or create infrastructure, it must prepare the project.

This is done by running:

```bash
terraform init
```

Think of this as the **setup stage**.

Terraform prepares your project by:

* Reading your Terraform configuration files.
* Downloading the required providers.
* Downloading any required modules.
* Initializing the backend (if one is configured).
* Creating the `.terraform/` directory.
* Creating the `.terraform.lock.hcl` dependency lock file.

**Important:** `terraform init` does **not** create any infrastructure.

It simply gets everything ready for the next steps.

You usually run `terraform init`:

* When starting a new Terraform project.
* After cloning a Terraform project from Git.
* After adding a new provider.
* After adding a new module.
* After changing the backend configuration.

---

# 3. Plan

Once the project has been initialized, the next step is to preview what Terraform is going to do.

Run:

```bash
terraform plan
```

This command compares:

* Your **desired state** (the code you wrote)
* The **current state** (the infrastructure Terraform already manages)

Terraform then creates an **execution plan**.

The plan shows:

* What resources will be created.
* What resources will be modified.
* What resources will be destroyed.

Nothing is changed during this step.

It is simply a preview that allows you to review the changes before making them.

Think of `terraform plan` as a "dry run."

---

# 4. Apply

Once you have reviewed the plan and are satisfied with the changes, you can create or update your infrastructure by running:

```bash
terraform apply
```

Terraform will:

* Create new resources.
* Update existing resources.
* Remove resources if necessary.
* Save the current infrastructure state in the Terraform state file.

After a successful `terraform apply`, your cloud infrastructure matches the configuration you wrote in your Terraform files.

---

# Complete Workflow

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
Infrastructure Created or Updated
```

---

# Real-World Example

Suppose you want to create:

* One VPC
* One EC2 Instance
* One S3 Bucket

### Step 1 — Write

You write the Terraform code that describes these resources.

### Step 2 — Initialize

You run:

```bash
terraform init
```

Terraform downloads the AWS provider and prepares your project.

### Step 3 — Plan

You run:

```bash
terraform plan
```

Terraform displays:

```text
Plan: 3 to add, 0 to change, 0 to destroy.
```

This means Terraform will create three new resources.

### Step 4 — Apply

You run:

```bash
terraform apply
```

Terraform communicates with AWS and creates:

* VPC
* EC2 Instance
* S3 Bucket

It then updates the Terraform state file to keep track of the infrastructure.

---

# Key Points to Remember

* **Write** – Describe the desired infrastructure using HCL.
* **Initialize (`terraform init`)** – Prepare the project by downloading providers and modules and setting up the working directory.
* **Plan (`terraform plan`)** – Preview the changes Terraform intends to make.
* **Apply (`terraform apply`)** – Create, update, or remove infrastructure to match your configuration.

---

# Summary

Terraform follows a straightforward workflow: first you **write** the desired infrastructure in HCL, then **initialize** the project with `terraform init`, **preview** the changes using `terraform plan`, and finally **create or update** the infrastructure with `terraform apply`. Following this workflow helps ensure that your infrastructure changes are predictable, reviewed before execution, and managed consistently using Infrastructure as Code (IaC).
