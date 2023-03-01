// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  experiments = [module_variable_optional_attrs]
}

variable "policy_params" {
  default = {}
  type    = map(object({
    name             = string
    compartment_name = string
    description      = string
    statements       = list(string)
    defined_tags     = optional(map(string))
    freeform_tags    = optional(map(string))
  }))
}

variable "dynamic_group_params" {
  default = {}
  type    = map(object({
    name           = string
    description    = string
    matching_rules = list(string)
    match_all      = bool
    defined_tags   = optional(map(string))
    freeform_tags  = optional(map(string))
  }))
}

variable compartment_ids {
  description = "Map with compartment_name: compartment_id pairs"
  type        = map(string)
  default     = {}
}

variable "tenancy_ocid" {
  type = string
}
