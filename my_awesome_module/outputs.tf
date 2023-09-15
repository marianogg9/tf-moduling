output "the_bucket" {
    value = module.s3_bucket.s3_bucket_arn
}
output "the_role" {
    value = module.iam_assumable_role_with_oidc.iam_role_arn
}