// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  experiments = [module_variable_optional_attrs]
}

## Provider

variable region {
  type = string
}

variable tenancy_ocid {
  type = string
}

## Default tagging

variable default_defined_tags {
  description = "Default defined tags to attach to all created resources."
  type        = map(string)
  default     = {}
}

variable default_freeform_tags {
  description = "Default freeform tags to attach to all created resources."
  type        = map(string)
  default     = {}
}

## Compartments

variable deployment_compartment {
  type        = string
  description = "In what compartment should application/functions/OCIRs be placed?"
}

variable monitored_compartment {
  type        = string
  description = "What is the parent compartment for which instance events should be captured for DNS records management?"
}

variable application_subnet {
  type        = string
  description = "What subnet should functions use to call OCI API?"
}

variable subnetCompartment {
  description = "OCID of the comparment where Function subnet and DNS zone is placed."
  type        = string
}


## Credentials

variable oci_username {
  description = "Username to use for authentication to OCI devops service"
  type        = string
}

variable oci_auth_token {
  description = "User authentication token to use for authentication to OCI services"
  type        = string
}


## Event variables

variable stream_ids {
  description = "Map of stream IDs to be available for rule actions"
  type        = map(string)
  default     = {}
}

variable topic_ids {
  description = "Map of topic IDs to be available for rule actions"
  type        = map(string)
  default     = {}
}

## Common Variables

variable apm_domain_ids {
  description = "Map with apm_domain_name: apm_domain_id pairs"
  type        = map(string)
  default     = {}
}

variable kms_key_ids {
  description = "Map with kms_key_name: kms_key_id pairs"
  type        = map(string)
  default     = {}
}

variable nsg_ids {
  description = "Map with nsg_name: nsg_id pairs"
  default     = {}
  type        = map(string)
}

variable release {
  description = "Release version"
  type        = string
  default     = "v1.0"
}

variable dns_zone_ocid {
  description = "OCID of the DNS Zone"
  type        = string
}

variable create_functions_policies {
  description = "Create required policies for function to interact with OCI API?"
  type        = bool
  default     = true
}