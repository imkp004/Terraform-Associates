# Terraform `for_each`

## What is `for_each`?

`for_each` is a Terraform meta-argument used to **create multiple resources from a single resource block**.

Instead of copying and pasting the same resource many times, Terraform will automatically create one resource for **each item** in a collection.

Think of it as a **loop**.

Instead of writing:

```hcl
resource "aws_s3_bucket" "bucket1" {
  bucket = "company-dev"
}

resource "aws_s3_bucket" "bucket2" {
  bucket = "company-test"
}

resource "aws_s3_bucket" "bucket3" {
  bucket = "company-prod"
}
```

You can write one resource block and let Terraform create all three.

---

# Why Use `for_each`?

Without `for_each`:

* Lots of duplicated code.
* Harder to maintain.
* Easy to make mistakes.
* Every resource must be written manually.

With `for_each`:

* One resource block.
* Cleaner code.
* Easy to add or remove resources.
* Scales to hundreds of resources.

---

# How Does It Work?

Terraform takes a **map** or a **set of strings**.

It loops through every item.

For every item, Terraform creates one resource.

Think of it like this:

```text
Collection

↓

Item 1

↓

Create Resource


Collection

↓

Item 2

↓

Create Resource


Collection

↓

Item 3

↓

Create Resource
```

One block becomes many resources.

---

# Syntax

```hcl
resource "<type>" "<name>" {

  for_each = <collection>

}
```

The collection can be:

* Map
* Set of strings

---

# Understanding `each.key` and `each.value`

Whenever you use `for_each`, Terraform automatically creates a special object called **each**.

It has two properties.

```text
each.key
```

The unique key.

```text
each.value
```

The value stored in that key.

These are used inside the resource block.

---

# Example 1 - Using a Map

Suppose you have three environments.

```hcl
locals {

  buckets = {

    dev  = "company-dev"

    test = "company-test"

    prod = "company-prod"

  }

}
```

Now create three S3 buckets.

```hcl
resource "aws_s3_bucket" "bucket" {

  for_each = local.buckets

  bucket = each.value

}
```

Terraform sees:

```text
dev  -> company-dev

test -> company-test

prod -> company-prod
```

It creates:

```text
company-dev

company-test

company-prod
```

---

# What are `each.key` and `each.value` Here?

Terraform loops one item at a time.

### First iteration

```text
each.key

dev
```

```text
each.value

company-dev
```

---

### Second iteration

```text
each.key

test
```

```text
each.value

company-test
```

---

### Third iteration

```text
each.key

prod
```

```text
each.value

company-prod
```

---

# Example 2 - Using Both Key and Value

```hcl
locals {

  environments = {

    dev = "t3.micro"

    test = "t3.small"

    prod = "t3.large"

  }

}
```

Create EC2 instances.

```hcl
resource "aws_instance" "servers" {

  for_each = local.environments

  ami           = "ami-123456"

  instance_type = each.value

  tags = {

    Name = each.key

  }

}
```

Terraform creates:

| Resource | Instance Type |
| -------- | ------------- |
| dev      | t3.micro      |
| test     | t3.small      |
| prod     | t3.large      |

Notice:

```text
each.key
```

became the Name tag.

```text
each.value
```

became the instance type.

---

# Example 3 - Using a Set

You can also use a set.

```hcl
locals {

  users = toset([

    "alice",

    "bob",

    "charlie"

  ])

}
```

Create IAM users.

```hcl
resource "aws_iam_user" "users" {

  for_each = local.users

  name = each.value

}
```

Terraform creates:

```text
alice

bob

charlie
```

For a set:

```text
each.key == each.value
```

because a set only stores values.

---

# Why Not Use a List?

Terraform does **not** allow lists directly with `for_each`.

This is **incorrect**.

```hcl
locals {

  names = [

    "dev",

    "test",

    "prod"

  ]

}

resource "aws_s3_bucket" "bucket" {

  for_each = local.names

}
```

Terraform will return an error.

Instead convert the list.

```hcl
for_each = toset(local.names)
```

---

# Resource Addresses

Each resource gets its own address.

Example:

```hcl
resource "aws_s3_bucket" "bucket" {

  for_each = {

    dev = "company-dev"

    prod = "company-prod"

  }

}
```

Terraform creates:

```text
aws_s3_bucket.bucket["dev"]
```

and

```text
aws_s3_bucket.bucket["prod"]
```

These are unique resources.

---

# Resource Referencing

Suppose you created buckets.

```hcl
resource "aws_s3_bucket" "bucket" {

  for_each = {

    dev = "company-dev"

    prod = "company-prod"

  }

}
```

Reference one bucket.

```hcl
aws_s3_bucket.bucket["dev"].id
```

Or

```hcl
aws_s3_bucket.bucket["prod"].arn
```

Each resource has its own attributes.

---

# Example 4 - Creating Multiple Security Groups

```hcl
locals {

  security_groups = {

    web = "Web Server"

    app = "Application Server"

    db = "Database Server"

  }

}
```

```hcl
resource "aws_security_group" "sg" {

  for_each = local.security_groups

  name = each.key

  description = each.value

}
```

Terraform creates:

| Name | Description        |
| ---- | ------------------ |
| web  | Web Server         |
| app  | Application Server |
| db   | Database Server    |

---

# Example 5 - Different Instance Sizes

```hcl
locals {

  servers = {

    frontend = "t3.micro"

    backend = "t3.medium"

    database = "t3.large"

  }

}
```

```hcl
resource "aws_instance" "server" {

  for_each = local.servers

  ami = "ami-123456"

  instance_type = each.value

  tags = {

    Name = each.key

  }

}
```

Terraform creates:

| Name     | Type      |
| -------- | --------- |
| frontend | t3.micro  |
| backend  | t3.medium |
| database | t3.large  |

---

# Adding New Resources

Suppose you currently have:

```text
dev

test
```

Later you add:

```text
prod
```

Terraform only creates:

```text
prod
```

It does **not** recreate dev or test.

This is one of the biggest advantages of `for_each`.

---

# Removing Resources

Suppose you remove:

```text
test
```

Terraform destroys only:

```text
test
```

The other resources stay untouched.

---

# `count` vs `for_each`

Terraform has another meta-argument called `count`.

### `count`

Uses numbers.

```hcl
count = 3
```

Creates:

```text
resource[0]

resource[1]

resource[2]
```

Resources are identified by their index.

---

### `for_each`

Uses keys.

```hcl
for_each = {

  dev = ...

  prod = ...

}
```

Creates:

```text
resource["dev"]

resource["prod"]
```

Resources are identified by meaningful names.

This makes your configuration easier to understand and maintain.

---

# When Should You Use `for_each`?

Use `for_each` when:

* Every resource has a unique name.
* Every resource has different settings.
* You have maps or sets.
* Resources may be added or removed over time.
* You want stable resource addresses.

Examples:

* IAM users
* S3 buckets
* Security groups
* EC2 instances
* Route53 records
* VPC subnets
* ECR repositories

---

# Best Practices

* Use meaningful keys such as `dev`, `prod`, or `frontend` instead of generic names.
* Prefer `for_each` over `count` when resources have unique identities.
* Use maps when each resource has different values.
* Use sets when you only need unique strings.
* Reference resources by their key, such as `aws_instance.server["frontend"]`, instead of relying on numeric indexes.

---

# Key Points to Remember

* `for_each` creates multiple resources from a single resource block.
* It works with **maps** and **sets of strings**.
* Terraform creates one resource for each item in the collection.
* `each.key` returns the unique key.
* `each.value` returns the value associated with that key.
* Every created resource has its own state entry and unique resource address.
* Adding a new key creates only the new resource.
* Removing a key destroys only that specific resource.
* `for_each` is generally preferred over `count` when resources have meaningful names or unique configurations.
