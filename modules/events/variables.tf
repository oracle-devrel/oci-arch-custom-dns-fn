// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  experiments = [module_variable_optional_attrs]
}

variable events_rule_params {
  description = "OCI event rule params: compartment_name, display_name, description, action, condition, etc.."
  type        = map(object({
    display_name     = string
    description      = string
    compartment_name = string
    is_enabled       = bool
    condition        = string
    freeform_tags    = optional(map(string))
    defined_tags     = optional(map(string))
    actions          = list(object({
      is_enabled       = bool
      description      = optional(string)

      is_invoke_function   = optional(bool)
      invoke_function_name = optional(string)

      is_post_to_stream    = optional(bool)
      post_to_stream_name  = optional(string)

      is_post_to_topic     = optional(bool)
      post_to_topic_name   = optional(string)
    }))
  }))
}

variable compartment_ids {
  description = "Map of compartment IDs to be used with the module"
  type        = map(string)
}

variable stream_ids {
  description = "Map of stream IDs to be available for rule actions"
  type        = map(string)
  default     = {}
}

variable function_ids {
  description = "Map of function IDs to be available for rule actions"
  type        = map(string)
  default     = {}
}

variable topic_ids {
  description = "Map of topic IDs to be available for rule actions"
  type        = map(string)
  default     = {}
}
