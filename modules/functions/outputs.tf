// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "application_ids" {
  value = {
    for application in oci_functions_application.this :
      application.display_name => application.id
  }
}

output "function_ids" {
  value = {
    for function in oci_functions_function.this :
      function.display_name => function.id
  }
}