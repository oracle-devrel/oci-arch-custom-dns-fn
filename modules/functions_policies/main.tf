// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_identity_dynamic_group" "functions_dg" {
  name           = "dns_automation_functions_dg"
  description    = "Dynamic group for the DNS automation functions."
  compartment_id = var.tenancy_ocid
  matching_rule  = "Any { ${join(",", [
    for k, v in var.function_ids : "ALL {resource.type = 'fnfunc', resource.id = '${v}'}"
  ])} }"

  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_identity_policy" "functions_instance_policies" {
  depends_on     = [oci_identity_dynamic_group.functions_dg]
  name           = "dns_automation_functions_instance_policy"
  description    = "Policies for the DNS automation functions required to interact with instances."
  compartment_id = var.compartment_ids[var.parent_compartment]
  statements     = [
    "allow dynamic-group dns_automation_functions_dg to read instances in compartment id ${var.compartment_ids[var.parent_compartment]}",
    "allow dynamic-group dns_automation_functions_dg to read subnets in compartment id ${var.compartment_ids[var.parent_compartment]}",
    "allow dynamic-group dns_automation_functions_dg to read vnic-attachments in compartment id ${var.compartment_ids[var.parent_compartment]}",
    "allow dynamic-group dns_automation_functions_dg to read vnics in compartment id ${var.compartment_ids[var.parent_compartment]}",
    "allow dynamic-group dns_automation_functions_dg to use vnics in compartment id ${var.compartment_ids[var.parent_compartment]} where any { request.operation = 'UpdateVnic' }",
    "allow dynamic-group dns_automation_functions_dg to use instances in compartment id ${var.compartment_ids[var.parent_compartment]} where any { request.operation = 'UpdateInstance' }"
  ]
  
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}


resource "oci_identity_policy" "functions_network_policies" {
  depends_on     = [oci_identity_dynamic_group.functions_dg]
  name           = "dns_automation_functions_network_policy"
  description    = "Policies for the DNS automation functions required to interact with networking resources."
  compartment_id = var.compartment_ids[var.subnet_compartment]
  statements     = [
    "allow dynamic-group dns_automation_functions_dg to read subnets in compartment id ${var.compartment_ids[var.subnet_compartment]}",
    "allow dynamic-group dns_automation_functions_dg to read vnic-attachments in compartment id ${var.compartment_ids[var.subnet_compartment]}",
    "allow dynamic-group dns_automation_functions_dg to read vnics in compartment id ${var.compartment_ids[var.subnet_compartment]}",
    "allow dynamic-group dns_automation_functions_dg to use vnics in compartment id ${var.compartment_ids[var.subnet_compartment]} where any { request.operation = 'UpdateVnic' }",
    "allow dynamic-group dns_automation_functions_dg to use dns in compartment id ${var.compartment_ids[var.subnet_compartment]} where any { request.operation = 'PatchZoneRecords', request.operation = 'GetZone', request.operation = 'GetZoneRecords' }",
  ]

  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}