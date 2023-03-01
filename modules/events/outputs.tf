// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


output "rules" {
  value = {
    for rule in oci_events_rule.this:
      rule.display_name => rule.id
  }
}