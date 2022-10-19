# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "cislz_policies" {
  source       = "../.."
  tenancy_id   = var.tenancy_id
  policy_name_prefix = "cislandingzone"
  
  compartments = [
    {"name":"cislandingzone-top-cmp",         "freeform_tags":{"cmp-type":"enclosing"}},
    {"name":"cislandingzone-security-cmp",    "freeform_tags":{"cmp-type":"security"}},
    {"name":"cislandingzone-network-cmp",     "freeform_tags":{"cmp-type":"network"}},
    {"name":"cislandingzone-application-cmp", "freeform_tags":{"cmp-type":"application"}},
    {"name":"cislandingzone-database-cmp",    "freeform_tags":{"cmp-type":"database"}},
    {"name":"cislandingzone-exainfra-cmp",    "freeform_tags":{"cmp-type":"exainfra"}}
  ]

  groups = [
    {"name":"cislandingzone-iam-admin-group",     "freeform_tags":{"roles":"iam-admin"}},
    {"name":"cislandingzone-cred-admin-group",    "freeform_tags":{"roles":"cred-admin"}},
    {"name":"cislandingzone-cost-admin-group",    "freeform_tags":{"roles":"cost-admin"}},
    {"name":"cislandingzone-network-admin-group", "freeform_tags":{"roles":"network-admin"}},
    {"name":"cislandingzone-security-admin-group","freeform_tags":{"roles":"security-admin"}},
    {"name":"cislandingzone-app-admin-group",     "freeform_tags":{"roles":"application-admin"}},
    {"name":"cislandingzone-database-admin-group","freeform_tags":{"roles":"database-admin"}},
    {"name":"cislandingzone-exainfra-admin-group","freeform_tags":{"roles":"exainfra-admin"}},
    {"name":"cislandingzone-storage-admin-group", "freeform_tags":{"roles":"storage-admin"}},
    {"name":"cislandingzone-auditor-group",       "freeform_tags":{"roles":"auditor"}},
    {"name":"cislandingzone-announcement_reader-group","freeform_tags":{"roles":"announcement_reader"}}
  ]

  dynamic_groups = [
    {"name":"cislandingzone-iam-admin-dynamic-group", "freeform_tags":{"roles":"dyn-compute-agent"}},
    {"name":"cislandingzone-cred-admin-dynamic-group","freeform_tags":{"roles":"dyn-database-kms"}}
  ]  
}