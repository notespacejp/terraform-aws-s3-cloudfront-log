variable "bucket_name" {
    type = string
    description = "bucket name"
}

variable "kms_arn" {
    type = string
    description = "encryption kms arn"
    default = null
}

variable "versioning" {
    type = bool
    description = "enable versioning"
    default = false
}