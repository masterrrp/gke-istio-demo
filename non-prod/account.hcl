# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  gcp_account_name = "non-prod" # TODO: support organizations and account switching with service account impersonation!
  project_id       = "terraform-states-349403"
}
