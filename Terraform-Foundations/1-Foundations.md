# Introduction to Terraform

## What is Terraform?

**Terraform** is an **Infrastructure as Code (IaC)** tool created by **HashiCorp**.

Instead of creating cloud resources by clicking through the AWS, Azure, or Google Cloud console, you write code that describes the infrastructure you want. Terraform then creates that infrastructure for you.

Terraform uses its own language called **HashiCorp Configuration Language (HCL)**, which is designed to be simple and easy to read.

---

# What is Infrastructure?

Infrastructure is everything your application needs to run in the cloud.

Examples include:

* Virtual Machines (EC2)
* VPCs (Virtual Private Clouds)
* Subnets
* Security Groups
* Load Balancers
* S3 Buckets
* Databases
* DNS Records
* Kubernetes Clusters

Instead of creating these manually, Terraform creates them automatically.

---

# What is Infrastructure as Code (IaC)?

Infrastructure as Code (IaC) means managing and creating infrastructure using code instead of manually clicking through a web console.

Think of it like this:

### Without Terraform

1. Log into AWS.
2. Create a VPC.
3. Create Subnets.
4. Create an Internet Gateway.
5. Create Route Tables.
6. Create Security Groups.
7. Launch an EC2 instance.
8. Configure everything manually.

This can take **30–60 minutes**, and it's easy to make mistakes.

---

### With Terraform

You simply write a configuration file like this:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"
}
```

Then run:

```bash
terraform apply
```

Terraform automatically creates the resources for you.

---

# How Does Terraform Help?

Imagine you're building a house.

### Without Terraform

You build everything by hand every single time.

If you forget something, you have to go back and fix it.

If someone asks you to build the exact same house somewhere else, you have to start over from scratch.

---

### With Terraform

You first create a **blueprint** (your Terraform code).

Whenever you want another identical house, you simply reuse the same blueprint.

Terraform follows your blueprint exactly.

---

# Why Do Companies Use Terraform?

## 1. Saves Time

Instead of spending an hour clicking through the AWS Console, Terraform can create the same infrastructure in just a few minutes.

---

## 2. Reduces Human Errors

Manual work often leads to mistakes.

For example:

* Wrong VPC
* Wrong Security Group
* Wrong Region
* Forgot to create a Subnet
* Opened the wrong port

Terraform creates exactly what you wrote in your code.

No extra resources.

No missing resources.

---

## 3. Easy to Reuse

Suppose you built this infrastructure:

* 1 VPC
* 2 Public Subnets
* 2 Private Subnets
* 1 EC2 Instance
* 1 RDS Database

Now your company needs the same setup in another AWS account.

Without Terraform:

You repeat all the manual work.

With Terraform:

Just run the same code in the new account.

Terraform recreates the exact same infrastructure.

---

## 4. Easy to Scale

Need one EC2 instance today?

Tomorrow you need five?

Simply change:

```hcl
count = 1
```

to

```hcl
count = 5
```

Run:

```bash
terraform apply
```

Terraform automatically creates the additional instances.

---

## 5. Easy to Delete Resources

Finished using your lab environment?

Instead of deleting every resource manually, run:

```bash
terraform destroy
```

Terraform removes everything it created.

This helps prevent paying for resources you no longer need.

---

## 6. Version Control

Terraform files are plain text, so they can be stored in Git or GitHub.

This allows your team to:

* Track every change
* See who changed the infrastructure
* Review changes before deployment
* Restore older versions if needed

Just like application code, infrastructure can also be version controlled.

---

## 7. Team Collaboration

Since the infrastructure is written in code, every team member can understand exactly what has been deployed.

Everyone works from the same source of truth.

This makes collaboration much easier.

---

## 8. Multi-Cloud Support

Terraform is not limited to AWS.

It supports hundreds of providers.

Some popular ones include:

* AWS
* Microsoft Azure
* Google Cloud Platform (GCP)
* Kubernetes
* Docker
* GitHub
* Cloudflare
* VMware

The overall workflow stays the same. Only the resource names change depending on the provider.

---

# Simple Workflow

```
Write Terraform Code
        │
        ▼
terraform init
        │
        ▼
terraform plan
        │
        ▼
terraform apply
        │
        ▼
Infrastructure Created
```

---

# Real-World Example

Imagine a company needs:

* 1 VPC
* 3 EC2 Instances
* 1 Load Balancer
* 1 RDS Database
* 1 S3 Bucket
* Security Groups
* IAM Roles

Without Terraform:

A cloud engineer may spend hours creating and configuring everything manually.

With Terraform:

The engineer writes the infrastructure once.

Whenever another environment is needed (Development, Testing, or Production), they simply run the same Terraform code.

Terraform recreates the entire environment automatically.

---

# Advantages of Terraform

* Infrastructure is managed using code.
* Saves a significant amount of time.
* Reduces manual work and human errors.
* Easy to reuse across multiple environments.
* Supports version control with Git.
* Makes team collaboration easier.
* Can provision infrastructure across multiple cloud providers.
* Makes scaling infrastructure simple.
* Easily creates and destroys resources.
* Infrastructure becomes repeatable, consistent, and predictable.

---

# Key Terms to Remember

| Term                                       | Meaning                                                                                            |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| **Terraform**                              | An Infrastructure as Code (IaC) tool used to create and manage infrastructure.                     |
| **HashiCorp**                              | The company that created Terraform.                                                                |
| **HCL (HashiCorp Configuration Language)** | The language used to write Terraform configuration files.                                          |
| **Infrastructure**                         | Cloud resources such as EC2 instances, VPCs, databases, and storage.                               |
| **Infrastructure as Code (IaC)**           | Managing infrastructure by writing code instead of creating it manually.                           |
| **Provider**                               | A plugin that allows Terraform to interact with a specific platform, such as AWS or Azure.         |
| **Resource**                               | An individual infrastructure component created by Terraform, such as an EC2 instance or S3 bucket. |

---

# Summary

Terraform is a powerful Infrastructure as Code tool that allows you to create, modify, and delete cloud infrastructure using simple configuration files. Instead of manually clicking through cloud consoles, you define your desired infrastructure in code, and Terraform automatically builds it for you. This approach saves time, reduces mistakes, improves collaboration, supports version control, and makes infrastructure consistent and repeatable across multiple environments and cloud providers.
