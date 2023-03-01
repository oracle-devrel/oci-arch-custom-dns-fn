// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


resource "oci_identity_dynamic_group" "this" {
  for_each        = var.dynamic_group_params
  name            = each.value.name
  description     = each.value.description
  compartment_id  = var.tenancy_ocid
  matching_rule   = ( each.value.match_all == true ?
                        "All { ${join(",", each.value.matching_rules)} }" :
                        "Any { ${join(",", each.value.matching_rules)} }"          
  )

  defined_tags   = each.value.defined_tags != null ? each.value.defined_tag : {}
  freeform_tags  = each.value.freeform_tags != null ? each.value.freeform_tags : {}

  lifecycle {
    ignore_changes  = [defined_tags, freeform_tags]
  }
}

resource "oci_identity_policy" "this" {
  depends_on     = [oci_identity_dynamic_group.this]
  
  for_each       = var.policy_params
  
  name           = each.value.name
  description    = each.value.description
  compartment_id = var.compartment_ids[each.value.compartment_name]
  statements     = each.value.statements

  defined_tags   = each.value.defined_tags != null ? each.value.defined_tag : {}
  freeform_tags  = each.value.freeform_tags != null ? each.value.freeform_tags : {}

  lifecycle {
    ignore_changes  = [defined_tags, freeform_tags]
  }
}

