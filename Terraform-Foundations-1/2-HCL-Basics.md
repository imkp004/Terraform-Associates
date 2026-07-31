# HashiCorp Configuration Language (HCL)

## What is HCL?

**HashiCorp Configuration Language (HCL)** is the language used to write **Terraform configuration files**.

Think of it like this:

* Humans communicate using languages like **English**, **Spanish**, or **Hindi**.
* Programmers communicate with Terraform using **HCL**.

When you write HCL code, Terraform reads it and communicates with cloud providers such as **AWS**, **Azure**, or **Google Cloud** to create your infrastructure.

---

# What Does "Declarative" Mean?

Terraform uses a **declarative** approach.

This means **you tell Terraform what you want**, not **how to build it**.

### Example

Suppose you want an EC2 instance.

You simply write:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"
}
```

You are saying:

> "I want one EC2 instance."

You **do not** tell Terraform:

* How to connect to AWS
* How to create the virtual machine
* How to assign an ID
* How to wait until it's running

Terraform handles all of those steps automatically.

---

# Why is HCL Easy to Learn?

HCL is designed to be:

* Human-readable
* Easy to write
* Easy to understand
* Easy to maintain

Even someone with little programming experience can usually understand Terraform configurations after some practice.

---

# Terraform Configuration Files

Terraform code is stored in **configuration files**.

These files use the extension:

```text
.tf
```

Examples:

```text
main.tf
variables.tf
outputs.tf
providers.tf
network.tf
ec2.tf
```

Terraform automatically reads every `.tf` file in the current directory.

---

# What are Blocks?

Everything in Terraform is organized into **blocks**.

A block is a section of code that tells Terraform what to do.

Blocks always start with a **keyword**.

Some common block types are:

* `terraform`
* `provider`
* `resource`
* `data`
* `variable`
* `output`
* `locals`
* `module`

Example:

```hcl
resource "aws_s3_bucket" "demo_bucket" {

}
```

Here:

* `resource` → Block type
* `aws_s3_bucket` → Resource type
* `demo_bucket` → Resource name

---

# Blocks Use Curly Braces `{}`

Every block is enclosed inside curly braces.

Example:

```hcl
resource "aws_instance" "web" {

  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

}
```

The opening `{` starts the block.

The closing `}` ends the block.

Everything inside belongs to that block.

---

# Common Terraform Blocks

## 1. Resource Block

Creates infrastructure.

Example:

```hcl
resource "aws_instance" "web" {

}
```

This creates an AWS EC2 instance.

---

## 2. Data Block

Reads information that already exists.

Example:

```hcl
data "aws_ami" "ubuntu" {

}
```

Instead of creating an AMI, Terraform looks up an existing one.

---

## 3. Variable Block

Stores input values.

Example:

```hcl
variable "region" {

}
```

Variables make your code reusable.

---

## 4. Output Block

Displays useful information after Terraform finishes.

Example:

```hcl
output "instance_ip" {

}
```

Outputs often show things like:

* Public IP
* Instance ID
* Bucket Name
* Database Endpoint

---

# Block Names Must Be Unique

Most Terraform blocks have a name.

Example:

```hcl
resource "aws_instance" "web_server" {

}
```

Here:

* Resource Type = `aws_instance`
* Resource Name = `web_server`

The resource name should be unique within your Terraform configuration so you can reference it later.

Example:

```hcl
aws_instance.web_server.public_ip
```

Terraform knows exactly which resource you're referring to.

---

# Comments in Terraform

Comments help explain your code.

They make it easier for you and your teammates to understand what each section does.

Single-line comments use:

```hcl
# Create an EC2 instance

resource "aws_instance" "web" {

}
```

You can also use:

```hcl
// Create an EC2 instance
```

Although both work, **`#` is commonly used in Terraform examples and documentation.**

---

# Terraform Handles the "How"

One of Terraform's biggest advantages is that **you only describe the desired infrastructure**.

Terraform figures out:

* What to create
* In what order
* Which resources depend on others
* How to communicate with the cloud provider

For example:

```hcl
resource "aws_s3_bucket" "demo" {

}
```

You don't tell Terraform how to make an S3 bucket.

You simply declare that you want one.

Terraform handles the implementation.

---

# Naming Best Practices

Use lowercase letters and underscores.

Good:

```hcl
web_server
```

```hcl
private_subnet
```

```hcl
database_instance
```

Avoid:

```hcl
WebServer
```

```hcl
MyDatabase
```

```hcl
database-instance
```

Using underscores makes resource names easier to read.

---

# Indentation Best Practices

Use **two spaces** for each nesting level.

Good example:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  tags = {
    Name = "Web Server"
  }
}
```

Proper indentation makes it easy to see the hierarchy of the code.

---

# Align Equal Signs (Optional but Helpful)

Keeping equal signs aligned improves readability.

Example:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"
  key_name      = "my-key"
}
```

This makes the code easier to scan, especially in larger files.

---

# Use Empty Lines

Separate related sections with blank lines.

Instead of:

```hcl
resource "aws_instance" "web" {
  ami="ami-123"
  instance_type="t2.micro"
  tags={
    Name="Web"
  }
}
```

Write:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-123"
  instance_type = "t2.micro"

  tags = {
    Name = "Web"
  }
}
```

The second version is much easier to read.

---

# Why Follow These Best Practices?

Good formatting helps everyone who works on the project.

Benefits include:

* Easier to read
* Easier to debug
* Easier to maintain
* Easier for teammates to understand
* More professional code
* Better collaboration

Remember, Terraform code is often read more times than it is written.

Writing clean code today saves time later.

---

# Key Points to Remember

* **HCL** is Terraform's programming language.
* Terraform configuration files use the **`.tf`** extension.
* Terraform is **declarative**—you describe **what** you want, not **how** to create it.
* Everything is organized into **blocks**.
* Blocks begin with keywords such as `resource`, `data`, `variable`, or `output`.
* Blocks are enclosed in **curly braces `{}`**.
* Resource names should be unique and descriptive.
* Use comments to explain your code.
* Use lowercase letters and underscores for naming.
* Indent with **two spaces** for better readability.
* Group related settings and separate sections with empty lines.
* Clean, consistent formatting makes teamwork and maintenance much easier.

---

# Summary

HashiCorp Configuration Language (HCL) is the language used by Terraform to define infrastructure. Instead of manually creating cloud resources, you describe the infrastructure you want in simple, readable configuration files with the `.tf` extension. Terraform reads these files, determines the correct order of operations, and automatically creates or manages the resources. Following good coding practices—such as meaningful comments, proper indentation, descriptive names, and consistent formatting—makes Terraform configurations easier to read, maintain, and share with others.
