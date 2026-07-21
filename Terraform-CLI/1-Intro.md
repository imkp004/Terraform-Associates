# Terraform CLI (Command Line Interface)

## What is the Terraform CLI?

The **Terraform CLI (Command Line Interface)** is the main way you interact with Terraform.

Instead of clicking buttons in a web console, you type commands into your terminal.

Example:

```bash
terraform init
```

Terraform reads your command and performs the requested action.

Almost everything you do in Terraform starts with the CLI.

---

# Unified Workflow

One of Terraform's biggest strengths is its **unified workflow**.

No matter which cloud provider you use, the Terraform commands stay the same.

For example, these commands work whether you're using:

* AWS
* Microsoft Azure
* Google Cloud Platform (GCP)
* GitHub
* Docker
* Kubernetes
* VMware
* Hundreds of other providers

Example:

AWS

```bash
terraform init
terraform plan
terraform apply
```

Azure

```bash
terraform init
terraform plan
terraform apply
```

Google Cloud

```bash
terraform init
terraform plan
terraform apply
```

Notice that the commands never change.

Only the Terraform configuration changes.

This makes Terraform easy to learn because once you know the CLI, you can use it with almost any provider.

---

# Simple CLI

Terraform has a simple and easy-to-remember command structure.

Most commands follow the same pattern:

```bash
terraform <command> [options]
```

Example:

```bash
terraform init
```

```bash
terraform validate
```

```bash
terraform plan
```

```bash
terraform apply
```

```bash
terraform destroy
```

The first word is always:

```text
terraform
```

The second word tells Terraform what you want it to do.

Optional flags come after the command.

Example:

```bash
terraform plan -out=myplan
```

---

# Common Terraform Commands

## `terraform fmt`

Formats all Terraform files.

It automatically:

* Fixes indentation.
* Aligns equal signs.
* Organizes spacing.
* Makes your code easier to read.

Example:

```bash
terraform fmt
```

---

## `terraform init`

Initializes the working directory.

It:

* Downloads providers.
* Downloads modules.
* Creates the `.terraform/` directory.
* Creates or updates `.terraform.lock.hcl`.

Example:

```bash
terraform init
```

---

## `terraform validate`

Checks whether your Terraform configuration is valid.

It checks:

* Syntax
* Block structure
* Required arguments

It does **not** contact AWS or other providers.

Example:

```bash
terraform validate
```

---

## `terraform plan`

Shows a preview of the changes Terraform will make.

Nothing is created yet.

Example:

```bash
terraform plan
```

---

## `terraform apply`

Creates, updates, or destroys real infrastructure.

Example:

```bash
terraform apply
```

---

## `terraform state list`

Shows every resource currently managed by Terraform.

Example:

```bash
terraform state list
```

Output:

```text
aws_vpc.main

aws_subnet.public

aws_instance.web

aws_s3_bucket.logs
```

This command reads the state file and lists all tracked resources.

---

## `terraform destroy`

Deletes all infrastructure managed by Terraform.

Example:

```bash
terraform destroy
```

---

# Common Command Options

## Save a Plan

Instead of displaying the plan only on the screen:

```bash
terraform plan -out=myplan
```

Terraform saves the execution plan into:

```text
myplan
```

Later:

```bash
terraform apply myplan
```

Terraform executes that exact saved plan.

---

## Auto Approve

Normally Terraform asks:

```text
Do you want to perform these actions?
```

If you use:

```bash
terraform apply -auto-approve
```

Terraform skips the confirmation prompt.

The same works for destroy:

```bash
terraform destroy -auto-approve
```

Be careful with this option because Terraform immediately performs the requested changes.

---

# Environment Variables

Environment variables are **values stored in your operating system** that programs can read while they are running.

Instead of writing sensitive information directly in your Terraform code, you can store it as an environment variable.

Terraform automatically reads certain environment variables when it starts.

This improves:

* Security
* Reusability
* Automation
* Portability

---

# Why Are Environment Variables Important?

Imagine writing this:

```hcl
provider "aws" {

  access_key = "AKIA123456789"

  secret_key = "my-secret-password"

}
```

This is called **hardcoding**.

Problems:

* Anyone who opens the file can see your credentials.
* If you upload the project to GitHub, your secrets are exposed.
* If the credentials change, you must edit your code.

This is considered a very bad security practice.

---

Instead, store the credentials in your operating system.

Terraform automatically reads them when it runs.

Your Terraform code stays clean, secure, and reusable.

---

# TF_VAR

One of Terraform's most useful environment variables is:

```text
TF_VAR_<variable_name>
```

Terraform automatically assigns the value to the matching input variable.

---

## Example

Terraform variable:

```hcl
variable "region" {

  type = string

}
```

Instead of creating a `.tfvars` file, you can set:

macOS/Linux:

```bash
export TF_VAR_region="us-east-1"
```

Windows PowerShell:

```powershell
$env:TF_VAR_region="us-east-1"
```

Now when Terraform runs:

```bash
terraform plan
```

Terraform automatically uses:

```text
region = us-east-1
```

You never typed it inside your Terraform files.

---

## Another Example

Terraform code:

```hcl
variable "instance_type" {

  type = string

}
```

Set:

```bash
export TF_VAR_instance_type="t3.micro"
```

Terraform automatically receives:

```text
instance_type = "t3.micro"
```

without requiring:

```text
terraform.tfvars
```

---

# Why Use TF_VAR?

Benefits:

* Avoid hardcoding values.
* Easy to change between environments.
* Useful in CI/CD pipelines.
* Keeps secrets out of source code.
* Different users can use different values without changing the Terraform files.

Example:

Developer A:

```bash
export TF_VAR_region="us-east-1"
```

Developer B:

```bash
export TF_VAR_region="us-west-2"
```

Both use the same Terraform code, but deploy to different regions.

---

# TF_LOG

Another useful environment variable is:

```text
TF_LOG
```

`TF_LOG` enables **debug logging**.

Normally Terraform prints only important information.

Sometimes something goes wrong and you need more details.

You can tell Terraform to print internal debugging information.

---

## Example

macOS/Linux:

```bash
export TF_LOG=INFO
```

Then run:

```bash
terraform plan
```

Terraform prints much more information about what it is doing internally.

---

## Logging Levels

Terraform supports several logging levels:

```text
TRACE
DEBUG
INFO
WARN
ERROR
OFF
```

---

### TRACE

Prints **everything**.

Useful when troubleshooting complex issues.

Produces a very large amount of output.

---

### DEBUG

Shows detailed debugging information.

Less verbose than TRACE.

---

### INFO

Shows useful informational messages.

A good balance between detail and readability.

---

### WARN

Shows only warning messages.

---

### ERROR

Shows only errors.

---

### OFF

Turns logging off (default behavior).

---

## Example

```bash
export TF_LOG=DEBUG
```

Then:

```bash
terraform apply
```

Terraform might display:

```text
Reading provider configuration...

Connecting to AWS...

Loading provider plugins...

Refreshing state...

Creating EC2 instance...
```

This is very helpful when diagnosing problems with providers, authentication, or state.

---

# Other Common Environment Variables (Good to Know)

Although `TF_VAR` and `TF_LOG` are the most common for beginners, Terraform supports many others.

Examples:

```text
TF_DATA_DIR
```

Changes where Terraform stores the `.terraform` working directory.

---

```text
TF_INPUT
```

Controls whether Terraform asks for interactive input.

Setting:

```bash
export TF_INPUT=0
```

disables prompts, which is useful in automation.

---

```text
TF_CLI_ARGS
```

Automatically adds command-line arguments to every Terraform command.

Example:

```bash
export TF_CLI_ARGS="-no-color"
```

Every Terraform command will automatically use:

```text
-no-color
```

---

# Best Practices

* Never hardcode passwords, access keys, or API tokens in Terraform files.
* Use environment variables for secrets whenever possible.
* Use `TF_VAR` to provide variable values without modifying your code.
* Use `TF_LOG` only when troubleshooting because debug logs can become very large.
* Turn off logging after debugging to keep terminal output clean.

---

# Key Points to Remember

* The Terraform CLI provides a consistent way to manage infrastructure across all supported providers.
* Almost every Terraform command follows the pattern `terraform <command> [options]`.
* Common commands include `fmt`, `init`, `validate`, `plan`, `apply`, `state list`, and `destroy`.
* `terraform plan -out=<file>` saves an execution plan for later approval and application.
* `terraform apply -auto-approve` and `terraform destroy -auto-approve` skip the confirmation prompt and should be used carefully.
* Environment variables improve security and flexibility by keeping sensitive values out of your Terraform configuration.
* `TF_VAR_<name>` automatically supplies values for Terraform input variables.
* `TF_LOG` enables different levels of logging to help troubleshoot Terraform operations.

---

# Summary

The Terraform CLI is the primary way to interact with Terraform and follows a simple, consistent command structure regardless of the cloud provider you are using. Whether you're deploying to AWS, Azure, or Google Cloud, the same workflow—`init`, `validate`, `plan`, `apply`, and `destroy`—remains the same. Environment variables make Terraform even more powerful by allowing you to securely pass values into your configuration (`TF_VAR`) and troubleshoot problems (`TF_LOG`) without changing your Terraform code. This combination of a consistent CLI and flexible environment variables makes Terraform easy to automate, secure, and use across different environments.
