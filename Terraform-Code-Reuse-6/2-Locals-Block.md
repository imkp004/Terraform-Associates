# Terraform Local Values (`locals` Block)

## What is a Local Block?

A **local block** (also called **local values**) is used to create **temporary values inside your Terraform configuration** that can be reused throughout your code.

Think of local values as **variables that Terraform calculates for you**.

They are useful when:

* You need to combine multiple variables.
* You have the same expression repeated many times.
* You want cleaner and more readable code.
* You want to calculate values once and reuse them.
* You want to avoid repeating long expressions.

Unlike input variables, local values **cannot be changed by the user**. Terraform calculates them automatically.

---

# Variables vs Locals

Many beginners confuse variables and locals.

A simple way to remember them is:

**Variables = Input from the user**

**Locals = Calculated values inside Terraform**

Think of it like cooking.

Variables are the ingredients someone gives you.

```text
Tomatoes

Onions

Chicken
```

Local values are the recipe.

Terraform combines those ingredients into a finished meal.

```text
Chicken Curry
```

The user supplies the ingredients.

Terraform creates the finished product using locals.

---

# Why Do We Need Locals?

Imagine you are creating resources for a development environment.

Without locals:

```hcl
resource "aws_s3_bucket" "logs" {
  bucket = "${var.company_name}-${var.environment}-logs"
}

resource "aws_s3_bucket" "images" {
  bucket = "${var.company_name}-${var.environment}-images"
}

resource "aws_s3_bucket" "backup" {
  bucket = "${var.company_name}-${var.environment}-backup"
}
```

Notice this expression:

```hcl
${var.company_name}-${var.environment}
```

It is repeated three times.

Now imagine a project with:

* 150 resources
* 40 Terraform files

You may repeat the same expression dozens of times.

If you later rename your company or environment format, you must update every occurrence.

That is difficult to maintain.

---

# Using Locals

Instead, calculate the value once.

```hcl
locals {
  resource_prefix = "${var.company_name}-${var.environment}"
}
```

Now reuse it everywhere.

```hcl
resource "aws_s3_bucket" "logs" {
  bucket = "${local.resource_prefix}-logs"
}

resource "aws_s3_bucket" "images" {
  bucket = "${local.resource_prefix}-images"
}

resource "aws_s3_bucket" "backup" {
  bucket = "${local.resource_prefix}-backup"
}
```

Now the repeated expression exists in only one place.

If you change the naming convention, you only update the local value.

---

# Local Block Syntax

The syntax is simple.

```hcl
locals {

  local_name = value

}
```

Unlike variables, there is **no type** and **no default**.

Terraform automatically determines the data type.

Example:

```hcl
locals {

  company = "ABC"

  port = 80

  production = true

}
```

Terraform automatically knows:

* company → string
* port → number
* production → boolean

---

# Referencing Local Values

Every local value starts with:

```hcl
local.<local_name>
```

Example:

```hcl
locals {

  app_name = "ecommerce"

}
```

Use it like this:

```hcl
resource "aws_s3_bucket" "logs" {

  bucket = "${local.app_name}-logs"

}
```

Terraform replaces it with:

```text
ecommerce-logs
```

---

# Combining Variables

One of the biggest uses of locals is combining multiple variables.

Variables:

```hcl
variable "company_name" {

  default = "mycompany"

}

variable "environment" {

  default = "dev"

}
```

Local:

```hcl
locals {

  prefix = "${var.company_name}-${var.environment}"

}
```

Terraform calculates:

```text
mycompany-dev
```

Now every resource can use:

```hcl
local.prefix
```

instead of repeating:

```hcl
"${var.company_name}-${var.environment}"
```

---

# Example 1 - Naming Resources

Without locals:

```hcl
bucket = "${var.company}-${var.environment}-images"

queue = "${var.company}-${var.environment}-orders"

table = "${var.company}-${var.environment}-users"
```

With locals:

```hcl
locals {

  prefix = "${var.company}-${var.environment}"

}
```

Now:

```hcl
bucket = "${local.prefix}-images"

queue = "${local.prefix}-orders"

table = "${local.prefix}-users"
```

Much cleaner.

---

# Example 2 - Common Tags

Many AWS resources need identical tags.

Without locals:

```hcl
tags = {

  Environment = var.environment

  Owner = "DevOps"

  ManagedBy = "Terraform"

}
```

You copy this into:

* EC2
* VPC
* S3
* RDS
* IAM
* Load Balancer

The same block gets copied over and over.

Instead:

```hcl
locals {

  common_tags = {

    Environment = var.environment

    Owner = "DevOps"

    ManagedBy = "Terraform"

  }

}
```

Use it everywhere.

```hcl
resource "aws_s3_bucket" "logs" {

  tags = local.common_tags

}
```

```hcl
resource "aws_vpc" "main" {

  tags = local.common_tags

}
```

Now every resource gets identical tags.

If you add another tag later, you only update one place.

---

# Example 3 - Calculated Values

Locals can also perform calculations.

```hcl
variable "cpu_per_instance" {

  default = 2

}

variable "instance_count" {

  default = 4

}
```

Local:

```hcl
locals {

  total_cpu = var.cpu_per_instance * var.instance_count

}
```

Terraform calculates:

```text
2 × 4 = 8
```

Output:

```hcl
output "total_cpu" {

  value = local.total_cpu

}
```

Result:

```text
8
```

---

# Example 4 - Using Functions

Locals work very well with Terraform functions.

Example:

```hcl
locals {

  bucket_name = lower(join("-", [

    var.company,

    var.environment,

    "logs"

  ]))

}
```

Variables:

```text
Company = MyCompany

Environment = DEV
```

Terraform calculates:

```text
mycompany-dev-logs
```

The local value combines variables and functions into one reusable value.

---

# Example 5 - Lists

Locals can store lists.

```hcl
locals {

  availability_zones = [

    "us-east-1a",

    "us-east-1b",

    "us-east-1c"

  ]

}
```

Reference:

```hcl
local.availability_zones
```

---

# Example 6 - Maps

Locals can also store maps.

```hcl
locals {

  instance_sizes = {

    dev = "t3.micro"

    test = "t3.small"

    prod = "t3.large"

  }

}
```

Use:

```hcl
local.instance_sizes["prod"]
```

Terraform returns:

```text
t3.large
```

---

# Multiple Local Values

One `locals` block can contain many values.

```hcl
locals {

  company = "ABC"

  environment = "dev"

  prefix = "${local.company}-${local.environment}"

  common_tags = {

    Environment = local.environment

    ManagedBy = "Terraform"

  }

}
```

Notice something important.

A local value can reference another local value.

Terraform automatically calculates them in the correct order.

---

# Multiple locals Blocks

You can also create multiple `locals` blocks.

Terraform combines them into one.

Example:

```hcl
locals {

  company = "ABC"

}
```

Later in another file:

```hcl
locals {

  environment = "dev"

}
```

Terraform treats them as one collection of local values.

This is useful for keeping large projects organized.

---

# Variables vs Locals vs Outputs

These three blocks are commonly confused.

## Variable

Receives information **into** Terraform.

```text
User

↓

Terraform
```

Example:

```hcl
variable "environment" {}
```

---

## Local

Calculates or combines information **inside** Terraform.

```text
Terraform

↓

Calculates New Value
```

Example:

```hcl
locals {

  prefix = "${var.company}-${var.environment}"

}
```

---

## Output

Sends information **out of** Terraform.

```text
Terraform

↓

Displays Information
```

Example:

```hcl
output "bucket_name" {

  value = aws_s3_bucket.logs.bucket

}
```

Think of it like this:

```text
Variables

↓

Locals

↓

Resources

↓

Outputs
```

---

# Best Practices

* Use meaningful names such as `common_tags`, `resource_prefix`, or `bucket_name`.
* Store repeated expressions in locals instead of copying them throughout your configuration.
* Keep calculations inside locals instead of repeating them in multiple resources.
* Use locals for naming conventions, tags, calculated values, lists, and maps.
* Avoid using locals for values that users should customize. Those belong in input variables.
* Keep local values simple and readable. Extremely long or complex expressions can make your configuration harder to understand.

---

# When Should You Use Locals?

Use locals when:

* Combining multiple variables into one value.
* Reusing the same expression many times.
* Creating common tags for many resources.
* Building resource names consistently.
* Storing calculated values.
* Improving readability.
* Removing duplicate code.

Do **not** use locals when:

* The value should be provided by the user (use a variable instead).
* The value needs to change between environments through external input.
* The value represents infrastructure that Terraform creates (use a resource instead).

---

# Key Points to Remember

* A `locals` block defines reusable values that exist only inside the current Terraform configuration.
* Local values are calculated by Terraform and cannot be overridden by users.
* Reference local values using `local.<name>`.
* Locals help eliminate duplicate code by storing repeated expressions in one place.
* They are commonly used for naming conventions, tags, calculated values, lists, maps, and function results.
* Local values improve readability, consistency, and maintainability, making Infrastructure as Code easier to manage as projects grow.
