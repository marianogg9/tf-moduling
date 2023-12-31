locals {
  apps = {
    app-1 = { "permissions" : ["s3:PutObject"] },
    app-2 = { "permissions" : ["s3:GetObject", "s3:PutObject"] },
    app-3 = { "permissions" : ["s3:GetObjectVersion"] }
  }
}

# S3 resources
resource "aws_s3_bucket" "the_bucket" {
  for_each = local.apps

  bucket_prefix = join("", [each.key, "-"])
}

resource "aws_s3_bucket_ownership_controls" "the_bucket_oc" {
  for_each = {
    app-1 = { "permissions" : ["s3:PutObject"] },
    app-2 = { "permissions" : ["s3:GetObject", "s3:PutObject"] },
    app-3 = { "permissions" : ["s3:GetObjectVersion"] }
  }

  bucket = aws_s3_bucket.the_bucket[each.key].id
  
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "the_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.the_bucket_oc]

  for_each = local.apps

  bucket = aws_s3_bucket.the_bucket[each.key].id

  acl = "private"
}

resource "aws_s3_bucket_public_access_block" "the_bucket_ab" {
  for_each = local.apps

  bucket = aws_s3_bucket.the_bucket[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM resources

## Some prerequisites
data "aws_eks_cluster" "this" { # get EKS cluster attributes to use later on.
  name = "test-eks-cluster"
}

data "aws_caller_identity" "current" {} # get current account ID

data "aws_iam_policy_document" "assume-policy" { # create an assume policy for STS
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        replace(
          data.aws_eks_cluster.this.identity[0].oidc[0].issuer,
          "https://",
          join("", ["arn:aws:iam::", data.aws_caller_identity.current.account_id, ":oidc-provider/"])
        )
      ]
    }
  }
}

## Role definition
resource "aws_iam_role" "the_role" { # create the IAM role and attach both assume and inline identity based policies.
  for_each = local.apps

  name = each.key
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume-policy.json

  inline_policy {
    name = "s3-put"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action = [for permission in each.value["permissions"] : permission]
        Effect = "Allow"
        Resource = aws_s3_bucket.the_bucket[each.key].arn
      }]
    })
  }

  tags = {
    # always add some tags!
  }
}

resource "aws_iam_policy" "the_policy" {
  for_each = local.apps

  name_prefix = join("",[each.key,"-"])
  path        = "/"

  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = [ for permission in each.value["permissions"]: permission ]
        Effect   = "Allow"
        Resource = join("",[aws_s3_bucket.the_bucket[each.key].arn,"/*"])
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "the_policy_attachment" {
  for_each = local.apps

  role       = aws_iam_role.the_role[each.key].name
  policy_arn = aws_iam_policy.the_policy[each.key].arn
}

output "the_bucket" {
  value = values(aws_s3_bucket.the_bucket).*.arn
}
output "the_role" {
  value = values(aws_iam_role.the_role).*.arn
}