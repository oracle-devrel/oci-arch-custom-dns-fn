// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  experiments = [module_variable_optional_attrs]
}

variable application_params {
  description = "Function application parameters: display_name, comparment_name, subnet_name"
  type        = map(object({
    compartment_name     = string
    display_name         = string
    subnet_names         = list(string)
    config_params        = optional(map(string))
    nsg_names            = optional(map(string))
    image_signature_keys = optional(list(string))
    syslog_url           = optional(string)
    enable_oci_logging   = optional(bool)
    oci_log_group        = optional(string)
    log_retention_days   = optional(number)
    trace_domain_name    = optional(string)
    defined_tags         = optional(map(string))
    freeform_tags        = optional(map(string))
  }))
}

variable function_params {
  description = "Function parameters: display_name, application_name, image_uri, memory_in_mbs"
  type        = map(object({
    application_name       = string
    display_name           = string
    ocir_repository        = string
    zip_with_function_code = optional(string)
    memory_in_mbs          = optional(number)
    config_params          = optional(map(string))
    ocir_image_digest      = optional(string)
    concurency_count       = optional(number)
    timeout_in_seconds     = optional(number)
    tracing_enabled        = optional(bool)
    defined_tags           = optional(map(string))
    freeform_tags          = optional(map(string))
  }))
}

variable apm_domain_ids {
  description = "Map with apm_domain_name: apm_domain_id pairs"
  type        = map(string)
  default     = {}
}

variable compartment_ids {
  description = "Map with compartment_name: compartment_id pairs"
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
  type        = map(string)
  default     = {}
}

variable ocir_repositories {
  description = "Map of ocir_repo_name : {id: repo_id, url: repo_uri} pairs"
  type        = map(object({
    id    = string
    url   = string
  }))
  default = {}
}
variable ocir_user_name {
  description = "Username to use for authentication to OCIR"
  type        = string
  default     = ""
}

variable ocir_user_auth_token {
  description = "Authentication token to use for authentication to OCIR"
  type        = string
  default     = ""
}

variable region {
  type = string
}


variable subnet_ids {
  description = "Map with subnet_name: subnet_id pairs"
  type        = map(string)
  default     = {}
}

variable tenancy_ocid {
  type = string
}
