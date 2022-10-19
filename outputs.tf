# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "policies" {
  description = "The policies."
  value = merge(oci_identity_policy.root,oci_identity_policy.these)
} 