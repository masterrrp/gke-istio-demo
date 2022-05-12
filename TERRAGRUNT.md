### Deploying Using Terragrunt

#### Pre-requisites

1. Install [Terraform](https://www.terraform.io/) version `1.1.9` and
   [Terragrunt](https://github.com/gruntwork-io/terragrunt) version `v0.36.8` or newer.
2. Update the `bucket` parameter in the root `terragrunt.hcl`. We use GCS [as a Terraform
   backend](https://www.terraform.io/docs/backends/types/gcs.html) to store the
   Terraform state. Alternatives, you can
   set the environment variable `TG_BUCKET_PREFIX` to set a custom prefix.
3. Fill in your GCP `project_id` in `prod/account.hcl`, this is used for the terraform state bucket.
4. Fill in your GCP `project_id` in `prod/shared/env.hcl` to declare which project to deploy the resources.
5. You will need a GCP account and project, [create a free account here](https://cloud.google.com/free).
6. Create a GCP service account with "Owner" permissions.
7. Create a service account key, once created the key will be downloaded automatically.
8. Export your service account key using `export GOOGLE_CREDENTIALS=$(cat PATH_TO_KEY.json | tr -s '\n' ' ')`. Alternatively, configure your GCP credentials using one of the supported [authentication
   mechanisms](https://www.terraform.io/docs/providers/google/#authentication).


#### Deploying a single module

1. `cd` into the module's folder (e.g. `cd prod/us-west1/shared/gke`).
2. Run `terragrunt plan` to see the changes you're about to apply.
3. If the plan looks good, run `terragrunt apply`.

#### Deploying all modules in a environment

1. `cd` into the region folder (e.g. `cd prod/us-west1/shared`).
2. Run `terragrunt run-all plan` to see all the changes you're about to apply.
3. If the plan looks good, run `terragrunt run-all apply`.

#### Deploying all modules in a region

1. `cd` into the region folder (e.g. `cd prod/us-west1`).
2. Run `terragrunt run-all plan` to see all the changes you're about to apply.
3. If the plan looks good, run `terragrunt run-all apply`.