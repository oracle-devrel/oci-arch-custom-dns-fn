// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "ocir_scan_policies" {
  count                         = local.image_scan_required ? 1 : 0
  providers                     = { oci = oci.target_region }
  source                        = "./modules/policies"
  policy_params                 = local.vulnerability_scan_policy_params
  dynamic_group_params          = {}
  compartment_ids               = local.compartment_ids
  tenancy_ocid                  = var.tenancy_ocid
}

module "events" {
  depends_on                    = [module.fn]
  providers                     = { oci = oci.target_region }
  source                        = "./modules/events"
  events_rule_params            = local.events_rule_params
  compartment_ids               = local.compartment_ids
  function_ids                  = module.fn.function_ids
  topic_ids                     = var.topic_ids
  stream_ids                    = var.stream_ids
}

module "functions_policies" {
  count                         = var.create_functions_policies ? 1 : 0
  providers                     = { oci = oci.home_region }
  source                        = "./modules/functions_policies"
  compartment_ids               = local.compartment_ids
  tenancy_ocid                  = var.tenancy_ocid
  function_ids                  = module.fn.function_ids
  parent_compartment            = "monitored_compartment"
  subnet_compartment            = "subnet_compartment"
  defined_tags                  = merge(var.default_defined_tags, { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release })
  freeform_tags                 = var.default_freeform_tags
}

module "fn" {
  providers                     = { oci = oci.target_region }
  source                        = "./modules/functions"
  application_params            = local.application_params
  function_params               = local.function_params
  apm_domain_ids                = var.apm_domain_ids
  compartment_ids               = local.compartment_ids
  kms_key_ids                   = var.kms_key_ids
  nsg_ids                       = var.nsg_ids
  region                        = var.region
  subnet_ids                    = local.subnet_ids
  tenancy_ocid                  = var.tenancy_ocid
  ocir_user_name                = local.ocir_username
  ocir_user_auth_token          = var.oci_auth_token
  ocir_repositories             = module.ocir.container_repositories
}

module "ocir" {
  depends_on                    = [module.ocir_scan_policies]
  providers                     = { oci = oci.target_region }
  source                        = "./modules/ocir"
  container_repository_params   = local.container_repository_params
  compartment_ids               = local.compartment_ids
  region                        = var.region
  tenancy_ocid                  = var.tenancy_ocid
}


