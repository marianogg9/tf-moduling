data "aws_eks_cluster" "this" { # get EKS cluster attributes to use later on.
  name = "test-eks-cluster"
}

data "aws_caller_identity" "current" {} # get current account ID

module "s3_bucket" {
    for_each = {
    app-1 = { "permissions" : ["s3:PutObject"] },
    app-2 = { "permissions" : ["s3:GetObject", "s3:PutObject"] },
    app-3 = { "permissions" : ["s3:GetObjectVersion"] }
  }

  source = "terraform-aws-modules/s3-bucket/aws"

  bucket_prefix    = join("",[each.key,"-"])
  acl              = "private"

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"
}

module "iam_assumable_role_with_oidc" {
    for_each = {
    app-1 = { "permissions" : ["s3:PutObject"] },
    app-2 = { "permissions" : ["s3:GetObject", "s3:PutObject"] },
    app-3 = { "permissions" : ["s3:GetObjectVersion"] }
  }

  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  create_role = true
  role_name   = each.key

  tags = {
    # add some tags!
  }
  provider_url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer

  role_policy_arns = [
    aws_iam_policy.the_policy[each.key].arn,
  ]
  number_of_role_policy_arns = 1
}

resource "aws_iam_policy" "the_policy" {
    for_each = {
    app-1 = { "permissions" : ["s3:PutObject"] },
    app-2 = { "permissions" : ["s3:GetObject", "s3:PutObject"] },
    app-3 = { "permissions" : ["s3:GetObjectVersion"] }
  }

  name_prefix = join("",[each.key,"-"])
  path        = "/"

  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = [ for permission in each.value["permissions"]: permission ]
        Effect   = "Allow"
        Resource = join("",[module.s3_bucket[each.key].s3_bucket_arn,"/*"])
      },
    ]
  })
}