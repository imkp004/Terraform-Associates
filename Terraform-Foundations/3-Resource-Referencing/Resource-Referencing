# Resource Referencing in Terraform

## What is Resource Referencing?

**Resource referencing** is the process of using one Terraform resource inside another resource.

Instead of typing the same value over and over again (also called **hardcoding**), you tell Terraform to use information from a resource that has already been created.

This makes your code cleaner, easier to maintain, and less likely to contain mistakes.

---

# Simple Example

Imagine you create a VPC.

Terraform gives it a unique ID like this:

```text
vpc-0a123456789abcdef
```

Now you want to create a subnet inside that VPC.

Instead of manually typing the VPC ID:

```hcl
vpc_id = "vpc-0a123456789abcdef"
```

You reference the VPC directly:

```hcl
vpc_id = aws_vpc.main.id
```

Terraform automatically gets the correct VPC ID for you.

---

# Think of It Like This

Imagine you're filling out a form.

Your name is already written at the top of the page.

Instead of writing your name 10 more times, you simply point to it.

Terraform works the same way.

Instead of repeating values, it **references** them.

---

# Why Do We Use Resource Referencing?

Without resource referencing:

* You have to manually copy IDs.
* You may accidentally type the wrong value.
* If something changes, you must update it everywhere.
* Your code becomes harder to maintain.

With resource referencing:

* Terraform gets the value automatically.
* No hardcoded values.
* Fewer mistakes.
* Cleaner and more reusable code.

---

# How Terraform Identifies a Resource

Every Terraform resource has two important parts:

1. **Resource Type**
2. **Resource Name**

Example:

```hcl
resource "aws_vpc" "main" {

}
```

Here:

* Resource Type → `aws_vpc`
* Resource Name → `main`

Terraform combines these to uniquely identify the resource.

You can then reference it anywhere in your code.

Example:

```hcl
aws_vpc.main.id
```

---

# General Syntax

Resource references follow this format:

```text
resource_type.resource_name.attribute
```

Example:

```hcl
aws_instance.web.public_ip
```

Breaking it down:

* `aws_instance` → Resource type
* `web` → Resource name
* `public_ip` → Attribute you want to use

---

# Example: VPC and Subnet

Create a VPC:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```

Now create a subnet:

```hcl
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
```

Notice this line:

```hcl
vpc_id = aws_vpc.main.id
```

The subnet is using the VPC's ID without you having to type it manually.

---

# Automatic Resource Order

One of Terraform's biggest advantages is that it automatically understands the order in which resources should be created.

For example:

```text
VPC
 │
 ▼
Subnet
 │
 ▼
EC2 Instance
```

Terraform knows:

1. Create the VPC first.
2. Create the subnet inside the VPC.
3. Launch the EC2 instance inside the subnet.

You **do not** have to tell Terraform the order.

Terraform figures it out automatically by looking at the resource references.

---

# What Happens Without Referencing?

Imagine writing this:

```hcl
vpc_id = "vpc-123456"
```

Later, you delete and recreate the VPC.

AWS gives it a new ID:

```text
vpc-987654
```

Now your Terraform code still points to the old VPC ID.

Your deployment will fail.

With resource referencing:

```hcl
vpc_id = aws_vpc.main.id
```

Terraform automatically uses the new VPC ID.

No changes are needed in your code.

---

# Real-World Example

Imagine your company has:

* 1 VPC
* 6 Subnets
* 4 EC2 Instances
* 2 Load Balancers
* 5 Security Groups

Every one of these resources depends on another.

Instead of manually copying IDs everywhere, Terraform uses resource references to connect them together automatically.

This keeps the infrastructure organized and easy to manage.

---

# Benefits of Resource Referencing

* Eliminates hardcoded values.
* Reduces human errors.
* Makes code easier to read.
* Automatically creates resources in the correct order.
* Makes code reusable.
* Makes infrastructure easier to maintain.
* Allows Terraform to understand dependencies between resources.

---

# Terraform Formatting (`terraform fmt`)

As your Terraform project grows, keeping the code neat and readable becomes important.

Terraform provides a built-in command called:

```bash
terraform fmt
```

This command automatically formats your Terraform files according to Terraform's standard style.

It helps make your code clean and consistent.

---

# What Does `terraform fmt` Do?

It automatically:

* Fixes indentation.
* Aligns equal (`=`) signs where appropriate.
* Removes unnecessary spaces.
* Formats nested blocks.
* Makes the code easier to read.

You don't have to format the code manually.

---

# Example

Before running `terraform fmt`:

```hcl
resource "aws_instance" "web" {
ami="ami-123456"
instance_type="t2.micro"
tags={
Name="Web Server"
}
}
```

After running:

```bash
terraform fmt
```

Terraform changes it to:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  tags = {
    Name = "Web Server"
  }
}
```

The code is now much easier to read.

---

# Does It Format All Files?

Yes.

When you run:

```bash
terraform fmt
```

Terraform automatically formats **all `.tf` files in the current directory**.

If it changes a file, it prints the filename in the terminal.

Example:

```text
main.tf
network.tf
outputs.tf
variables.tf
```

This tells you which files were formatted.

---

# Why Use `terraform fmt`?

Using `terraform fmt` is considered a Terraform best practice because it:

* Keeps your code clean.
* Makes your code consistent.
* Makes teamwork easier.
* Makes code reviews faster.
* Makes Terraform files look professional.

Most DevOps engineers run `terraform fmt` before committing their code to Git.

---

# Key Points to Remember

* Resource referencing means using one Terraform resource inside another resource.
* It helps avoid hardcoding values like IDs, names, or IP addresses.
* Resources are referenced using:

```text
resource_type.resource_name.attribute
```

Example:

```text
aws_vpc.main.id
```

* Terraform automatically understands dependencies between resources.
* Terraform creates resources in the correct order based on these references.
* `terraform fmt` automatically formats all `.tf` files in the current directory.
* Clean formatting improves readability, maintenance, and collaboration.

---

# Summary

Resource referencing allows Terraform resources to share information with each other instead of relying on hardcoded values. By referencing attributes such as IDs or names, Terraform automatically understands how resources are connected and creates them in the correct order. This makes your infrastructure code more reliable, reusable, and easier to maintain. To keep your code clean and consistent, Terraform provides the `terraform fmt` command, which automatically formats all Terraform configuration files according to standard best practices.
