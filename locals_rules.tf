// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  events_rule_params = {
    add_record_dns_zone = {
      display_name     = "add_record_dns_zone"
      description      = "rule to trigger function which extracts new instance metadata and adds record to DNS Zone"
      compartment_name = "monitored_compartment"
      is_enabled       = true
      condition        = "{\"eventType\":[\"com.oraclecloud.computeapi.launchinstance.end\"]}"
      actions          = [{
        is_enabled       = true

        is_invoke_function   = true
        invoke_function_name = "dns_record_add"
      }]
      defined_tags     = merge(var.default_defined_tags, { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release })
      freeform_tags    = var.default_freeform_tags
    },
    remove_record_dns_zone = {
      display_name     = "remove_record_dns_zone"
      description      = "rule to trigger function which extracts terminated instance metadata and removes record from DNS Zone"
      compartment_name = "monitored_compartment"
      is_enabled       = true
      condition        = "{\"eventType\":[\"com.oraclecloud.computeapi.terminateinstance.begin\"]}"
      actions          = [{
        is_enabled       = true

        is_invoke_function   = true
        invoke_function_name = "dns_record_remove"
      }]
      defined_tags     = merge(var.default_defined_tags, { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release })
      freeform_tags    = var.default_freeform_tags
    }
  }
}