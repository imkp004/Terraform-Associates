# Terraform Output Block

## What is an Output Block?

When Terraform finishes creating your infrastructure, a common question is:

> **"How do I know what Terraform created?"**

For example:

* What is my EC2 instance's public IP?
* What is the S3 bucket name?
* What is the VPC ID?
* What is my Load Balancer DNS name?
* What is my RDS endpoint?

You could manually log into AWS and search for this information.

However, that is slow, tedious, and doesn't scale.

Instead, Terraform provides **Output Blocks**.

An **output block** retrieves information from resources Terraform has created and displays it after deployment.

Think of an output block as Terraform saying:

> "Your infrastructure has been created. Here is the important information you probably need."

---

# Why Do We Need Output Blocks?

Imagine Terraform creates:

* 1 VPC
* 3 EC2 instances
* 2 Security Groups
* 1 Load Balancer
* 1 RDS Database

Terraform successfully creates everything.

Now you need:

* EC2 Public IP
* Database endpoint
* Load Balancer URL

Without output blocks, you would:

1. Open the AWS Console.
2. Navigate to EC2.
3. Find the instance.
4. Copy the Public IP.
5. Open RDS.
6. Copy the endpoint.
7. Open the Load Balancer.
8. Copy the DNS name.

That becomes repetitive, especially when deploying frequently.

Instead, Terraform prints the important information automatically.

---

# Real-World Analogy

Imagine ordering a new laptop online.

After delivery, the courier hands you a receipt containing:

* Order Number
* Tracking Number
* Delivery Address
* Payment Status

The courier doesn't hand you the entire warehouse inventory.

Only the information you need.

Terraform outputs work the same way.

They display only the information you choose.

---

# General Syntax

```hcl
output "<output_name>" {

  description = "Description of this output"

  value = <value>

}
```

Example:

```hcl
output "instance_public_ip" {

  description = "Public IP address of the EC2 instance"

  value = aws_instance.web.public_ip

}
```

---

# Parts of an Output Block

Example:

```hcl
output "instance_public_ip" {

  description = "Public IP address"

  value = aws_instance.web.public_ip

}
```

---

## output

Terraform keyword.

It tells Terraform:

> "Display this information after deployment."

---

## Output Name

```text
instance_public_ip
```

This is a name that **you choose**.

It is only used inside Terraform.

Choose meaningful names.

Good examples:

```text
instance_public_ip

database_endpoint

bucket_name

vpc_id

load_balancer_dns
```

Poor examples:

```text
abc

output1

thing

test
```

---

## Description

Descriptions explain what the output returns.

Example:

```hcl
description = "Public IP address of the web server"
```

Descriptions are especially helpful when many people work on the same Terraform project.

---

## Value

The **value** is the actual information Terraform will retrieve.

Usually this comes from:

* Resources
* Data sources
* Variables
* Modules
* Expressions

Example:

```hcl
value = aws_instance.web.public_ip
```

Terraform retrieves the EC2 instance's public IP and prints it.

---

# Example 1 – EC2 Public IP

Create an EC2 instance.

```hcl
resource "aws_instance" "web" {

  ami           = "ami-123456"

  instance_type = "t3.micro"

}
```

Output:

```hcl
output "public_ip" {

  value = aws_instance.web.public_ip

}
```

After:

```bash
terraform apply
```

Terraform displays:

```text
Apply complete!

Outputs:

public_ip = 54.213.100.25
```

You don't need to open AWS.

---

# Example 2 – S3 Bucket Name

```hcl
resource "aws_s3_bucket" "logs" {

  bucket = "company-logs"

}
```

Output:

```hcl
output "bucket_name" {

  value = aws_s3_bucket.logs.bucket

}
```

Terraform prints:

```text
bucket_name = company-logs
```

---

# Example 3 – VPC ID

```hcl
resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"

}
```

Output:

```hcl
output "vpc_id" {

  value = aws_vpc.main.id

}
```

Terraform displays:

```text
vpc_id = vpc-08f8d9ab12
```

---

# Example 4 – Database Endpoint

```hcl
resource "aws_db_instance" "database" {

  ...

}
```

Output:

```hcl
output "database_endpoint" {

  value = aws_db_instance.database.endpoint

}
```

Terraform prints:

```text
database_endpoint = database.xxxxx.us-east-1.rds.amazonaws.com
```

Now your application developers immediately know where to connect.

---

# Output Blocks Can Use Strings

Outputs are not limited to displaying a single value.

You can combine text with resource attributes.

Example:

```hcl
output "website_message" {

  value = "Your website is available at http://${aws_instance.web.public_ip}"

}
```

Terraform prints:

```text
website_message = Your website is available at http://54.213.100.25
```

This makes outputs much more user-friendly.

---

Another example:

```hcl
output "bucket_info" {

  value = "Bucket created successfully: ${aws_s3_bucket.logs.bucket}"

}
```

Output:

```text
Bucket created successfully: company-logs
```

---

# Output Blocks Appear After Apply

Whenever you run:

```bash
terraform apply
```

Terraform creates your infrastructure.

After everything finishes successfully, Terraform prints every output block.

Example:

```text
Apply complete!

Outputs:

public_ip = 54.213.100.25

bucket_name = company-backups

vpc_id = vpc-123456789
```

This is one reason outputs improve your workflow—you immediately receive the information you are likely to need next.

---

# Terraform Output Command

Even if you close your terminal, Terraform still remembers your outputs.

Why?

Because Terraform stores output values in the **state file**.

Later you can run:

```bash
terraform output
```

Example:

```text
public_ip = 54.213.100.25

bucket_name = company-backups

vpc_id = vpc-123456789
```

No need to run `terraform apply` again.

---

You can also request a specific output.

```bash
terraform output public_ip
```

Result:

```text
54.213.100.25
```

This is useful in scripts and automation.

---

# Output Values Come from the State File

Terraform does **not** query AWS every time you run:

```bash
terraform output
```

Instead, Terraform reads the values stored in its **terraform.tfstate** file.

Example:

```text
terraform apply

↓

Terraform creates EC2

↓

Terraform stores EC2 information in the state file

↓

terraform output

↓

Reads values from the state file
```

This makes retrieving outputs very fast.

---

# Sensitive Outputs

Some values should **not** be displayed on your screen.

Examples:

* Database passwords
* API keys
* Access tokens
* Secret keys
* Private connection strings

Terraform allows you to mark outputs as sensitive.

Example:

```hcl
output "database_password" {

  value = aws_db_instance.database.password

  sensitive = true

}
```

After `terraform apply`:

```text
database_password = <sensitive>
```

Terraform hides the value instead of displaying it.

This helps prevent accidental exposure of secrets.

> **Important:** The value is still stored in the Terraform state file. Marking an output as `sensitive` only hides it from normal CLI output. You should also protect your state file because it may still contain sensitive information.

---

# Output Blocks and Modules

Outputs are very important when working with **modules**.

Imagine you have a networking module.

It creates a VPC.

Other modules need the VPC ID.

Instead of searching for the VPC ID, the networking module exposes it as an output.

Network module:

```hcl
output "vpc_id" {

  value = aws_vpc.main.id

}
```

Another module can then use that output as an input.

This allows modules to communicate with each other without hardcoding values.

---

# Display Critical Information

Output blocks make it easy to display the information people actually need.

Examples include:

* EC2 Public IP
* Private IP
* Elastic IP
* Load Balancer DNS Name
* VPC ID
* Subnet IDs
* Security Group IDs
* S3 Bucket Name
* Database Endpoint
* CloudFront Domain Name
* IAM Role ARN

Instead of opening the cloud console every time, Terraform displays this information automatically.

---

# Enable Module Interaction

Large Terraform projects are usually split into modules.

For example:

```text
Network Module

↓

Compute Module

↓

Database Module
```

The network module creates a VPC.

The compute module needs the VPC ID.

The networking module outputs the VPC ID, and the compute module uses that value.

This keeps modules independent while allowing them to work together.

---

# Improve Workflow Efficiency

Without outputs:

```text
terraform apply

↓

Open AWS Console

↓

Find EC2

↓

Copy Public IP

↓

Find RDS

↓

Copy Endpoint

↓

Find S3 Bucket

↓

Copy Name
```

With outputs:

```text
terraform apply

↓

Terraform prints everything immediately

↓

Start using your infrastructure
```

This saves time, reduces manual work, and minimises mistakes.

---

# Best Practices

* Output only information that users actually need.
* Use clear and meaningful output names.
* Add descriptions to every output block.
* Mark passwords, tokens, and secrets as `sensitive`.
* Avoid outputting unnecessary information.
* Use outputs to connect modules together instead of hardcoding values.

---

# Key Points to Remember

* An output block retrieves and displays useful information about your infrastructure after deployment.
* Outputs save time by eliminating the need to manually search for resource details in the cloud console.
* Output values commonly include IDs, IP addresses, ARNs, DNS names, bucket names, and database endpoints.
* Outputs can reference resources, data sources, variables, modules, and expressions.
* Terraform automatically displays all outputs after a successful `terraform apply`.
* You can retrieve outputs later using the `terraform output` command because they are stored in the Terraform state file.
* Outputs can be customised with descriptive names, descriptions, and formatted strings.
* Mark sensitive outputs with `sensitive = true` to hide them from normal CLI output, while remembering that the values still exist in the state file.
* Output blocks are essential for allowing Terraform modules to share information cleanly and efficiently.
