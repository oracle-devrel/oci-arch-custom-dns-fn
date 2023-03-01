// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  experiments = [module_variable_optional_attrs]
}

variable container_repository_params {
  description = "Container repository parameters: display_name, comparment_name"
  type        = map(object({
    compartment_name              = string
    display_name                  = string
    is_immutable                  = optional(bool)
    is_public                     = optional(bool)
    readme_content                = optional(string)
    readme_format                 = optional(string)
    enable_vulnerability_scanning = optional(bool)
    defined_tags                  = optional(map(string))
    freeform_tags                 = optional(map(string))
  }))
}

variable compartment_ids {
  description = "Map with compartment_name: compartment_id pairs"
  type        = map(string)
  default     = {}
}

variable region {
  type = string
}

variable tenancy_ocid {
  type = string
}

