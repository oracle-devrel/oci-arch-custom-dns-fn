// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  ocir_repository = join("", [lower(lookup(data.oci_identity_regions.oci_regions.regions[0], "key")), ".ocir.io"])
  ocir_namespace  = lookup(data.oci_objectstorage_namespace.os_namespace, "namespace")
}


data "oci_identity_regions" "oci_regions" {
  filter {
    name   = "name"
    values = [var.region]
  }
}

data "oci_objectstorage_namespace" "os_namespace" {
  compartment_id = var.tenancy_ocid
}

resource "oci_artifacts_container_repository" "this" {
  for_each          = var.container_repository_params

  compartment_id    = var.compartment_ids[each.value.compartment_name]
  display_name      = each.value.display_name
  is_immutable      = each.value.is_immutable != null ? each.value.is_immutable : false
  is_public         = each.value.is_public != null ? each.value.is_public : false
  
  dynamic "readme" {
    for_each        = ( each.value.readme_content != null &&
                        each.value.readme_format != null ?
                          [0] :
                          []
    )
    content {
      content       = each.value.readme_content
      format        = each.value.readme_format
    }
  }
}

resource "oci_vulnerability_scanning_container_scan_recipe" "this" {
  for_each          = { for k, v in var.container_repository_params:
                          k => v
                          if v.enable_vulnerability_scanning == true
  }

  compartment_id    = var.compartment_ids[each.value.compartment_name]
  scan_settings {
      scan_level = "STANDARD"
  }

  display_name      = "${each.value.display_name}_scan"
  image_count       = 4

  defined_tags      = each.value.defined_tags
  freeform_tags     = each.value.freeform_tags
  
  lifecycle {
    ignore_changes  = [defined_tags, freeform_tags]
  }
  depends_on = [oci_artifacts_container_repository.this]
}


resource "oci_vulnerability_scanning_container_scan_target" "this" {
  for_each                  = { for k, v in var.container_repository_params:
                                  k => v
                                  if v.enable_vulnerability_scanning == true
  }

  compartment_id            = var.compartment_ids[each.value.compartment_name]
  container_scan_recipe_id  = oci_vulnerability_scanning_container_scan_recipe.this[each.key].id
  target_registry {
      compartment_id = var.compartment_ids[each.value.compartment_name]
      type           = "OCIR"
      repositories   = [each.value.display_name]
      url            = local.ocir_repository
  }

  description               = "${each.value.display_name}_scan_target"
  display_name              = "${each.value.display_name}_scan_target"

  defined_tags              = each.value.defined_tags
  freeform_tags             = each.value.freeform_tags
  
  lifecycle {
    ignore_changes  = [defined_tags, freeform_tags]
  }
  depends_on = [oci_vulnerability_scanning_container_scan_recipe.this]
}

