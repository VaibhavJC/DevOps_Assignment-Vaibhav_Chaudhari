variable "availability_zone" {
  description = "The availability zone where the EBS volume will be created."
  type        = string
  
}

variable "size" {
  description = "The size of the EBS volume in gigabytes."
  type        = number
}