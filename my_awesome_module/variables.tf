variable "bucket_name" {
    description = "S3 bucket name"
    type        = string
    default     = ""
}
variable "role_name" {
    description = "IAM role name"
    type        = string
    default     = ""
}
variable "permissions" {
    description = "List of permissions to attach to the IAM role"
    type        = list
    default     = []
}