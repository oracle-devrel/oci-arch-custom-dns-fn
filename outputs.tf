// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "application_ids" {
  value = module.fn.application_ids
}

output "function_ids" {
  value = module.fn.function_ids
}

output "container_repositories" {
  value = module.ocir.container_repositories
}
