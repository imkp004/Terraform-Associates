
# Terraform Blocks (Brief Overview)

Terraform configurations are built from different block types.

---

## `terraform` Block

The `terraform` block contains settings that control how Terraform itself behaves.

It is **not** used to create infrastructure.

Example:

```hcl
terraform {

  required_version = ">= 1.0.0"

  required_providers {

    aws = {

      source  = "hashicorp/aws"

      version = "~> 6.0"

    }

  }

}
```

This tells Terraform:

* Minimum Terraform version required.
* Which providers to use.
* Which provider versions are allowed.

---

## `provider` Block

A provider connects Terraform to a platform or service.

Example:

```hcl
provider "aws" {

  region = "us-east-1"

}
```

Terraform now knows it should create resources inside AWS.

---

## `resource` Block

Resources are the actual infrastructure Terraform manages.

Examples:

* EC2 Instances
* S3 Buckets
* VPCs
* Databases

Example:

```hcl
resource "aws_instance" "web" {

}
```

---

## `data` Block

Data sources **read existing infrastructure**.

Unlike resources, they do **not create anything**.

Example:

```hcl
data "aws_availability_zones" "available" {

}
```

Terraform retrieves the existing availability zones from AWS.

---

## `variable` Block

Variables make Terraform code reusable.

Instead of hardcoding values, you define them once and provide different values later.

Example:

```hcl
variable "instance_type" {

}
```

Later:

```hcl
instance_type = var.instance_type
```

---

## `output` Block

Outputs display useful information after Terraform finishes.

Example:

```hcl
output "bucket_name" {

  value = aws_s3_bucket.demo.bucket

}
```

Outputs can also be shared with other Terraform configurations using remote state.

---

## `module` Block

Modules are reusable collections of Terraform code.

Instead of rewriting the same resources repeatedly, you package them into a module and call it whenever needed.

Example:

```hcl
module "network" {

  source = "./modules/network"

}
```

Or use a public module:

```hcl
module "vpc" {

  source = "terraform-aws-modules/vpc/aws"

}
```

This downloads a pre-built VPC module from the Terraform Registry instead of writing all the networking code yourself.

Modules are similar to functions in programming—they let you reuse code multiple times.

---

## `import` Block

Sometimes infrastructure already exists because it was created manually or by another tool.

Terraform cannot manage those resources until they are imported.

Example:

You manually created an S3 bucket called:

```text
my-company-logs
```

You can import it into Terraform so Terraform starts managing it.

Example:

```hcl
import {

  to = aws_s3_bucket.logs

  id = "my-company-logs"

}
```

After importing, the bucket becomes part of the Terraform state and Terraform can update or destroy it just like any other managed resource.

---

# Key Points to Remember

* Split large Terraform projects into multiple `.tf` files for better readability and maintenance.
* Terraform automatically reads **all** `.tf` files in the current directory as a single configuration.
* Resource references work across different files.
* `main.tf` usually contains your primary infrastructure.
* `providers.tf` configures cloud providers.
* `variables.tf` defines reusable input variables.
* `terraform.tfvars` stores values for those variables and often stays out of Git if it contains secrets.
* `outputs.tf` displays useful information and can share values with other Terraform projects.
* `terraform.tfstate`, `terraform.tfstate.backup`, and `.terraform.lock.hcl` are automatically managed by Terraform.
* Separate environments such as `dev`, `test`, and `prod` into different directories (or separate backends) to isolate infrastructure.
* The main Terraform blocks are: `terraform`, `provider`, `resource`, `data`, `variable`, `output`, `module`, and `import`.
