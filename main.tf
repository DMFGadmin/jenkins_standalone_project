module "project" {
  source          = "./modules/jenkins_project"
  billing_account_id = var.billing_account_id
}