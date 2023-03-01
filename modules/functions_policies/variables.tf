// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable function_ids {
  description = "Map with function_name: function_id pairs"
  type        = map(string)
  default     = {}
}

variable compartment_ids {
  description = "Map with compartment_name: compartment_id pairs"
  type        = map(string)
  default     = {}
}

variable "tenancy_ocid" {
  type = string
}

variable "parent_compartment" {
  type = string
}

variable "subnet_compartment" {
  type = string
}

variable "freeform_tags" {
  type = map(string)
}

variable "defined_tags" {
  type = map(string)
}