data "aws_eks_cluster" "this" { # get EKS cluster attributes to use later on.
  name = "test-eks-cluster"
}

data "aws_caller_identity" "current" {} # get current account ID

module "iam_assumable_role_with_oidc" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  create_role = true
  role_name   = var.role_name

  tags = {
    # add some tags!
  }
  provider_url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer

  role_policy_arns = [
    aws_iam_policy.the_policy.arn,
  ]
  number_of_role_policy_arns = 1
}

resource "aws_iam_policy" "the_policy" {
  name_prefix = join("",[var.role_name,"-"])
  path        = "/"

  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = [ for permission in var.permissions: permission ]
        Effect   = "Allow"
        Resource = join("",[module.s3_bucket.s3_bucket_arn,"/*"])
      },
    ]
  })
}