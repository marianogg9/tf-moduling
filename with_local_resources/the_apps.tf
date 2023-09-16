# S3 resources
resource "aws_s3_bucket" "the_bucket" {
  for_each = {
    app-1 = { "permissions" : ["s3:PutObject"] },
    app-2 = { "permissions" : ["s3:GetObject", "s3:PutObject"] },
    app-3 = { "permissions" : ["s3:GetObjectVersion"] }
  }

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

  for_each = {
    app-1 = { "permissions" : ["s3:PutObject"] },
    app-2 = { "permissions" : ["s3:GetObject", "s3:PutObject"] },
    app-3 = { "permissions" : ["s3:GetObjectVersion"] }
  }

  bucket = aws_s3_bucket.the_bucket[each.key].id

  acl = "private"
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
  for_each = {
    app-1 = { "permissions" : ["s3:PutObject"] },
    app-2 = { "permissions" : ["s3:GetObject", "s3:PutObject"] },
    app-3 = { "permissions" : ["s3:GetObjectVersion"] }
  }

  name_prefix = join("", [each.key, "-"])
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