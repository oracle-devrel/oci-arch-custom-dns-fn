// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  ocir_namespace  = lookup(data.oci_objectstorage_namespace.ns, "namespace")
  ocir_username   = join("/", [local.ocir_namespace, var.oci_username])
  compartment_ids = {
    deployment_compartment = var.deployment_compartment
    monitored_compartment  = var.monitored_compartment
    subnet_compartment     = var.subnetCompartment
    tenancy                = var.tenancy_ocid
  }
  subnet_ids      = {
    application_subnet = var.application_subnet
  }
}

