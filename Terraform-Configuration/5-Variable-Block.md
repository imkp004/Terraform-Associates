# Terraform Variable Block

## What is a Variable Block?

A **variable block** allows you to make your Terraform code **dynamic, reusable, and easy to maintain**.

Instead of hardcoding values directly into your resources, you define them as **variables**.

You can then provide different values depending on your environment (Development, Testing, Production) without changing the infrastructure code itself.

Think of variables like **blanks in a form**.

Instead of writing:

> Build an EC2 instance in **us-east-1**

You write:

> Build an EC2 instance in **<region>**

Then later you decide what `<region>` should be.

---

# Why Do We Need Variables?

Imagine your company has three environments.

```text
Development (Dev)

Testing (Test)

Production (Prod)
```

Each environment is almost identical.

The only things that change are:

* Region
* Number of EC2 instances
* Instance size
* Environment name
* Database size

Without variables, you would have to copy your Terraform code three times.

Example:

```text
dev/main.tf

test/main.tf

prod/main.tf
```

Now imagine changing one thing.

You must update all three copies.

That is slow and error-prone.

---

## The Infrastructure as Code (IaC) Principle

One of the biggest principles of Infrastructure as Code is:

> **Don't Repeat Yourself (DRY).**

Instead of writing the same code three times, write it once and change only the values.

Variables make this possible.

---

# Real-World Example

Without variables:

### Dev

```hcl
instance_type = "t2.micro"
```

### Test

```hcl
instance_type = "t3.small"
```

### Production

```hcl
instance_type = "t3.large"
```

You now have three copies of almost identical code.

---

With variables:

```hcl
instance_type = var.instance_type
```

Now you only change:

Dev

```text
instance_type = t2.micro
```

Test

```text
instance_type = t3.small
```

Production

```text
instance_type = t3.large
```

The Terraform code never changes.

Only the variable values change.

---

# General Syntax

```hcl
variable "variable_name" {

  description = ""

  type = string

  default = ""

}
```

Example:

```hcl
variable "region" {

  description = "AWS Region"

  type = string

  default = "us-east-1"

}
```

---

# Parts of a Variable Block

Example:

```hcl
variable "region" {

  description = "AWS Region"

  type = string

  default = "us-east-1"

}
```

---

## variable

Terraform keyword.

It tells Terraform that you are defining an input variable.

---

## "region"

This is the variable name.

You choose this name.

Use meaningful names.

Good examples:

```text
instance_type

region

environment

bucket_name

database_name
```

Poor examples:

```text
abc

test

var1

thing
```

---

## description

Explains what the variable is used for.

This is helpful for you and anyone reading your code.

Example:

```hcl
description = "AWS Region where resources will be created"
```

---

## type

Specifies what kind of value Terraform expects.

Examples:

* string
* number
* bool
* list
* map
* set

Terraform validates the type before running.

---

## default

The value Terraform will use if you don't provide one elsewhere.

Example:

```hcl
default = "us-east-1"
```

If no other value is supplied, Terraform uses `us-east-1`.

---

# Dynamic Values for Dynamic Code

One of the biggest advantages of variables is that they make your code dynamic.

Without variables:

```hcl
region = "us-east-1"
```

Every deployment goes to us-east-1.

---

With variables:

```hcl
region = var.region
```

Now:

Dev:

```text
us-east-1
```

Test:

```text
us-west-2
```

Production:

```text
eu-west-1
```

The same Terraform code can deploy to completely different regions.

Only the variable changes.

This is what people mean by:

> **Dynamic values create dynamic infrastructure.**

---

# Centralised Management

Suppose your project creates:

* EC2
* RDS
* S3
* Load Balancer

Every resource needs the region.

Without variables:

```hcl
resource 1

region = "us-east-1"

resource 2

region = "us-east-1"

resource 3

region = "us-east-1"

resource 4

region = "us-east-1"
```

Later you change to:

```text
us-west-2
```

Now you must edit every resource.

---

With variables:

```hcl
variable "region" {

  default = "us-east-1"

}
```

Every resource uses:

```hcl
var.region
```

Need another region?

Change only one place.

Everything updates automatically.

---

# Improved Reusability

Imagine your company has five customers.

Instead of writing five Terraform projects:

```text
Customer A

Customer B

Customer C

Customer D

Customer E
```

You write one project.

Each customer provides different variables.

The infrastructure stays exactly the same.

---

# Variable Types

Terraform supports many variable types.

The most common are:

* string
* number
* bool
* list
* map
* set

---

# String

A string is text.

Example:

```hcl
variable "region" {

  type = string

  default = "us-east-2"

}
```

Possible values:

```text
us-east-1

us-west-2

eu-west-1

ap-south-1
```

Other examples:

```text
Instance Name

Bucket Name

AMI ID

Environment

Username

Domain Name
```

Example:

```hcl
variable "bucket_name" {

  type = string

  default = "company-backups"

}
```

---

# Number

Numbers can be integers or decimal values.

Example:

```hcl
variable "num_of_vm" {

  type = number

  default = 3

}
```

Terraform creates three VMs.

Another example:

```hcl
variable "disk_size" {

  type = number

  default = 100

}
```

100 GB disk.

Numbers are commonly used for:

* Number of EC2 instances
* Storage size
* Port numbers
* CPU count
* Memory size

---

# Bool (Boolean)

A boolean has only two values:

```text
true

false
```

Example:

```hcl
variable "enable_ha" {

  type = bool

  default = true

}
```

Examples:

```text
Enable backups

Enable monitoring

Enable encryption

Enable logging

Enable versioning
```

Example:

```hcl
variable "enable_monitoring" {

  type = bool

  default = true

}
```

If true, Terraform creates monitoring resources.

If false, it skips them.

---

# List

A list stores multiple values in order.

Lists:

* Use square brackets `[]`
* Separate values with commas
* Maintain order
* Index starts at **0**

Example:

```hcl
variable "availability_zones" {

  type = list(string)

  default = [

    "us-east-1a",

    "us-east-1b",

    "us-east-1c"

  ]

}
```

Terraform stores:

```text
Index 0 -> us-east-1a

Index 1 -> us-east-1b

Index 2 -> us-east-1c
```

Access values:

```hcl
var.availability_zones[0]
```

Returns:

```text
us-east-1a
```

Another example:

```hcl
variable "instance_names" {

  default = [

    "web1",

    "web2",

    "web3"

  ]

}
```

---

# Map

A map stores information as **key-value pairs**.

Think of a dictionary.

Example:

```hcl
variable "instance_types" {

  type = map(string)

  default = {

    dev  = "t2.micro"

    test = "t3.small"

    prod = "t3.large"

  }

}
```

Retrieve:

```hcl
var.instance_types["prod"]
```

Returns:

```text
t3.large
```

Maps are useful when different environments need different values.

---

# Set

A set is similar to a list.

However:

* No duplicate values
* No guaranteed order

Example:

```hcl
variable "allowed_regions" {

  type = set(string)

  default = [

    "us-east-1",

    "us-east-1",

    "us-west-2"

  ]

}
```

Terraform automatically removes duplicates.

Result:

```text
us-east-1

us-west-2
```

Sets are useful when duplicate values make no sense.

---

# Referencing Variables

Every variable begins with:

```text
var.
```

General syntax:

```text
var.<variable_name>
```

Example:

```hcl
variable "instance_type" {

  default = "t3.micro"

}
```

Resource:

```hcl
resource "aws_instance" "web" {

  instance_type = var.instance_type

}
```

Terraform replaces:

```text
var.instance_type
```

with

```text
t3.micro
```

---

# Ways to Assign Variable Values

Terraform lets you provide variable values in several ways.

---

# 1. Default Values

Example:

```hcl
variable "region" {

  default = "us-east-1"

}
```

If no other value is provided, Terraform uses the default.

Defaults are the **lowest priority** because any other source can override them.

---

# 2. Environment Variables

Terraform can read variables from your operating system.

Environment variables must begin with:

```text
TF_VAR_
```

Example:

Linux/macOS:

```bash
export TF_VAR_region="us-west-2"
```

Windows PowerShell:

```powershell
$env:TF_VAR_region="us-west-2"
```

Terraform automatically assigns:

```text
var.region
```

to

```text
us-west-2
```

### Why use environment variables?

Useful for sensitive values such as:

* API keys
* Passwords
* Tokens
* Secret IDs

Because they are not written directly into your Terraform files.

They exist only in your current shell session unless you save them permanently.

---

# 3. .tfvars Files

A `.tfvars` file stores variable values outside your Terraform code.

Example:

variables.tf

```hcl
variable "region" {

  type = string

}
```

terraform.tfvars

```hcl
region = "us-east-1"
```

Terraform reads this automatically.

---

Example for different environments:

dev.tfvars

```hcl
instance_type = "t2.micro"

region = "us-east-1"
```

---

prod.tfvars

```hcl
instance_type = "t3.large"

region = "eu-west-1"
```

Run:

```bash
terraform apply -var-file="dev.tfvars"
```

or

```bash
terraform apply -var-file="prod.tfvars"
```

Same code.

Different infrastructure.

---

# 4. CLI Flags

You can also provide variables directly from the command line.

Example:

```bash
terraform apply -var="region=us-west-2"
```

Or multiple:

```bash
terraform apply \
-var="region=us-west-2" \
-var="instance_type=t3.large"
```

Useful for:

* Quick testing
* Temporary changes
* Automation scripts

No files need to be edited.

---

# Variable Precedence (Override Order)

Terraform follows a clear priority order.

Highest priority overrides everything below it.

```text
1. CLI (-var)

↓

2. .auto.tfvars

↓

3. terraform.tfvars or *.tfvars

↓

4. Environment Variables (TF_VAR_)

↓

5. Default Values
```

---

## Example

Variable:

```hcl
default = "us-east-1"
```

Environment variable:

```text
TF_VAR_region=us-west-2
```

terraform.tfvars:

```text
region = "eu-west-1"
```

CLI:

```bash
terraform apply -var="region=ap-south-1"
```

Terraform uses:

```text
ap-south-1
```

because the CLI has the highest priority.

---

# Real-World Environment Example

You have one Terraform project:

```text
main.tf

variables.tf

outputs.tf
```

Three environments:

Development:

```text
dev.tfvars
```

```hcl
instance_type = "t2.micro"

num_of_vm = 1
```

Testing:

```text
test.tfvars
```

```hcl
instance_type = "t3.small"

num_of_vm = 2
```

Production:

```text
prod.tfvars
```

```hcl
instance_type = "t3.large"

num_of_vm = 6
```

Deploy Development:

```bash
terraform apply -var-file="dev.tfvars"
```

Deploy Production:

```bash
terraform apply -var-file="prod.tfvars"
```

Exactly the same Terraform code creates completely different infrastructure based only on the variable values.

---

# Best Practices

* Avoid hardcoding values inside resources.
* Use meaningful variable names.
* Add descriptions to every variable.
* Use `.tfvars` files for environment-specific values.
* Use environment variables for secrets and sensitive information.
* Use CLI variables only for temporary overrides or testing.
* Keep common defaults in `variables.tf`.
* Reuse the same Terraform configuration across multiple environments by changing only the variable values.

---

# Key Points to Remember

* Variables make Terraform code flexible, reusable, and easier to maintain.
* They allow you to write one configuration and deploy it to different environments with different values.
* Variables reduce code duplication and follow the Infrastructure as Code principle of **Don't Repeat Yourself (DRY)**.
* Common variable types include `string`, `number`, `bool`, `list`, `map`, and `set`.
* Variables are referenced using the syntax `var.<variable_name>`.
* Variable values can come from defaults, environment variables, `.tfvars` files, or CLI flags.
* Terraform uses a precedence order, where CLI values override `.tfvars`, environment variables, and defaults.
* Using variables keeps your infrastructure code cleaner, more organised, and much easier to scale as your projects grow.
