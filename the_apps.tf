module "the_apps" {
    for_each = {
        app-1 = {"permissions":["s3:PutObject"]},
        app-2 = {"permissions":["s3:GetObject","s3:PutObject"]},
        app-3 = {"permissions":["s3:GetObjectVersion"]}
    }
    
    source = "./my_awesome_module" # reference to our local module
    
    bucket_name = each.key
    role_name = each.key
    permissions = each.value["permissions"]
    oidc_url = "your_eks_OIDC_provider_URL"
}

output "the_apps" {
  value = module.the_apps
}