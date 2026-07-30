# Terraform Built-in Functions

## What are Built-in Functions?

Terraform has many **built-in functions** that help you manipulate data inside your configuration.

Think of a function like a **small tool** that takes an input, performs an operation, and returns an output.

Just like a calculator has functions such as:

* Add
* Subtract
* Square Root

Terraform has functions that can:

* Work with numbers
* Manipulate strings
* Convert data types
* Perform calculations
* Work with dates and times
* Generate hashes
* Manipulate collections (lists, maps, sets)
* Calculate IP addresses and subnets

Instead of manually writing everything, Terraform functions can automatically calculate or transform values for you.

---

# Why Use Functions?

Without functions, you would have to hardcode many values.

Functions make your Terraform code:

* More dynamic
* Easier to maintain
* More reusable
* Less error-prone
* Easier to read

For example, instead of hardcoding a subnet CIDR block, Terraform can calculate it automatically.

---

# Function Syntax

Every function follows the same basic format.

```hcl
function_name(argument1, argument2, ...)
```

Example:

```hcl
max(5, 10, 20)
```

Terraform returns:

```text
20
```

The function receives three numbers and returns the largest one.

---

# Categories of Terraform Functions

Terraform has many built-in functions. Common categories include:

* Numeric Functions
* String Functions
* Collection Functions
* Type Conversion Functions
* Network Functions
* Date & Time Functions
* Encoding Functions
* Filesystem Functions
* Hash & Crypto Functions

You don't need to memorize them all. The Terraform documentation is the best reference.

---

# Numeric Functions

Numeric functions perform mathematical operations.

---

## min()

Returns the smallest number.

Example:

```hcl
min(15, 8, 22, 3)
```

Output:

```text
3
```

Terraform compares every number and returns the lowest value.

Real-world example:

Suppose your application supports multiple instance sizes.

```hcl
variable "instance_counts" {
  default = [3, 5, 2]
}

output "smallest" {
  value = min(var.instance_counts...)
}
```

Output:

```text
2
```

---

## max()

Returns the largest number.

Example:

```hcl
max(15, 8, 22, 3)
```

Output:

```text
22
```

Real-world example:

```hcl
max(100, 250, 75)
```

Terraform returns:

```text
250
```

---

## abs()

Returns the absolute value.

```hcl
abs(-20)
```

Output

```text
20
```

---

## ceil()

Rounds up.

```hcl
ceil(5.2)
```

Output

```text
6
```

---

## floor()

Rounds down.

```hcl
floor(5.9)
```

Output

```text
5
```

---

# String Functions

String functions manipulate text.

---

## join()

Combines multiple strings together using a separator.

Syntax:

```hcl
join(separator, list)
```

Example:

```hcl
join("-", ["web", "server", "01"])
```

Output:

```text
web-server-01
```

Terraform inserts "-" between each item.

Another example:

```hcl
join(", ", ["Dev", "Test", "Prod"])
```

Output:

```text
Dev, Test, Prod
```

Real-world example:

Generating names.

```hcl
locals {
  bucket_name = join("-", ["company", "logs", "dev"])
}
```

Result:

```text
company-logs-dev
```

---

## split()

The opposite of join().

It takes one string and breaks it into a list.

Example:

```hcl
split(",", "apple,banana,orange")
```

Output:

```text
[
  "apple",
  "banana",
  "orange"
]
```

Real-world example:

Suppose someone provides:

```text
subnet-a,subnet-b,subnet-c
```

Terraform converts it into:

```text
[
subnet-a,
subnet-b,
subnet-c
]
```

Now each subnet can be used individually.

---

## upper()

Converts text to uppercase.

```hcl
upper("terraform")
```

Output

```text
TERRAFORM
```

---

## lower()

Converts text to lowercase.

```hcl
lower("AWS")
```

Output

```text
aws
```

---

## replace()

Replaces text.

```hcl
replace("web-server", "-", "_")
```

Output

```text
web_server
```

---

## trim()

Removes spaces.

```hcl
trim(" hello ")
```

Output

```text
hello
```

---

# Type Conversion Functions

Terraform has several data types.

Sometimes you need to convert one type into another.

---

## tolist()

Converts a value into a list.

Example:

```hcl
tolist(["web1","web2"])
```

Result:

```text
[
web1,
web2
]
```

This is commonly used when another resource specifically expects a list.

---

## toset()

Converts a list into a set.

A **set** is an unordered collection that **cannot contain duplicate values**.

Example:

```hcl
toset(["web","db","web"])
```

Output:

```text
[
db,
web
]
```

Notice:

The duplicate `"web"` was automatically removed.

---

### Why Use a Set?

Imagine a firewall rule.

You accidentally wrote:

```text
80
80
443
443
```

Terraform converts it into a set.

Result:

```text
80
443
```

Duplicates disappear automatically.

---

## tonumber()

Converts text into a number.

Example:

```hcl
tonumber("50")
```

Output

```text
50
```

---

## tostring()

Converts numbers into text.

```hcl
tostring(100)
```

Output

```text
"100"
```

---

## tomap()

Converts data into a map.

Example:

```hcl
tomap({
  Name = "Web"
  Env  = "Dev"
})
```

---

# Collection Functions

These work with lists, maps, and sets.

---

## length()

Returns how many items exist.

```hcl
length(["web1","web2","web3"])
```

Output

```text
3
```

---

## keys()

Returns all map keys.

```hcl
keys({
  Name="Web"
  Env="Dev"
})
```

Output

```text
[
Name,
Env
]
```

---

## values()

Returns all map values.

```hcl
values({
Name="Web"
Env="Dev"
})
```

Output

```text
[
Web,
Dev
]
```

---

## contains()

Checks whether a value exists.

```hcl
contains(["dev","test","prod"],"prod")
```

Output

```text
true
```

---

# Network Functions

These are some of Terraform's most powerful functions.

They calculate networking values automatically.

This is especially useful when creating:

* VPCs
* Subnets
* Route Tables
* Large enterprise networks

The most common networking function is:

```hcl
cidrsubnet()
```

---

# What is cidrsubnet()?

Imagine you have one large network.

Example:

```text
10.0.0.0/16
```

This network contains many possible IP addresses.

Instead of manually calculating subnet ranges, Terraform can divide the network for you.

That's exactly what `cidrsubnet()` does.

It creates smaller subnet CIDR blocks from a larger network.

---

# Syntax

```hcl
cidrsubnet(prefix, newbits, netnum)
```

Three arguments are required.

---

## 1. Prefix

The original network.

Example:

```text
10.0.0.0/16
```

---

## 2. newbits

How many additional subnet bits should be added.

Larger values create more subnets.

Example:

```text
Original

/16

newbits = 8

↓

Result

/24
```

Because:

```text
16 + 8 = 24
```

---

## 3. netnum

Which subnet should Terraform return?

Example:

```text
Subnet 0

Subnet 1

Subnet 2

Subnet 3
```

You choose using `netnum`.

---

# Example 1

```hcl
cidrsubnet("10.0.0.0/16",8,0)
```

Output:

```text
10.0.0.0/24
```

Terraform creates the first subnet.

---

# Example 2

```hcl
cidrsubnet("10.0.0.0/16",8,1)
```

Output:

```text
10.0.1.0/24
```

Second subnet.

---

# Example 3

```hcl
cidrsubnet("10.0.0.0/16",8,2)
```

Output:

```text
10.0.2.0/24
```

Third subnet.

---

# Visual Example

Suppose you own this network.

```text
10.0.0.0/16
```

Terraform divides it automatically.

```text
10.0.0.0/24

10.0.1.0/24

10.0.2.0/24

10.0.3.0/24

...

10.0.255.0/24
```

Instead of manually calculating every subnet, Terraform generates them for you.

---

# Real AWS Example

Suppose you create a VPC.

```hcl
resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"

}
```

Now create three subnets.

```hcl
resource "aws_subnet" "public1" {

  vpc_id = aws_vpc.main.id

  cidr_block = cidrsubnet(
    aws_vpc.main.cidr_block,
    8,
    0
  )

}
```

Terraform calculates:

```text
10.0.0.0/24
```

Second subnet.

```hcl
cidrsubnet(
aws_vpc.main.cidr_block,
8,
1
)
```

Output

```text
10.0.1.0/24
```

Third subnet.

```hcl
cidrsubnet(
aws_vpc.main.cidr_block,
8,
2
)
```

Output

```text
10.0.2.0/24
```

Notice that you never manually typed the subnet addresses.

Terraform calculated them automatically.

This reduces mistakes and makes your network easy to scale.

---

# Why is cidrsubnet() Important?

Imagine a company with:

* 50 VPCs
* 400 subnets
* Multiple AWS Regions

Calculating every subnet manually would be slow and error-prone.

Terraform performs the calculations automatically.

Benefits:

* No overlapping subnet ranges
* Consistent addressing
* Easier automation
* Better scalability
* Less human error

---

# Key Points to Remember

* Functions are built into Terraform and perform operations on data.
* Functions make Terraform configurations dynamic, reusable, and easier to maintain.
* Numeric functions work with numbers (`min()`, `max()`, `abs()`, `ceil()`, `floor()`).
* String functions manipulate text (`join()`, `split()`, `upper()`, `lower()`, `replace()`, `trim()`).
* Type conversion functions convert data types (`tolist()`, `toset()`, `tonumber()`, `tostring()`, `tomap()`).
* Collection functions help work with lists, maps, and sets (`length()`, `keys()`, `values()`, `contains()`).
* Network functions such as `cidrsubnet()` automatically calculate subnet CIDR blocks, making large network deployments much easier and reducing manual errors.
