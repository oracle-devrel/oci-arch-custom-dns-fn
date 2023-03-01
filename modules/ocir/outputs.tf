// Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "container_repositories" {
  value = {
    for repository in oci_artifacts_container_repository.this :
      repository.display_name => {
        "id" : repository.id,
        "url": "${local.ocir_repository}/${local.ocir_namespace}/${repository.display_name}"
      }
  }
}