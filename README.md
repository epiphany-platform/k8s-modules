# k8s-modules

Terraform modules for AKS and EKS which can be used alongside Epiphany.

## Usage

### Introduction

AKS and EKS modules use existing resources created by Epiphany e.g. resource groups, subnets etc. First step is to create infrastructure with Epiphany. Then, taking advantage of possibility to deploy custom Terraform scripts with Epiphany - AKS or EKS can be installed. Finally, after obtaining kubeconfig from Kubernetess service, it is possible to deploy Epiphany apps on top of that cluster.

### 1. Creating Epiphany cluster infrastructure

Follow documentation from [Epiphany](https://github.com/epiphany-platform/epiphany) in order to create infrastructure.
Prefereable way at this point is to create Epiphany cluster without ansible provisioning, which means applying with `--skip-config` flag set - see `epicli apply -h` to learn more. Note that usage of AKS/EKS assumes that your infrastructure will not include kubernetes machines - Epiphany do not support managing both services withing one cluster.

Basic configuration example:

  ```yaml
  kind: epiphany-cluster
  title: Epiphany cluster Config
  name: default
  provider: azure
  specification:
    name: your-cluster-name
    admin_user:
      name: operations # <----- make sure os-user is correct
      key_path: /tmp/shared/vms_rsa # <----- use generated key file
    cloud:
      k8s_as_cloud_service: true # <----- make sure that flag is set, as it indicates usage of a managed Kubernetes service
    components:
      repository:
        count: 1
      kubernetes_master:
        count: 0
      kubernetes_node:
        count: 0
      logging:
        count: 0
      monitoring:
        count: 0
      kafka:
        count: 0
      postgresql:
        count: 1
      load_balancer:
        count: 0
      rabbitmq:
        count: 0
  ---
```

Please ensure that you supply correct user for your cloud provider:

```yaml
Azure:
    redhat: ec2-user
    ubuntu: operations
AWS:
    redhat: ec2-user
    ubuntu: ubuntu
```

### 2. Re-using Terraform modules for AKS/EKS

In order to deploy AKS or EKS alongside existing Epiphany cluster, copy content of the directory: `aks` or `eks`, according to the provider used in your cluster. These terraform templates have to be copied inside your build directory, under terrafrom path: `/shared/build/clustername/terraform/`.
See [How to additional custom terrafrom templates](https://github.com/epiphany-platform/epiphany/blob/develop/docs/home/howto/CLUSTER.md#how-to-additional-custom-terraform-templates) to learn more.

### 3. Deploying AKS/EKS alongside Epiphany cluster

Before applying the configuration, parameters related to the AKS/EKS needs to be a provided.

#### Suppyling parameters

Both `aks` and `eks` modules contain:

- `variables.tf` - describes inputs for AKS/EKS
- `terraform.tfvars` - template configuration file used to provide input variables

In both cases (AKS/EKS) there are mandatory parameters of existing infrastructure that needs to be provided. Modules take advantage of reusing existing resources created by Epiphany. Majority of the values which are going to be reused, can be find via cloud provider dashboard or by inspecting terrafrom state file in your cluster - `/shared/build/clustername/terraform/terraform.tfstate`.

##### Mandatory parameters

**AKS:**

- `prefix`
- `rsa_pub_path`

*Note:* Parameters that have default values set in `variables.tf` are automatically fetched from existing infrastructure. However, it doesn't prevent you from applying these values manually.

**EKS:**

- `name`
- `vpc_id`
- `region`
- `private_route_table_id`
- `ec2_ssh_key`

*Note:* EKS requires 2 subnets from differect AZs. If `subnet_ids` are not provided, EKS will create 2 new subnets in existing VPC.

##### Veryfing parameters with default values

By default Epiphany provides default values for most parameters, e.g. `kubernetes_version` or `autoscaler_version`, but also `auto_scaler_profile` or `worker_groups`. These values are tested by Epiphany team, so changing them requires knowledge about both AKS/EKS.
Also, some of the parameters may differ depending on your region, e.g. for `kubernetes_version`. Please verify that values used in your configuration match criteria of your cloud provider and region.

Example for `kubernetes_version` - you can check available AKS versions by running command:

```bash
az aks get-versions --location "West Europe" --output table
```

##### Deploying module

When all required parameters are in place, you can deploy AKS/EKS with `epicli`.

*Note:* If you plan to deploy some Epiphany apps in AKS/EKS cluster, make sure that flag `--skip-config` is set. During Epiphany Ansible provisioning, `kubeconfig` from AKS/EKS lets Epiphany to connect and configure your cluster.

### 4. Getting `kubeconfig` from deployed AKS/EKS

In order to fetch kubeconfig from Terraform output variable to a file, you can use command:

```shell
terraform -chdir=/shared/build/clustername/terraform/ output kubeconfig | grep -v EOT > kubeconfig
```

Next step is to configure `aws` tool. Configuration is required in order to authenticate Epiphany communication with eks cluster.
It also gives possibility to use kubeconfig directly from local cli.

To perform basic configuration, use command:

```bash
aws configure
```

### 5. Applying Epiphany on top of AKS/EKS

1. Put `kubeconfig` in Epiphany cluster build directory - `/shared/build/clustername/kubeconfig`
2. Specify kubeconfig file - `export KUBECONFIG=/shared/build/clustername/kubeconfig`
3. Re-apply Epiphany with `epicli` - use flag `--no-infra` since infrastructure is already provisioned
