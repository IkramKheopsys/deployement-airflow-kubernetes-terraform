# Kubernetes Infrastructure for Airflow on Google Cloud Platform

This repository contains Terraform files necessary to deploy Kubernetes infrastructure on Google Cloud Platform (GCP) for running Apache Airflow.

## Prerequisites

Before using these scripts, make sure you have:

- A Google Cloud Platform account with a created project.
- Terraform installed on your local machine.
- A valid Kubernetes configuration in `~/.kube/config` to access your Kubernetes cluster.

## Configuration

The `main.tf` file contains Terraform configuration to deploy the required infrastructure.

### Google Provider

The Google Cloud Platform provider is configured with the following details:

- Project: `kheopsys-lab`
- Region: `us-central1`
- Zone: `us-central1-a`

### Required Google Cloud Platform Services

The Container Engine service is enabled for the `kheopsys-lab` project to allow Kubernetes cluster creation.

### Google Service Account

A Google service account is created with the ID `kheopsys-data-lab` and the display name "Service Account."

### Kubernetes Cluster

A Kubernetes cluster named `kuber-global-infra` is created in the `us-central1` region with a single node pool.

### Kubernetes Node Pool

A Kubernetes node pool named `my-node-pool` is configured for the Kubernetes cluster with the following specifications:

- Machine Type: `e2-medium`
- Service Account: linked to the previously created Google service account
- Preemptible nodes enabled
- OAuth permissions required for accessing Google Cloud Platform resources

### Airflow Deployment

An Airflow deployment named `airflow` is configured with the following specifications:

- Image: `apache/airflow:latest`
- Environment Variables:
  - `AIRFLOW__CORE__SQL_ALCHEMY_CONN`: MySQL database connection for Airflow
  - (Optional) `AIRFLOW__CORE__EXECUTOR`: Airflow Executor (commented out in the code)

### Kubernetes Service

A Kubernetes service named `airflow` is created to expose the Airflow deployment with the following specifications:

- Type: `LoadBalancer`
- Port: 8080

## Usage

1. Clone this repository to your local machine.
2. Ensure your Kubernetes configuration is correctly set up.
3. Run `terraform init` to initialize Terraform.
4. Run `terraform apply` to deploy the infrastructure on Google Cloud Platform.
5. Once the deployment is complete, you can access Airflow via the external IP address of the LoadBalancer service.

## Cleanup

After use, remember to destroy the created resources to avoid unnecessary charges. Run `terraform destroy` to remove the infrastructure.

