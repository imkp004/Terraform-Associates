# Terraform File Extensions, Formatting, Documentation, and Best Practices

## Terraform File Extensions

Terraform uses specific file extensions to identify different types of configuration files.

---

## `.tf` Files

Terraform configuration files always use the extension:

```text
.tf
```

These files contain the actual Terraform code that defines your infrastructure.

Examples:

```text
main.tf
provider.tf
network.tf
ec2.tf
security-group.tf
outputs.tf
```

Inside these files, we define:

* Resources
* Providers
* Variables
* Outputs
* Data sources
* Modules

Example:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
}
```

---

## `.tfvars` Files

Terraform variable definition files use:

```text
.tfvars
```

These files store values for variables.

Instead of writing values directly inside your Terraform code, you store them separately.

Example:

`variables.tf`

```hcl
variable "region" {
  description = "AWS region"
}
```

`terraform.tfvars`

```hcl
region = "us-east-1"
```

Now Terraform uses the value from the `.tfvars` file.

---

# Why Separate Variables?

Separating variables from configuration makes your code:

* Easier to reuse
* Easier to customize
* Safer
* Easier to manage across different environments

Example:

You can have:

```
dev.tfvars
test.tfvars
prod.tfvars
```

Each environment can use different values without changing the main Terraform code.

---

# Terraform Formatting Best Practices

Good formatting is important because Terraform code is read and maintained by humans.

Proper formatting improves:

* Readability
* Maintainability
* Understanding of the code
* Team collaboration

---

## Example of Poor Formatting

```hcl
resource "aws_instance" "web" {
ami="ami-123"
instance_type="t2.micro"
}
```

This works, but it is difficult to read.

---

## Proper Formatting

```hcl
resource "aws_instance" "web" {

  ami           = "ami-123"
  instance_type = "t2.micro"

}
```

The second example is easier to understand.

---

# Use `terraform fmt`

Terraform provides a command to automatically format your files:

```bash
terraform fmt
```

This command:

* Fixes indentation
* Aligns code
* Removes unnecessary spaces
* Formats blocks properly

Terraform engineers commonly run this command before committing code.

---

# Organization of Terraform Files

As Terraform projects grow, organizing files becomes very important.

A common structure:

```
terraform-project/

├── provider.tf
├── variables.tf
├── terraform.tfvars
├── network.tf
├── security.tf
├── ec2.tf
├── outputs.tf
```

Each file has a specific purpose.

---

## Example Organization

### provider.tf

Contains cloud provider configuration.

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

---

### variables.tf

Contains variable definitions.

Example:

```hcl
variable "instance_type" {

}
```

---

### ec2.tf

Contains EC2 resources.

Example:

```hcl
resource "aws_instance" "web" {

}
```

---

### outputs.tf

Contains values Terraform displays after deployment.

Example:

```hcl
output "public_ip" {

}
```

---

# Why Organization Matters?

Good organization helps you:

* Find resources quickly
* Understand the project structure
* Debug problems faster
* Work better with a team
* Maintain large Terraform projects

When a project has hundreds of resources, organization becomes extremely important.

---

# Comments and Documentation

Comments explain what your code does.

Terraform supports comments using:

```hcl
#
```

Example:

```hcl
# Create a VPC for the application network

resource "aws_vpc" "main" {

}
```

---

# Why Use Comments?

Good comments help:

* You remember why something was created
* Other engineers understand your code
* Teams collaborate easier
* Future maintenance becomes simpler

Remember:

> Code explains what is happening.
> Comments explain why it is happening.

---

# Good Documentation Example

Bad:

```hcl
resource "aws_security_group" "sg" {

}
```

Better:

```hcl
# Security group allowing HTTP and HTTPS traffic
# Required for the public web application

resource "aws_security_group" "web" {

}
```

---

# Avoid Hardcoding Values

Hardcoding means writing values directly inside your Terraform code.

Example:

```hcl
resource "aws_instance" "web" {

  instance_type = "t2.micro"

}
```

This works, but it is not flexible.

---

## Better Approach: Use Variables

`variables.tf`

```hcl
variable "instance_type" {

}
```

`terraform.tfvars`

```hcl
instance_type = "t2.micro"
```

Resource:

```hcl
resource "aws_instance" "web" {

  instance_type = var.instance_type

}
```

---

# Why Avoid Hardcoding?

Hardcoding causes problems because:

* Values are difficult to change
* Code cannot be reused easily
* Different environments become harder to manage

Example:

Development environment:

```text
instance_type = t2.micro
```

Production environment:

```text
instance_type = t3.large
```

Instead of changing the code, you simply change the variable value.

---

# Terraform Best Practices Summary

## File Extensions

✅ Use `.tf` for Terraform configuration files
✅ Use `.tfvars` for variable values

---

## Formatting

✅ Use proper indentation
✅ Use `terraform fmt`
✅ Keep code clean and readable

---

## Organization

✅ Separate resources into different files
✅ Group related infrastructure together
✅ Use meaningful file names

---

## Comments and Documentation

✅ Explain complex sections
✅ Document the purpose of resources
✅ Help future developers understand the code

---

## Avoid Hardcoding

✅ Use variables
✅ Make code reusable
✅ Support multiple environments easily

---

# Final Summary

Writing Terraform code is not only about making infrastructure work. Good Terraform engineers also focus on writing clean, organized, and maintainable code. Using the correct file extensions, formatting code properly, organizing resources, adding useful comments, and avoiding hardcoded values makes Terraform projects easier to understand, scale, and manage in real-world environments.
