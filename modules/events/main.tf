// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


resource "oci_events_rule" "this" {
  for_each       = var.events_rule_params


  compartment_id = var.compartment_ids[each.value.compartment_name]
  condition      = each.value.condition
  display_name   = each.value.display_name
  description    = each.value.description
  is_enabled     = each.value.is_enabled
  
  actions {
    dynamic "actions" {
      for_each   = each.value.actions
      iterator   = action
      content {
          action_type = ( action.value.is_invoke_function == true ?
                            "FAAS" :
                            action.value.is_post_to_stream == true ?
                              "OSS" :
                              action.value.is_post_to_topic == true ?
                                "ONS" :
                                "no action attribute set to true"
          )
          is_enabled = action.value.is_enabled

          description = action.value.description
          function_id = action.value.is_invoke_function == true ? var.function_ids[action.value.invoke_function_name] : null
          stream_id   = action.value.is_post_to_stream == true ? var.stream_ids[action.value.post_to_stream_name] : null
          topic_id    = action.value.is_post_to_topic == true ? var.topic_ids[action.value.post_to_topic_name] : null
      }  
    }
  }

  defined_tags      = each.value.defined_tags
  freeform_tags     = each.value.freeform_tags
  
  lifecycle {
    ignore_changes  = [defined_tags, freeform_tags]
  }
}