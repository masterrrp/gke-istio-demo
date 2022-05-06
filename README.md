# Terragrunt + Helm + GKE + Istio Demo

This repo and README are heavily influced by the [terragrunt-infrastructure-live-example repo](https://github.com/gruntwork-io/terragrunt-infrastructure-live-example), [terragrunt-infrastructure-modules-example
repo](https://github.com/gruntwork-io/terragrunt-infrastructure-modules-example) and [helm-starter-istio repo](https://github.com/salesforce/helm-starter-istio) so please make a point to check those out.

<img align="right" src="https://i.imgur.com/6cM2eUU.png">

This repo details the use of terragrunt, terraform, and helm to
deploy a VPC, k8s cluster, istio (default profile), and HTTPBin across two environments (dev and stage) in two projects in a single GCP account all without duplicating any of the Terraform code. Because of Terragrunt there is just a single copy of
the Terraform code, defined in the `/modules` folder, in the `/non-prod` folder we use
`terragrunt.hcl` files that reference the modules and charts and fill in variables specific to each
environment. Check out the dependency graph to the right for quick look into how the modules/charts are linked together.

There are a quite a few anti-patterns in here which are justified to simplify getting started:
- live repo and modules should be separated for
  - sercurity reasons
  - easy upgrades using git tags
  - module version locking
- similar reasons for separating out the helm charts e.g. the httpbin chart
- check out the todo section to get an idea of other things you consider

<!-- <br clear="right"/> -->

## How do you deploy the infrastructure in this repo?


### Pre-requisites

1. Install [Terraform](https://www.terraform.io/) version `1.1.9` and
   [Terragrunt](https://github.com/gruntwork-io/terragrunt) version `v0.36.8` or newer.
1. Update the `bucket` parameter in the root `terragrunt.hcl`. We use GCS [as a Terraform
   backend](https://www.terraform.io/docs/backends/types/gcs.html) to store the
   Terraform state. Alternatives, you can
   set the environment variable `TG_BUCKET_PREFIX` to set a custom prefix.
2. Configure your GCP credentials using one of the supported [authentication
   mechanisms](https://www.terraform.io/docs/providers/google/#authentication).
3. Fill in your GCP project_id in `non-prod/account.hcl`, this is used for the terraform state bucket.
4. Fill in your GCP project_id in `non-prod/stage/env.hcl` and `non-prod/dev/env.hcl` to declare which project is your dev and stage.


### Deploying a single module

1. `cd` into the module's folder (e.g. `cd non-prod/us-west1/dev/gke`).
2. Run `terragrunt plan` to see the changes you're about to apply.
3. If the plan looks good, run `terragrunt apply`.

### Deploying all modules in a environment

1. `cd` into the region folder (e.g. `cd non-prod/us-west1/dev`).
2. Run `terragrunt run-all plan` to see all the changes you're about to apply.
3. If the plan looks good, run `terragrunt run-all apply`.

### Deploying all modules in a region

1. `cd` into the region folder (e.g. `cd non-prod/us-west1`).
2. Run `terragrunt run-all plan` to see all the changes you're about to apply.
3. If the plan looks good, run `terragrunt run-all apply`.


## How is the code in this repo organized?

The code in this repo uses the following folder hierarchy:

```
account
 └ _global
 └ region
    └ _global
    └ environment
       └ resource
```

Where:

* **Account**: At the top level are each of your GCP accounts, such as `non-prod-account`, `prod-account`, `mgmt-account`,
  etc. If you have everything deployed in a single GCP account, there will just be a single folder at the root (e.g.
  `main-account`).

* **Region**: Within each account, there will be one or more, such as
  `us-east1` and `us-west1`, where you've deployed resources.

* **Environment**: Within each region, there will be one or more "environments", such as `dev`, `stage`, etc. Typically,
  an environment will correspond to a single VPC, which
  isolates that environment from everything else in that GCP account.

* **Resource**: Within each environment, you deploy all the resources for that environment, such as VMs, GKE, load balancers, and so on. Note that the Terraform code for theses resources lives in `/modules`.

## Todo List
- [ ] support for service account impersonation
- [ ] support for multiple GCP accounts
- [ ] support mock outputs to allow succesful validation
- [ ] add additional documentation for terraform GCP authentication
- [ ] add additional documentation for testing the infrastructure and apps after they are deployed
- [ ] extend some of the heavily used helm values into the terraform modules for istio and httpbin
- [ ] consider breaking out the networking portion of the gke module