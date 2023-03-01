// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  // OCIR parameters
  container_repository_params = {
    "dns_automation/dns_record_add" = {
      compartment_name              = "deployment_compartment"
      display_name                  = "dns_automation/dns_record_add"
      enable_vulnerability_scanning = false
      defined_tags                  = merge(var.default_defined_tags, { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release })
      freeform_tags                 = var.default_freeform_tags
    },
    "dns_automation/dns_record_remove" = {
      compartment_name              = "deployment_compartment"
      display_name                  = "dns_automation/dns_record_remove"
      enable_vulnerability_scanning = false
      defined_tags                  = merge(var.default_defined_tags, { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release })
      freeform_tags                 = var.default_freeform_tags
    }
  }
  image_scan_required = anytrue([for k,v in local.container_repository_params: v.enable_vulnerability_scanning])
}