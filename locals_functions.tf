// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  application_params = {
    dns_zone_records_automation = {
      compartment_name   = "deployment_compartment"
      display_name       = "dns_zone_records_automation"
      subnet_names       = ["application_subnet"]
      enable_oci_logging = true
      config_params      = {
        DNS_ZONE_OCID = var.dns_zone_ocid
      }
      defined_tags       = merge(var.default_defined_tags, { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release })
      freeform_tags      = var.default_freeform_tags      
    }
  }

  function_params = {
    dns_record_add = {
      application_name       = "dns_zone_records_automation"
      display_name           = "dns_record_add"
      ocir_repository        = "dns_automation/dns_record_add"
      zip_with_function_code = "utils/dns_record_add.zip"
      timeout_in_seconds     = 60
      defined_tags           = merge(var.default_defined_tags, { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release })
      freeform_tags          = var.default_freeform_tags      
    },
    dns_record_remove = {
      application_name       = "dns_zone_records_automation"
      display_name           = "dns_record_remove"
      ocir_repository        = "dns_automation/dns_record_remove"
      zip_with_function_code = "utils/dns_record_remove.zip"
      timeout_in_seconds     = 60
      defined_tags           = merge(var.default_defined_tags, { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release })
      freeform_tags          = var.default_freeform_tags    
    }
  }
}