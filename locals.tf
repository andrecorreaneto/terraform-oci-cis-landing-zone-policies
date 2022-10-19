# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {  
  #-- Group tags
  iam_admin_tag           = "iam-admin"
  cred_admin_tag          = "cred-admin"
  cost_admin_tag          = "cost-admin"
  security_admin_tag      = "security-admin"
  network_admin_tag       = "network-admin"
  database_admin_tag      = "database-admin"
  application_admin_tag   = "application-admin"
  exainfra_admin_tag      = "exainfra-admin"
  storage_admin_tag       = "storage-admin"
  auditor_tag             = "auditor"
  announcement_reader_tag = "announcement_reader"

  #-- Dynamic Group tags
  dyn_compute_agent_tag   = "dyn-compute-agent"
  dyn_database_kms_tag    = "dyn-database-kms"

  #-- Compartment tags
  enclosing_cmp_tag   = "enclosing"
  security_cmp_tag    = "security"
  network_cmp_tag     = "network"
  database_cmp_tag    = "database"
  application_cmp_tag = "application"
  exainfra_cmp_tag    = "exainfra"

  group_name_map = {for group in var.groups : group.name => split(",", group.freeform_tags["roles"])} # this produces objects like {"group-name-1" : ["role-1", "role-2"]}
  group_names = join(",", keys(local.group_name_map)) # this produces a comma separated string of group names, like "group-name-1, group-name-2, group-name-3"
  group_name_map_transpose = transpose(local.group_name_map) # this produces objects like {"role-1" : ["group-name-1"], "role-2" : ["group-name-1"]}
  group_tag_map = {for key, value in local.group_name_map_transpose : key => value[0]} # this is the same transposed matrix, but it takes group name string at index 0.

  dyn_group_name_map = {for dyn_group in var.dynamic_groups : dyn_group.name => split(",", dyn_group.freeform_tags["roles"])} # this produces objects like {"group-name-1" : ["role-1", "role-2"]}
  dyn_group_name_map_transpose = transpose(local.dyn_group_name_map) # this produces objects like {"role-1" : ["group-name-1"], "role-2" : ["group-name-1"]}
  dyn_group_tag_map = {for key, value in local.dyn_group_name_map_transpose : key => value[0]} # this is the same transposed matrix, but it takes group name string at index 0.

  cmp_name_map = {for cmp in var.compartments : cmp.name => split(",", cmp.freeform_tags["cmp-type"])} # this produces objects like {"network-cmp" : ["network", "security"]}
  cmp_name_map_transpose = transpose(local.cmp_name_map) # this produces objects like {"network" : ["network-cmp"], "security" : ["network-cmp"]}
  cmp_tag_map   = {for key, value in local.cmp_name_map_transpose : key => value[0]} # this is the same transposed matrix, but it takes compartment name string at index 0.

  policy_scope = contains(keys(local.cmp_tag_map),local.enclosing_cmp_tag) ? "compartment ${local.cmp_tag_map[local.enclosing_cmp_tag]}" : "tenancy"
}  