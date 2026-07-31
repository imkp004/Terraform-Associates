provider "random" {}

provider "aws" {
  region = "us-east-1"
}

variable "length" {
    type = number
    description = "numbe of the lenght of pet"
}

resource "random_pet" "pet" {
  length = var.length
}


output "random_pet_name" {
  value = random_pet.pet.id
}
