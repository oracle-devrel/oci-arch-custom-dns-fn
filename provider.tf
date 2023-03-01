// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = ">= 0.14.0, < 1.3.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
    }
  }
}

provider "oci" {
  alias            = "target_region"
  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
}

provider "oci" {
  alias            = "home_region"
  tenancy_ocid     = var.tenancy_ocid
  region           = data.oci_identity_region_subscriptions.home_region_subscriptions.region_subscriptions[0].region_name
}