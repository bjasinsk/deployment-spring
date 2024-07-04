# Spring Deployment Project

This project demonstrates various deployment strategies for a Spring application using different technologies. The project is divided into three labs, each focusing on a different deployment method.

## Labs Overview

### Lab 1: Deploy with Azure

This lab include deploy a Spring application using Microsoft Azure. The configuration scripts set up the necessary infrastructure and deploy application.

#### Files:

- `config1/`: Contains configuration scripts for the first deployment setup.
- `config42/`: Contains configuration scripts for the fourth deployment setup.

#### Key Scripts:

- `config.sh`: Main configuration script.
- `initMachinesConfig1.sh`: Initializes the machines.
- `run-all.sh`: Runs all necessary services.
- `destroyConfig1.sh`: Destroys the created Azure resources.

### Lab 2: Deploy with Ansible

This lab focuses on using Ansible to deploy a Spring application. Ansible playbooks and configuration files are provided to automate the deployment process.

#### Files:

- `azure-requirements.txt`: Lists the necessary packages for Azure.
- `create_all_vms.yml`: Ansible playbook to create all VMs.
- `back_playbook.yml`: Playbook for deploying the backend.
- `db_playbook.yml`: Playbook for setting up the database.
- `front_playbook.yml`: Playbook for deploying the frontend.

#### Key Scripts:

- `run_all.sh`: Runs all playbooks.
- `destoy.yml`: Ansible playbook to destroy the setup.

### Lab 3: Deploy with Kubernetes

In this lab, Kubernetes is used for deploying the Spring application. This involves creating Kubernetes configurations and scripts to manage the deployment.

#### Files:

- `deploy.sh`: Script to deploy the application using Kubernetes.
- `destroy_config.sh`: Script to destroy the Kubernetes setup.
