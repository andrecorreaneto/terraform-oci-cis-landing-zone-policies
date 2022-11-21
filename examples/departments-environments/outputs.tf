# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "cmp_name_to_cislz_tag_map" {
  value = module.cislz_policies.cmp_name_to_cislz_tag_map
}

output "cmp_type_list" {
  value = module.cislz_policies.cmp_type_list
}