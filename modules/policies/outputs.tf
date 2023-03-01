// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "dynamic_groups" {
  value = {
    for d_group in oci_identity_dynamic_group.this:
      d_group.name => d_group.id
  }
}

output "policies" {
  value = {
    for policy in oci_identity_policy.this:
      policy.name => policy.id
  }
}
