# S3 resources
resource "aws_s3_bucket" "the_bucket" {
  bucket_prefix = "app-1-"
}

resource "aws_s3_bucket_ownership_controls" "the_bucket_oc" {
  bucket = aws_s3_bucket.the_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "the_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.the_bucket_oc]

  bucket     = aws_s3_bucket.the_bucket.id
  acl        = "private"
}

# IAM resources

## Some prerequisites
data "aws_eks_cluster" "this" { # get EKS cluster attributes to use later on.
    name = "your-eks-cluster-name"
}

data "aws_iam_policy_document" "assume-policy" { # create an assume policy for STS
    statement {
      actions = ["sts:AssumeRoleWithWebIdentity"]
      principals {
        type        = "Federated"
        identifiers = [data.aws_eks_cluster.this.identity[0].oidc[0].issuer]
      }
    }
}

## Role definition
resource "aws_iam_role" "the_role" { # create the IAM role and attach both assume and inline identity based policies.
    name_prefix        = "app-1-"
    path               = "/"
    assume_role_policy = data.aws_iam_policy_document.assume-policy.json
    inline_policy {
      name   = "s3-put"
      policy = jsonencode({
        Version   = "2012-10-17"
        Statement = [{
            Action = [
                "s3:PutObject"
            ]
            Effect   = "Allow"
            Resource = aws_s3_bucket.the_bucket.arn
        }]
      })
    }

    tags = {
        # always add some tags!
    }
}