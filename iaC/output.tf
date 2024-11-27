output "public_subnets" {
  value = module.vpc.public_subnets

}

output "private_subnets" {
  value = module.vpc.private_subnets

}

output "vpc_id" {
  value = module.vpc.vpc_id

}

output "aws_iam_oidc_connect_provider_arn" {
  value = module.eks.aws_iam_oidc_connect_provider_arn
}

output "aws_iam_oidc_connect_provider_extract_from_arn" {
  value = module.eks.aws_iam_oidc_connect_provider_extract_from_arn

}