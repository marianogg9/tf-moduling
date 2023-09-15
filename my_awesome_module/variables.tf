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
variable "oidc_url" {
    description = "OIDC provider URL, taken from the EKS cluster"
    type        = string
    default     = ""
}