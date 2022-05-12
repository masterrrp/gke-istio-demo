# Terragrunt + Helm + GKE + _Istio_ Demo

This repo and README are heavily influced by the [terragrunt-infrastructure-live-example repo](https://github.com/gruntwork-io/terragrunt-infrastructure-live-example), [terragrunt-infrastructure-modules-example
repo](https://github.com/gruntwork-io/terragrunt-infrastructure-modules-example) and [helm-starter-istio repo](https://github.com/salesforce/helm-starter-istio) so please make a point to check those out.

<img align="right" src="https://i.imgur.com/6cM2eUU.png">

This repo details the use of terragrunt, terraform, and helm to
deploy multiple instances of a VPC, k8s cluster, istio (default profile), and a sample application without duplicating any of the Terraform code. Because of Terragrunt there is just a single copy of
the Terraform code, defined in the `modules/` folder, `terragrunt.hcl` files are used that reference the modules and charts and fill in variables specific to each
environment. Check out the dependency graph to the right for quick look into how the modules and charts are linked together in the `prod/` example. 

The `dev/` example is different in two main ways. First, the `dev/` example doesn't use istio. Second difference is httpbin has been swapped out for my own [python based timestamp sample app](https://github.com/masterrrp/timestamp). Since istio is not in place, I implented the service to be load balancer type.

Both examples will include the following; VPC's with private subnet, pod subnet, svc subnet, cloud router, and firewall rules. GKE Private Cluster with default node pools replaced with custom node pool, control plane authorized networks, and shielded nodes. For the K8s resources you can expect deployments and services to be common. In the istio configuration e.g. `prod/` the sample application also includes the addition of the virtualservice to interface with the ingressgateway. 

There are a quite a few anti-patterns in here which are mostly used to simplify getting started:
- live repo and modules should be separated to allow 
  - more access control options
  - easy upgrades using git tags/releases
  - module version locking
- similar reasons for separating out the helm charts e.g. the httpbin chart
  

Check out the [TODO List](#TODO-List) to get an idea of other items I'm considering adding down the road.

<!-- <br clear="right"/> -->

## How do you deploy the infrastructure in this repo?

For the sake of brevity this section is focused on the `dev/` account. 

### Think globally, `act` locally

By using [act](https://github.com/nektos/act) you can  run the Github workflows locally. I would just stick to `act` as it's less work to get up and running and offers more functionality however you do have a second option, using `terragrunt` directly, you can find the [terragrunt instructions here](TERRAGRUNT.md). The main caveat is the `act` workflow method is opinionated has more features such as automated tests. After you make it through this README it is definitely worthwhile diving deeper into the act project. 

#### Pre-requisites

1. Clone this repo and `cd` into the repo.
   
2. The main prerequisite for `act` is `docker` visit their docs for [more details.](https://github.com/nektos/act#necessary-prerequisites-for-running-act)

3. Install act with `brew install act`, alternative install methods available [see act's documentation](https://github.com/nektos/act#installation-through-package-managers)

4. You will need a GCP account and project, you can [create a free account here](https://cloud.google.com/free).

5. If you created a free account just use the default project otherwise I would create a new project just to keep this example separated from the rest of your existing projects in GCP.

6. In the new project we need to do a few more setup steps before we can start provisioning. 
   
7. Enable the `Cloud Resource Manager API`, by searching that in the GCP console search bar.

8. Create a GCP service account with "Owner" permissions.
   
9. Open the new service account and create a key, once created the key will be downloaded automatically.

10. Now to properly format our service account key for our automation use the following command, don't forget to change `key.json` to the path of your service account key:
      ```
      echo -E "DEV_GOOGLE_CREDENTIALS='$(cat key.json | tr -s '\n' ' ')'" >> .env
      ```
      **Note:** On MacOS my service account key was downloaded to `~/Downloads/development-349403-xxxxxxxxx.json`

11. Fill in your GCP `project_id` in:
    - `dev/account.hcl`, this is used for the terraform state bucket.
    - `dev/shared-non-istio/env.hcl` to declare which project to deploy the resources.

11. Optionally, update the `bucket` parameter in the root `terragrunt.hcl`. We use GCS [as a Terraform
      backend](https://www.terraform.io/docs/backends/types/gcs.html) to store the
      Terraform state. Optionally you can
      set the environment variable `TG_BUCKET_PREFIX` to set a custom prefix.

**Note:** If you are interested in the `prod/` account, it's pretty simple. Any where you see `dev` swap it to `prod` and `DEV` swap it to `PROD`.

### Deploying all modules in an account

The github workflow will only interact with account mapped to the branch you currently have checked out. For example dev branch maps to `dev/` account folder structure and main branch maps to `prod/` account folder structure. For this example let's interact with the dev branch and in turn the `dev/` folder structure.

1. Check out the dev branch, `git checkout dev`
   
2. To graph the workflow dependencies use `act -g`, you will notice both prod and dev jobs here.
   
3. Let's execute a dry run to see which jobs will actually run, `act -n`. 
   
4. Now let's actually run the workflow, `act --secret-file .env`

### Destroying all modules in an account

The workflow will only interact with account mapped to the branch you currently have checked out.

1. Check out the dev branch, `git checkout dev`
   
2. Let's execute a dry run to see which jobs will actually run, `act workflow_call -W ./.github/workflows/destroy_terragrunt.yml --secret-file .env -n`
   
3. Now let's actually run the workflow, `act workflow_call -W ./.github/workflows/destroy_terragrunt.yml --secret-file .env`



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

* **Account**: At the top level are each of your GCP accounts, such as `dev`, `prod`, `non-prod-account`, `prod-account`, `mgmt-account`,
  etc. If you have everything deployed in a single GCP account, you could use just a single folder at the root (e.g.
  `main-account`).

* **Region**: Within each account, there will be one or more, such as
  `us-east1` and `us-west1`, where you've deployed resources.

* **Environment**: Within each region, there will be one or more "environments", such as `shared`, `stage`, `backend`, etc. Typically,
  an environment will correspond to a single VPC, which
  isolates that environment from everything else in that GCP account.

* **Resource**: Within each environment, you deploy all the resources for that environment, such as VMs, GKE, load balancers, and so on. Note that the Terraform code for theses resources lives in `/modules`. As well as applications such as the `prod/us-west1/shared/httpbin/` or `dev/us-west1/shared-non-istio/timestamp/`.

## TODO List
- [x] support for service account
- [x] support mock outputs to allow succesful validation
- [x] support multiple GCP projects
- [ ] support for service account impersonation
- [ ] support for multiple GCP accounts
- [ ] add additional documentation for terraform GCP authentication
- [ ] add additional documentation for testing the infrastructure and apps after they are deployed
- [ ] extend some of the heavily used helm values into the terraform modules for istio and httpbin
- [ ] consider breaking out the networking portion of the gke module
- [ ] Make workflow DRYer, using composite actions
- [ ] Add documentation about workflows
- [ ] Consider adding direnv to the docs for ease of use
- [ ] Break this repo down
  - [ ] Move httpbin chart to it's own repo
  - [ ] Move tf modules to their own repo
  - [ ] Update this example to reference new module and chart repos