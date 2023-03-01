// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  ocir_repository_domain = join("", [lower(lookup(data.oci_identity_regions.oci_regions.regions[0], "key")), ".ocir.io"])
  ocir_namespace         = lookup(data.oci_objectstorage_namespace.os_namespace, "namespace")
  function_ocir_uri      = { for k, v in var.function_params:
                              k => ( lookup(var.ocir_repositories, v.ocir_repository, null) != null ? 
                                      "${lookup(var.ocir_repositories, v.ocir_repository).url}:first" :
                                      length(try(regex("(?flags:i):[a-z0-9.-]+$", v.ocir_repository), "")) > 0 ?
                                        v.ocir_repository :
                                        "${v.ocir_repository}:first"
                                )
  }
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

resource "oci_functions_application" "this" {
  for_each                   = var.application_params

  compartment_id             = var.compartment_ids[each.value.compartment_name]
  display_name               = each.value.display_name
  subnet_ids                 = [ for subnet_name in each.value.subnet_names : var.subnet_ids[subnet_name] ]

  #Optional
  config                     = each.value.config_params != null ? each.value.config_params : {}
  
  network_security_group_ids =  each.value.nsg_names != null ? [ for nsg_name in each.value.nsg_names : var.nsg_ids[nsg_name] ] : null
  
  dynamic "image_policy_config" {
    for_each  = ( each.value.image_signature_keys != null &&
                  each.value.image_signature_keys != [] ?
                  [0] :
                  []
    )
    iterator = ipc
    content {
      is_policy_enabled = true
      dynamic "key_details" {
        for_each = each.value.image_signature_keys
        iterator = key
        content {
          kms_key_id = var.kms_key_ids[key.value]
        }
      }
    }
  } 

  syslog_url  = ( each.value.syslog_url != null &&
                  each.value.enable_oci_logging == false &&
                  each.value.syslog_url != "" ? 
                    each.value.syslog_url :
                    null
  )

  dynamic "trace_config" {
    for_each  = ( each.value.trace_domain_name != null &&
                  each.value.trace_domain_name != "" ?
                  [0] :
                  []
    )
    iterator = tc
    content {
      domain_id  = true
      is_enabled = var.apm_domain_ids[each.value.trace_domain_name]
    }
  }

  defined_tags               = each.value.defined_tags
  freeform_tags              = each.value.freeform_tags
  
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}


resource "oci_functions_function" "this" {
  for_each                   = var.function_params

  application_id             = oci_functions_application.this[each.value.application_name].id
  display_name               = each.value.display_name
  image                      = local.function_ocir_uri[each.key]
  memory_in_mbs              = each.value.memory_in_mbs != null ? each.value.memory_in_mbs : 256

  #Optional
  config                     = each.value.config_params != null ? each.value.config_params : {}

  image_digest               = each.value.ocir_image_digest
  
  provisioned_concurrency_config {
      #Required
      strategy =  ( each.value.concurency_count != null ?
                      ( each.value.concurency_count > 0 ?
                          "CONSTANT" :
                        "NONE" ) :
                      "NONE"
      )

      #Optional
      count = ( each.value.concurency_count != null ?
                      ( each.value.concurency_count > 0 ?
                          each.value.concurency_count :
                        null ) :
                      null
      )
  }
  
  timeout_in_seconds         = each.value.timeout_in_seconds != null ? each.value.timeout_in_seconds : 30
  
  dynamic "trace_config" {
    for_each  = each.value.tracing_enabled != null ? [0] : []
    content {
      is_enabled = each.value.tracing_enabled
    }
  }
  
  defined_tags               = each.value.defined_tags
  freeform_tags              = each.value.freeform_tags
  
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }

  depends_on = [null_resource.FnPush2OCIR]
}


data "oci_logging_log_groups" "this" {
  for_each                    = { for k, v in var.application_params: 
                                  k => v 
                                  if v.enable_oci_logging == true
  }
  
  compartment_id = var.compartment_ids[each.value.compartment_name]
}


resource "oci_logging_log_group" "this" {
  for_each                    = { for k, v in var.application_params: 
                                  k => v 
                                  if v.enable_oci_logging == true && !contains(try([for log_group in data.oci_logging_log_groups.this[k]: log_group.display_name], []), v.oci_log_group != null ? v.oci_log_group : "")
  }

  compartment_id              = var.compartment_ids[each.value.compartment_name]
  display_name                = ( each.value.oci_log_group != null &&
                                  each.value.oci_log_group != "" ?
                                    each.value.oci_log_group :
                                    "${each.value.display_name}_application_log_group"
  )
  description                 = "${each.value.display_name}_application_log_group"

  defined_tags                = each.value.defined_tags
  freeform_tags               = each.value.freeform_tags
  
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}


resource "oci_logging_log" "this" {
  for_each                    = { for k, v in var.application_params: 
                                  k => v 
                                  if v.enable_oci_logging == true
  }

  display_name                = "${each.value.display_name}_invoke"
  log_group_id                = ( try(oci_logging_log_group.this[each.key], null) != null ?
                                    oci_logging_log_group.this[each.key].id :
                                    one([ for log_group in data.oci_logging_log_groups.this[each.key]: log_group.id if log_group.display_name == each.value.oci_log_group ])
  )
  log_type                    = "SERVICE"

  configuration {
    source {
        category    = "invoke"
        resource    = oci_functions_application.this[each.key].id
        service     = "functions"
        source_type = "OCISERVICE"
    }
  }
  is_enabled                  = each.value.enable_oci_logging
  retention_duration          = each.value.log_retention_days != null ? each.value.log_retention_days : 30

  defined_tags                = each.value.defined_tags
  freeform_tags               = each.value.freeform_tags
  
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}


resource "null_resource" "Login2OCIR" {
  count  = var.ocir_user_auth_token != "" && var.ocir_user_name != "" ? 1 : 0

  provisioner "local-exec" {
    command = "echo '${var.ocir_user_auth_token}' |  docker login ${local.ocir_repository_domain} --username ${var.ocir_user_name} --password-stdin"
  }

  depends_on = [oci_functions_application.this]
  triggers   = {
    sha256 = join(", ", [ for key, value in var.function_params: filesha256("${abspath(path.root)}/${value.zip_with_function_code}") ])
  }
}


resource "null_resource" "FnPush2OCIR" {
  for_each   =  { for k, v in var.function_params:
                    k => v
                    if v.zip_with_function_code != null
  }

  # Creating image build directory
  provisioner "local-exec" {
    command     = "mkdir -p tmp_fn"
    working_dir = "${abspath(path.root)}"
  }
  
  # Unzipping function code
  provisioner "local-exec" {
    command     = "unzip -o '${abspath(path.root)}/${each.value.zip_with_function_code}' -d '${abspath(path.root)}/tmp_fn/${each.value.display_name}'"
    working_dir = "${abspath(path.root)}"
  }
  
  # Random sleep up to 20 seconds
  provisioner "local-exec" {
    command     = "sleep $[ ( $RANDOM % 30 )  + 1 ]s"
  }

  provisioner "local-exec" {
    command     = "image=$(fn build --verbose 2>/dev/null | grep 'Successfully tagged' | awk -F ' ' '{print $3}'); docker tag $image ${lower(local.function_ocir_uri[each.key])}; docker push ${lower(local.function_ocir_uri[each.key])}"
    working_dir = "${abspath(path.root)}/tmp_fn/${each.value.display_name}"
  }

  depends_on = [null_resource.Login2OCIR]
  triggers   = {
    sha256 = join(", ", [ for key, value in var.function_params: filesha256("${abspath(path.root)}/${value.zip_with_function_code}") ])
  }
}