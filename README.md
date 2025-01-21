# oci-arch-custom-dns-fn

[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green)  [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_oci-arch-custom-dns-fn)](https://sonarcloud.io/dashboard?id=oracle-devrel_oci-arch-custom-dns-fn) 

## Introduction

The DNS Private Zone feature within OCI's DNS service allows the users to expand the capabilities of the built-in VCN DNS resolver, enabling them to use custom domain names for the resources within the VCNs.

This sample deployment uses OCI Events to monitor a parent compartment for compute resource creation and termination. When such an event occurs, OCI Functions are triggered to maintain the records in a user-configured DNS Zone. 

In case of duplicate records, the function will attempt to generate a new hostname using the latest five characters in instance OCID.

Two free-form tags: `hostnames` and `dns_zone_record_hashes`, will be attached to the instance to confirm the DNS Zone record insertion at instance creation and DNS Zone record deletion at instance termination.

## Prerequisite

- Administrative rights (to manage OCIRs, Functions, IAM, Compute, DNS Zones, Stacks) in the tenancy.
- The DNS zone should be created before this deployment.
- The subnet used for functions must provide connectivity to OCI API via a Service Gateway or NAT Gateway.

## Getting Started

Navigate to User Profile in OCI Console and create a new [auth token](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcredentials.htm#create_swift_password). Auth token is used during deployment to push the functions container images to OCIR.

## Automated deployment

Click below button, fill-in required values and `Apply`.

[![Deploy to OCI](https://docs.oracle.com/en-us/iaas/Content/Resources/Images/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-devrel/oci-arch-custom-dns-fn/archive/refs/tags/v1.0.zip)


## Manual deployment

 **Prerequisites:** `bash`, `terraform`, `fn`, `docker`

1. Create a file named `terraform.auto.tfvars` in the root directory using below list of variables and update associated values based on your use-case:
```
tenancy_ocid            = "ocid1.tenancy.oc1...7dq"
user_ocid               = "ocid1.user.oc1...7wa"
private_key_path        = "/path/to/..../oci_api_key.pem"
private_key_password    = ""
fingerprint             = "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"
region                  = "eu-frankfurt-1"

deployment_compartment  = "ocid1.compartment.oc1...iqq"
monitored_compartment   = "ocid1.compartment.oc1...iqq"
application_subnet      = "ocid1.subnet.oc1...uca"

oci_username            = "oracleidentitycloudservice/alice@oracle.com"
oci_auth_token          = "<generated_auth_token>"
dns_zone_ocid           = "ocid1.dns-zone.oc1...a4q"

```
2. Execute `terraform init`
3. Execute `terraform plan`
4. Execute `terraform apply`

## Customization

The function code is written in Python and can be customized by modifying `func.py` file in the two archives under `utils` directory. After code change, pack the code in a container image, push the new container image to OCIR and update the function container image.

## Manual Test
  - Create an instance, confirm if a DNS A record is added to the DNS zone and the two free-form tags (`hostnames` and `dns_zone_record_hashes`) are present on the instance.
  - Terminate the instance and confirm if the DNS record was removed.

## Notes/Issues
* Use OCI Functions logging to troubleshoot any issue with function execution.
## URLs
* Nothing at this time

## Contributing
This project is open source. Please submit your contributions by forking this repository and submitting a pull request! Oracle appreciates any contributions that are made by the open-source community.

## License
Copyright (c) 2024 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](LICENSE.txt) for more details.

ORACLE AND ITS AFFILIATES DO NOT PROVIDE ANY WARRANTY WHATSOEVER, EXPRESS OR IMPLIED, FOR ANY SOFTWARE, MATERIAL OR CONTENT OF ANY KIND CONTAINED OR PRODUCED WITHIN THIS REPOSITORY, AND IN PARTICULAR SPECIFICALLY DISCLAIM ANY AND ALL IMPLIED WARRANTIES OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR PURPOSE.  FURTHERMORE, ORACLE AND ITS AFFILIATES DO NOT REPRESENT THAT ANY CUSTOMARY SECURITY REVIEW HAS BEEN PERFORMED WITH RESPECT TO ANY SOFTWARE, MATERIAL OR CONTENT CONTAINED OR PRODUCED WITHIN THIS REPOSITORY. IN ADDITION, AND WITHOUT LIMITING THE FOREGOING, THIRD PARTIES MAY HAVE POSTED SOFTWARE, MATERIAL OR CONTENT TO THIS REPOSITORY WITHOUT ANY REVIEW. USE AT YOUR OWN RISK. 
