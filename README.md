# koro

## Getting started

the project has one endpoint http://localhost:8080/healthcheck just returning with 200 HTTP code

```
{"status":"Running"}
```

## Start the project locally

There is a `docker-compose.yml` file building the required images locally.

To start the project locally for the first time the service `nginx_php_build` needs to run first to cache the docker
image with xdebug enabled

```
docker-compose up nginx_php_build
docker-compose up
```

after the first run just `docker-compose up` is enough

```
docker-compose up
```

#### Note:

port `8080` is required for the project to run properly

## Integrate PHPStorm

The project is ready with debugging capabilities on port `9003`
The php interpreter needs to be setup running from the `docker-compose.yml` with the service `nginx_php`.

## Gitlab Workflow

The workflow is triggered manually in a production level environment some stages should be split.

it consists of 7 jobs that can be expanded and they have the proper dependencies.

```
composer_install
docker_build_images
docker_push_images
phpunit
terraform_validate
terraform_plan
terraform_apply
```

#### Note: All must succeed to deploy the changes to AWS

## Terraform IaC

There are many ways to configure the terraform credentials but for the task scope to manage the infrastructure locally
the easiest way if you have `direnv` installed create a file with the name `.envrc` with the following values filled.

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_DEFAULT_REGION=
```

The folder `terraform` has the IaC code split in modules.

```
terraform
├──modules
│  ├──alb #for load balancer
│  │  ├──main.tf
│  │  ├──outputs.tf
│  │  └──variables.tf
│  ├──ecr #for the docker registery
│  │  ├──main.tf
│  │  ├──outputs.tf
│  │  └──variables.tf
│  └──ecs #for the cluster running the service
│     ├──main.tf
│     ├──outputs.tf
│     └──variables.tf
├──backend.tf
├──locals.tf
├──main.tf
├──outputs.tf
└──variables.tf
```

To access the web application after the `terraform apply` check the outputs it has `alb_dns_name` containing the URL.

## Enhancements on the project

These are a set of enhancements that can be applied to the project

- [ ] Combine the build image with terraform
- [ ] Split workflow to different project and include the actions only
- [ ] Show test results in GitHub project
- [ ] Run code scanners
- [ ] Add phpstorm environment for standardised code formatting in another repo
- [ ] Trigger only with pull requests the deployments steps
- [x] Enable xdebug locally
- [ ] Split php from nginx docker files
- [ ] Add autoscaling
- [ ] Add support for https
- [ ] Split terraform modules from the code base in another git repo
- [ ] Use the docker compose image in the pipeline
- [ ] Link composer install docker image to the main php image to sync the versions
- [x] Have local dev environment running from the docker-compose environment
- [x] Use docker image for composer install
- [x] Add health checks
