# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder. If any environment
# needs to deploy a different module version, it should redefine this block with a different ref to override the
# deployed version.
terraform {
  source = "${local.base_source_url}"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env        = local.environment_vars.locals.environment
  project_id = local.environment_vars.locals.project_id
  region     = local.region_vars.locals.region

  # Expose the base source URL so different versions of the module can be deployed in different environments. This will
  # be used to construct the terraform block in the child terragrunt configurations.
  # base_source_url = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-modules-example.git//mysql"
  base_source_url = "${get_repo_root()}/modules//httpbin"
}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  project_id = local.project_id
  region     = local.region
  cluster_name           = dependency.gke.outputs.cluster_name
  cluster_endpoint       = dependency.gke.outputs.kubernetes_endpoint
  cluster_ca_certificate = dependency.gke.outputs.ca_certificate
  chart                  = "${get_repo_root()}/charts/httpbin"
}

dependency "gke" {
  config_path = "${get_terragrunt_dir()}/../gke"
  mock_outputs = {
    cluster_name = "example"
    kubernetes_endpoint = "192.0.2.0"
    ca_certificate = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUVMVENDQXBXZ0F3SUJBZ0lSQUlHc2xzVGZiRjJEN21VV0VQalQ0aHd3RFFZSktvWklodmNOQVFFTEJRQXcKTHpFdE1Dc0dBMVVFQXhNa01HWTROMk13TXpBdE56SmlNQzAwTmpJMkxXSXpOakF0TjJFMU5HRTBOR1psWm1NMgpNQ0FYRFRJeU1EVXdOakl5TWpNek5sb1lEekl3TlRJd05ESTRNak15TXpNMldqQXZNUzB3S3dZRFZRUURFeVF3ClpqZzNZekF6TUMwM01tSXdMVFEyTWpZdFlqTTJNQzAzWVRVMFlUUTBabVZtWXpZd2dnR2lNQTBHQ1NxR1NJYjMKRFFFQkFRVUFBNElCandBd2dnR0tBb0lCZ1FDVkRKZnQwUFBXL2dkVkpFcGdJUDBjL1J1TGhyaWdQTllQcjJMWQphWWoxamVnbTUvMFVZZjdtUEs4N3VSWkVlR09FWENwazdnaTU1bmJmZXR5ZXRybHBjc2NmeDdHT2xBZnArL0lJClVOaUppR3Jkb3lQRUJkMVlYOWJ4UjlVb0F2SDFwUFMvMmVZU04zMGtSTEJRVGxySTYxcVRudEF2TXA0YzFZZEcKRHhsMlloUFY5anZzUkJPMm13K1ExNFZoZk9ycVRLRTBOUkNrcTJBNG5xOFdGWURIRDFWcnMxYkZNTHpUaU1sVApkT1R1Q2l1WUczUTg1RjAvQkpIWDRrUUZDZnlqVUVhdDNCZTA1aWU5cnZ0MER4a1c1VHk4c01STGQ5dE93V1BkCk9HUlh5c2RJVm4zV1RIWno5OVg5ako0ek9GekNsbzFiL0MyRmduS0JlYWYrRkoxaTBDd3N6ajE5dUFaNWVnSmUKZFFhSGlybTZTNDd5RTd0VTNzUlArQURrSHZHQkFkSUhPcUYvRVZpcWtaZXR4OFUwa3MwWmpuMERrT09LZGhUaQpNaXRPYXlrYXZ4eDBZRk5KdDk4b2QyNkk2V05xanpheE50YkMzY2IrbklML3BBOXcrNW1BaEFnVFBUVVAvb0lmCkFFN3lBcEVLQUtKQ0JDeS93T2Ixd01lcWwvc0NBd0VBQWFOQ01FQXdEZ1lEVlIwUEFRSC9CQVFEQWdJRU1BOEcKQTFVZEV3RUIvd1FGTUFNQkFmOHdIUVlEVlIwT0JCWUVGTnVSdm1pYTV4VG8rVnFoRENKQjc5dTRzTjJUTUEwRwpDU3FHU0liM0RRRUJDd1VBQTRJQmdRQWhmSEkrQ3lCOXUrRGhyQmhBN01xU1QzMERLdXBoTVFMQzF3Ylc1aldECmNybCtoemQyTll3Z2F6c2d5dXlwMlhHdW0vUXpCazR4TG9DeE9jRCtZWW5LeXhuUndCNUw3M2ovSkVlb0lNSE8KLzYwMlZVckhIcms0VGZWK3ZQcnFVZEdEZ21kOE54K2NvdGtrK1k0Q05WdzJPN2lyMEprTVQ5djRjaFpJWkhkSQp5N1FkZ0tHd0gwazhsRXpaVnpLZ0ltWGZheVFzNHdFS2tzN0ZsWDZnS0VYRmFnb0RBakppeVdKMGNhbEswTmtGCldNSEloTFBVNmhQYjJmak5IbENJQkpZdFk2SUJPZ1QwQTlaNW1HZ2pHdllXSGVmdWVhQ3NQcmV4cHBZYUZUU3UKdElLRU5XVE5LNFBXc2lZTzFWNitsTnVNMHBTWGdkVytmQTVMTG1hSjBPeGdLZ1lxbGd1RnJKOWVpbXJ6TFNxTwphRUxSMmRNeERDOFVPQk9PR2dndlMxMzV3Tmk4R3BEZWgydm5OVWpRZ0cySUIwRWJ2ZjV2QVdHVTFmL0trUWhhCkdWbjZPdjJIY1NzQTROcGlEeXpGTjViU1NGRTNUejdtYnVZYnZXRm81eS9wSWFwRkFuNDIyZXpvY21BY1hEcmwKNUlnMFBqN0t5TFhNcWsySE1PcFF3Nzg9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
  }
}

dependency "istio" {
  config_path = "${get_terragrunt_dir()}/../istio"
  skip_outputs = true
}
