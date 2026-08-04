# Terraform `depends_on` Meta-Argument

## What is `depends_on`?

The `depends_on` is a **Terraform meta-argument** that allows you to manually tell Terraform:

> "Create this resource only after another resource has been created."

Terraform normally understands the creation order automatically by looking at **resource references**.

However, sometimes Terraform cannot understand the relationship between resources because there is no direct reference between them.

In those situations, we use `depends_on`.

---

# Why Do We Need `depends_on`?

Terraform builds something called a **resource dependency graph** behind the scenes.

The graph tells Terraform:

* What resources need to be created
* What resources depend on others
* Which resources can be created at the same time
* The correct order of operations

Terraform automatically understands many relationships.

Example:

```hcl
resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"

}


resource "aws_subnet" "public" {

  vpc_id = aws_vpc.main.id

}
```

Terraform sees:

```text
VPC

↓

Subnet
```

because the subnet references:

```hcl
aws_vpc.main.id
```

Terraform knows:

> "The subnet needs the VPC ID, so the VPC must exist first."

This is called an **implicit dependency**.

---

# Implicit Dependency

## Definition

An implicit dependency is when Terraform automatically detects the relationship between resources because one resource references another resource.

Terraform does not need help.

It automatically creates the correct order.

---

## Example

```hcl
resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"

}


resource "aws_instance" "server" {

  ami = "ami-123456"

  instance_type = "t2.micro"

  subnet_id = aws_subnet.public.id

}
```

Terraform sees:

```text
VPC

↓

Subnet

↓

EC2 Instance
```

because:

```hcl
subnet_id = aws_subnet.public.id
```

is a resource reference.

Terraform automatically creates:

1. VPC
2. Subnet
3. EC2 Instance

---

# Explicit Dependency

## Definition

An explicit dependency is when Terraform **cannot automatically determine the relationship**, so you manually tell Terraform using:

```hcl
depends_on
```

You are saying:

> "Terraform, even though you don't see a reference, this resource depends on another resource."

---

# Syntax

```hcl
depends_on = [

  resource_type.resource_name

]
```

Example:

```hcl
resource "aws_instance" "app_server" {

  ami = "ami-123456"

  instance_type = "t2.micro"


  depends_on = [

    aws_iam_role.app_role

  ]

}
```

This means:

```
IAM Role

↓

EC2 Instance
```

Terraform must create the IAM role first.

---

# Real-Life Example

Imagine you have:

* EC2 application server
* RDS database

Your application connects to the database.

A human understands:

```
Database

↓

Application Server
```

because the application needs the database.

However, Terraform may not know this relationship.

Why?

Because your EC2 resource might not directly reference the RDS resource.

Example:

```hcl
resource "aws_db_instance" "database" {

  engine = "mysql"

}


resource "aws_instance" "app" {

  ami = "ami-123456"

  instance_type = "t2.micro"

}
```

Terraform sees:

```
Database

EC2
```

There is no connection.

Terraform might create them in parallel.

---

## Using depends_on

```hcl
resource "aws_instance" "app" {

  ami = "ami-123456"

  instance_type = "t2.micro"


  depends_on = [

    aws_db_instance.database

  ]

}
```

Now Terraform knows:

```
RDS Database

↓

EC2 Application Server
```

The database must exist first.

---

# Implicit vs Explicit Dependency

| Type                | How Terraform Knows                    | Example                                   |
| ------------------- | -------------------------------------- | ----------------------------------------- |
| Implicit Dependency | Terraform detects resource reference   | `subnet_id = aws_subnet.public.id`        |
| Explicit Dependency | Engineer manually defines relationship | `depends_on = [aws_db_instance.database]` |

---

# Another Real Example: IAM Permissions

Imagine an EC2 instance requires an IAM role.

You create:

```hcl
resource "aws_iam_role" "server_role" {

  name = "server-role"

}
```

and:

```hcl
resource "aws_instance" "server" {

  ami = "ami-123456"

  instance_type = "t2.micro"

}
```

Terraform does not know:

```
IAM Role

↓

EC2
```

because the EC2 resource does not reference the IAM role.

So:

```hcl
resource "aws_instance" "server" {

  ami = "ami-123456"

  instance_type = "t2.micro"


  depends_on = [

    aws_iam_role.server_role

  ]

}
```

Now Terraform creates:

1. IAM Role
2. EC2 Instance

---

# Important: Do Not Overuse depends_on

`depends_on` is powerful, but you should not use it everywhere.

Terraform is designed to automatically understand dependencies.

Bad:

```hcl
resource "aws_instance" "server" {

  depends_on = [

    aws_vpc.main,

    aws_subnet.public,

    aws_security_group.sg,

    aws_route_table.route

  ]

}
```

This creates unnecessary restrictions.

Terraform already knows these relationships if you reference them.

---

# Best Practice

Use:

## Resource References First

Preferred:

```hcl
vpc_id = aws_vpc.main.id
```

because Terraform automatically creates the dependency.

---

Use:

## depends_on Only When Needed

Example situations:

* Resource relationship exists but there is no direct reference
* API ordering requirements
* IAM permissions need to exist before another resource
* A service must be fully created before another service starts

---

# How Terraform Uses Dependencies

Terraform creates a graph:

Example:

```
              VPC
               |
        ----------------
        |              |
     Subnet       Security Group
        |
       EC2
        |
       App
```

Terraform analyzes this graph.

Resources with no dependency can run together.

Example:

```
VPC

↓

----------------

Subnet A     Subnet B

(can run in parallel)

↓

EC2
```

But if you add:

```hcl
depends_on
```

you create an additional connection in the graph.

---

# Important Notes

## depends_on Does Not Create Resources

It only controls the order.

It does not:

* Configure resources
* Pass values
* Create relationships

It only says:

> "Wait until this resource is complete before creating this one."

---

## depends_on Works With Resources and Modules

Example with modules:

```hcl
module "database" {

  source = "./modules/database"

}


module "application" {

  source = "./modules/application"


  depends_on = [

    module.database

  ]

}
```

Terraform creates:

```
Database Module

↓

Application Module
```

---

# Simple Way To Remember

### Implicit Dependency

Terraform says:

> "I see the connection. I know the order."

Example:

```
EC2 uses subnet ID

Subnet must exist first
```

---

### Explicit Dependency

You say:

> "Terraform, you cannot see this connection, but I need this created first."

Example:

```
Database

↓

Application
```

---

# Key Points

* `depends_on` is a Terraform meta-argument.
* It creates an explicit dependency between resources.
* Terraform normally uses implicit dependencies through resource references.
* Use `depends_on` only when Terraform cannot automatically determine the correct order.
* It affects Terraform's dependency graph and creation order.
* It does not pass values between resources.
* Overusing it can slow deployments and reduce Terraform's ability to create resources in parallel.
* In real-world projects, most dependencies are implicit; explicit dependencies are used for special cases.
