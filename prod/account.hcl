# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  gcp_account_name = "prod" # TODO: support organizations and account switching with service account impersonation!
  project_id       = "development-349403"
}
