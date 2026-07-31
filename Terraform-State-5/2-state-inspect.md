# Inspecting the Terraform State

Once Terraform has created your infrastructure, you may want to see **what Terraform is currently managing**.

Terraform provides several commands to inspect the state without making any changes.

These commands are **read-only**. They do **not** create, modify, or destroy any infrastructure.

The two most commonly used commands are:

* `terraform state list`
* `terraform show`

---

# terraform state list

## What does it do?

The `terraform state list` command displays **all the resources currently stored in the Terraform state file**.

Think of it as the **`ls` command in Linux**, but instead of listing files, it lists all the infrastructure resources Terraform is managing.

It only shows the **resource addresses**, not all of their details.

---

## Syntax

```bash
terraform state list
```

---

## What is it used for?

This command is commonly used to:

* See what Terraform is currently managing.
* Verify that a resource was successfully created.
* Find the address of a resource.
* Check resources inside modules.
* Confirm whether a resource exists in the state before troubleshooting.

---

## Example

Suppose your Terraform project created:

* One VPC
* One Public Subnet
* One Security Group
* Two EC2 Instances

Running:

```bash
terraform state list
```

might return:

```text
aws_vpc.main

aws_subnet.public

aws_security_group.web_sg

aws_instance.web1

aws_instance.web2
```

Terraform is telling you:

> "These are all the resources I currently manage."

Notice that this command only shows the resource addresses.

It does **not** show:

* IDs
* IP addresses
* Tags
* Configuration
* Dependencies

It simply lists the resources.

---

## Understanding Resource Addresses

Each line has two parts:

```text
<Type>.<Local Name>
```

Example:

```text
aws_instance.web1
```

Breaking it down:

* `aws_instance` → Resource type supplied by the AWS provider.
* `web1` → The local name you gave the resource in your Terraform code.

Example configuration:

```hcl
resource "aws_instance" "web1" {

  ami           = "ami-123456789"

  instance_type = "t3.micro"

}
```

Terraform refers to this resource internally as:

```text
aws_instance.web1
```

This is called the **resource address**.

Many Terraform commands use this address.

---

## Resources Inside Modules

Suppose you have a module:

```hcl
module "network" {

  source = "./modules/network"

}
```

Inside that module there is a VPC.

Running:

```bash
terraform state list
```

may display:

```text
module.network.aws_vpc.main
```

Terraform includes the module name as part of the address.

---

# terraform show

## What does it do?

The `terraform show` command displays the **contents of the Terraform state file in a human-readable format**.

Unlike `terraform state list`, which only lists resource names, `terraform show` displays **all the stored information** about every managed resource.

Think of it like opening the state file and translating it into something people can easily read.

---

## Syntax

```bash
terraform show
```

---

## What is it used for?

It helps you:

* View all managed resources.
* Inspect resource configuration.
* View IDs.
* View IP addresses.
* View ARNs.
* View tags.
* View dependencies.
* View output values.
* Troubleshoot Terraform resources.

---

## Example

Suppose Terraform created this EC2 instance:

```hcl
resource "aws_instance" "web1" {

  ami           = "ami-123456"

  instance_type = "t3.micro"

}
```

Running:

```bash
terraform show
```

might display:

```text
resource "aws_instance" "web1" {

    id = "i-0abc123456789"

    ami = "ami-123456"

    instance_type = "t3.micro"

    availability_zone = "us-east-1a"

    private_ip = "10.0.1.25"

    public_ip = "44.201.15.30"

    tags = {

        Name = "Web Server"

    }

}
```

Notice how much more information is displayed compared to `terraform state list`.

Terraform is showing everything it knows about that resource.

---

# terraform state show

Sometimes you don't want to see the **entire** state file.

You only want information about **one specific resource**.

That is where `terraform state show` is useful.

---

## Syntax

```bash
terraform state show <resource_address>
```

Example:

```bash
terraform state show aws_vpc.main
```

---

## What does it do?

Instead of displaying every managed resource, Terraform displays **only the selected resource**.

This makes troubleshooting much easier.

---

## Example

Suppose your project contains:

```text
aws_vpc.main

aws_subnet.public

aws_security_group.web_sg

aws_instance.web1

aws_instance.web2
```

You only want information about the VPC.

Run:

```bash
terraform state show aws_vpc.main
```

Terraform might return:

```text
resource "aws_vpc" "main" {

    id = "vpc-0abc123456"

    cidr_block = "10.0.0.0/16"

    enable_dns_support = true

    enable_dns_hostnames = true

    arn = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-0abc123456"

    owner_id = "123456789012"

    tags = {

        Name = "Production-VPC"

    }

}
```

Now you can inspect just that resource without searching through hundreds of lines of output.

---

# Real-World Example

Imagine your infrastructure contains:

* 2 VPCs
* 12 Subnets
* 30 EC2 Instances
* 15 Security Groups
* 8 IAM Roles
* 4 Load Balancers

Running:

```bash
terraform show
```

could produce thousands of lines of output.

Instead, if you only need to inspect one EC2 instance, run:

```bash
terraform state show aws_instance.web1
```

Terraform immediately displays only that resource.

This is much faster and easier for troubleshooting.

---

# When Would You Use Each Command?

### terraform state list

Use when you want to know:

* What Terraform currently manages.
* Whether a resource exists.
* The resource address.
* Resources inside modules.

Example:

```bash
terraform state list
```

---

### terraform show

Use when you want to:

* View the complete state.
* Inspect every resource.
* Review outputs.
* Troubleshoot your infrastructure.

Example:

```bash
terraform show
```

---

### terraform state show

Use when you want to inspect one specific resource.

Example:

```bash
terraform state show aws_instance.web1
```

---

# Comparison

| Command                           | Purpose                                                           | Output                                       |
| --------------------------------- | ----------------------------------------------------------------- | -------------------------------------------- |
| `terraform state list`            | Lists every resource Terraform manages.                           | Resource addresses only.                     |
| `terraform show`                  | Displays the complete Terraform state in a human-readable format. | Full details for all resources.              |
| `terraform state show <resource>` | Displays detailed information for one specific resource.          | Full details for only the selected resource. |

---

# Key Points to Remember

* `terraform state list` is like the Linux `ls` command—it lists every resource Terraform manages.
* It displays **resource addresses**, not resource details.
* Resource addresses are used by many Terraform commands.
* `terraform show` displays the entire Terraform state in a human-readable format.
* `terraform state show` displays detailed information about a single resource.
* None of these commands modify your infrastructure—they are inspection and troubleshooting commands only.
* These commands are especially useful when debugging, verifying deployments, or learning how Terraform tracks your infrastructure.
