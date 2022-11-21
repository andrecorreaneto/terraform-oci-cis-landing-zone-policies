# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "cislz_policies" {
  source       = "../.."
  tenancy_id   = var.tenancy_id
  policy_name_prefix = "org1"
  /* 
  groups = [
    {"name":"org1-iam-admin-group",     "freeform_tags":{"roles":"iam-admin"}},
    {"name":"org1-cred-admin-group",    "freeform_tags":{"roles":"cred-admin"}},
    {"name":"org1-cost-admin-group",    "freeform_tags":{"roles":"cost-admin"}},
    {"name":"org1-sharedinfra-admin-group", "freeform_tags":{"roles":"network-admin,security-admin"}},
    {"name":"org1-cmr-admin-group",     "freeform_tags":{"roles":"div:cmr"}},
    {"name":"org1-cor-admin-group",     "freeform_tags":{"roles":"div:cor"}},
    {"name":"org1-cmr-prod-admin-group","freeform_tags":{"roles":"env:high|div:cmr"}},
    {"name":"org1-cmr-test-admin-group","freeform_tags":{"roles":"env:low|div:cmr"}}
  ]
 */
  # Groups with tenancy level roles
  groups_with_tenancy_level_roles = [
    {"name":"org1-iam-admin-group",  "roles":"iam"},
    {"name":"org1-cred-admin-group", "roles":"cred"},
    {"name":"org1-cost-admin-group", "roles":"cost"},
    {"name":"org1-sharedinfra-admin-group", "roles":"security"},
    {"name":"org1-cmr-admin-group", "roles":"basic"}
  ]

  dynamic_groups = []  
}