# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#--------------------------------------------------------------------------------------------
#-- Tenancy level (Root) policies definition
#-- Notice that each policy is conditioned to the existence of applicable grants 
#--------------------------------------------------------------------------------------------

locals {
  #--------------------------------------------------------------------------------------------  
  #-- Common policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  common_admin_root_policy_key = "${var.policy_name_prefix}-common-root-policy"
  default_common_admin_root_policy_name = "common-root-policy"
  common_admin_root_policy_name = var.common_admin_root_policy_name != null ? var.common_admin_root_policy_name : "${var.policy_name_prefix}-${local.default_common_admin_root_policy_name}"
  
  #-- Grants
  common_grants_on_root_cmp = [
    "allow group ${local.group_names} to use cloud-shell in tenancy",
    "allow group ${local.group_names} to read usage-budgets in tenancy",
    "allow group ${local.group_names} to read usage-reports in tenancy"
  ]

  #-- Policy  
  common_admin_root_policy = length(local.common_grants_on_root_cmp) > 0 ? {
    (local.common_admin_root_policy_key) = {
      name           = local.common_admin_root_policy_name
      compartment_id = var.tenancy_id
      description    = "CIS Landing Zone root compartment policy common to all groups."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.common_grants_on_root_cmp
    }
  } : {}

  #--------------------------------------------------------------------------------------------  
  #-- IAM admin policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  iam_admin_root_policy_key = "${var.policy_name_prefix}-iam-root-policy"
  default_iam_admin_root_policy_name = "iam-root-policy"
  iam_admin_root_policy_name = var.iam_admin_root_policy_name != null ? var.iam_admin_root_policy_name : "${var.policy_name_prefix}-${local.default_iam_admin_root_policy_name}"

  #-- Grants
  iam_admin_grants_on_root_cmp = contains(keys(local.group_tag_map),local.iam_admin_tag) ? [
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to inspect users in tenancy",
    # Users should be manage users and groups permissions via IDP
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to inspect groups in tenancy",
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to read policies in tenancy",
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to manage groups in tenancy where all {target.group.name != 'Administrators', target.group.name != '${local.group_tag_map[local.cred_admin_tag]}'}",
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to inspect identity-providers in tenancy",
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to manage identity-providers in tenancy where any {request.operation = 'AddIdpGroupMapping', request.operation = 'DeleteIdpGroupMapping'}",
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to manage dynamic-groups in tenancy",
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to manage authentication-policies in tenancy",
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to manage network-sources in tenancy",
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to manage quota in tenancy",
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to read audit-events in tenancy",
    #"allow group ${local.group_tag_map[local.iam_admin_tag]} to use cloud-shell in tenancy",
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to manage tag-defaults in tenancy",
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to manage tag-namespaces in tenancy",
    # Statements scoped to allow an IAM admin to deploy IAM resources via ORM
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to manage orm-stacks in tenancy",
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to manage orm-jobs in tenancy",
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to manage orm-config-source-providers in tenancy"
  ] : []

  iam_admin_root_grants = concat(local.policy_scope == "tenancy" ? local.iam_admin_grants_on_enclosing_cmp : [],
                                 local.iam_admin_grants_on_root_cmp)

  #-- Policy
  iam_admin_root_policy = length(local.iam_admin_root_grants) > 0 ? {
    (local.iam_admin_root_policy_key) = {
      name           = local.iam_admin_root_policy_name
      compartment_id = var.tenancy_id
      description    = "CIS Landing Zone root compartment policy for IAM administrators."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.iam_admin_root_grants
    }
  } : {}

  #--------------------------------------------------------------------------------------------  
  #-- Credential admin policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  cred_admin_root_policy_key = "${var.policy_name_prefix}-cred-root-policy"
  default_cred_admin_root_policy_name = "cred-root-policy"
  cred_admin_root_policy_name = var.cred_admin_root_policy_name != null ? var.cred_admin_root_policy_name : "${var.policy_name_prefix}-${local.default_cred_admin_root_policy_name}"
  
  #-- Grants
  cred_admin_grants_on_root_cmp = contains(keys(local.group_tag_map),local.cred_admin_tag) ? [
    "allow group ${local.group_tag_map[local.cred_admin_tag]} to inspect users in tenancy",
    "allow group ${local.group_tag_map[local.cred_admin_tag]} to inspect groups in tenancy",
    "allow group ${local.group_tag_map[local.cred_admin_tag]} to manage users in tenancy  where any {request.operation = 'ListApiKeys',request.operation = 'ListAuthTokens',request.operation = 'ListCustomerSecretKeys',request.operation = 'UploadApiKey',request.operation = 'DeleteApiKey',request.operation = 'UpdateAuthToken',request.operation = 'CreateAuthToken',request.operation = 'DeleteAuthToken',request.operation = 'CreateSecretKey',request.operation = 'UpdateCustomerSecretKey',request.operation = 'DeleteCustomerSecretKey',request.operation = 'UpdateUserCapabilities'}"
    #"allow group ${local.group_tag_map[local.cred_admin_tag]}to use cloud-shell in tenancy"
  ] : []  

  #-- Policy
  cred_admin_root_policy = length(local.cred_admin_grants_on_root_cmp) > 0 ? {
    (local.cred_admin_root_policy_key) = {
      name           = local.cred_admin_root_policy_name
      compartment_id = var.tenancy_id
      description    = "CIS Landing Zone root compartment policy for credential administrators."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.cred_admin_grants_on_root_cmp
    }
  } : {}

  #--------------------------------------------------------------------------------------------  
  #-- Cost admin policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  cost_admin_root_policy_key = "${var.policy_name_prefix}-cost-root-policy"
  default_cost_admin_root_policy_name = "cost-root-policy"
  cost_admin_root_policy_name = var.cost_admin_root_policy_name != null ? var.cost_admin_root_policy_name : "${var.policy_name_prefix}-${local.default_cost_admin_root_policy_name}"
  
  #-- Grants
  cost_admin_grants_on_root_cmp = contains(keys(local.group_tag_map),local.cost_admin_tag) ? [
    "define tenancy usage-report as ocid1.tenancy.oc1..aaaaaaaaned4fkpkisbwjlr56u7cj63lf3wffbilvqknstgtvzub7vhqkggq", 
    "allow group ${local.group_tag_map[local.cost_admin_tag]} to manage usage-report in tenancy",
    "allow group ${local.group_tag_map[local.cost_admin_tag]} to manage usage-budgets in tenancy", 
    "endorse group ${local.group_tag_map[local.cost_admin_tag]} to read objects in tenancy usage-report"
  ] : []

  #-- Policy
  cost_admin_root_policy = length(local.cost_admin_grants_on_root_cmp) > 0 ? {
    (local.cost_admin_root_policy_key) = {
      name           = local.cost_admin_root_policy_name
      compartment_id = var.tenancy_id
      description    = "CIS Landing Zone root compartment policy for cost administrators."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.cost_admin_grants_on_root_cmp
    }
  } : {}

  #--------------------------------------------------------------------------------------------  
  #-- Security admin policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  security_admin_root_policy_key = "${var.policy_name_prefix}-security-root-policy"
  default_security_admin_root_policy_name = "security-root-policy"
  security_admin_root_policy_name = var.security_admin_root_policy_name != null ? var.security_admin_root_policy_name : "${var.policy_name_prefix}-${local.default_security_admin_root_policy_name}"

  #-- Grants
  security_admin_grants_on_root_cmp = contains(keys(local.group_tag_map),local.security_admin_tag) ? [
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage cloudevents-rules in tenancy",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage cloud-guard-family in tenancy",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to read tenancies in tenancy",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to read objectstorage-namespaces in tenancy"
  ] : []  
    #"allow group ${local.group_tag_map[local.security_admin_tag]} to use cloud-shell in tenancy",
    #"allow group ${local.group_tag_map[local.security_admin_tag]} to read usage-budgets in tenancy",
    #"allow group ${local.group_tag_map[local.security_admin_tag]} to read usage-reports in tenancy"] : []

  security_admin_root_grants = concat(local.policy_scope == "tenancy" ? local.security_admin_grants_on_enclosing_cmp : [],
                                      local.security_admin_grants_on_root_cmp)  

  #-- Policy
  security_admin_root_policy = length(local.security_admin_root_grants) > 0 ? {
    (local.security_admin_root_policy_key) = {
      name           = local.security_admin_root_policy_name
      compartment_id = var.tenancy_id
      description    = "CIS Landing Zone root compartment policy for Security administrators."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.security_admin_root_grants
    }
  } : {}

  #--------------------------------------------------------------------------------------------  
  #-- Auditor policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  auditor_policy_key = "${var.policy_name_prefix}-auditor-policy"
  default_auditor_policy_name = "auditor-policy"
  auditor_policy_name = var.auditor_policy_name != null ? var.auditor_policy_name : "${var.policy_name_prefix}-${local.default_auditor_policy_name}"

  #-- Grants
  auditor_grants = contains(keys(local.group_tag_map),local.auditor_tag) ? [
    "allow group ${local.group_tag_map[local.auditor_tag]} to inspect all-resources in tenancy",
    "allow group ${local.group_tag_map[local.auditor_tag]} to read instances in tenancy",
    "allow group ${local.group_tag_map[local.auditor_tag]} to read load-balancers in tenancy",
    "allow group ${local.group_tag_map[local.auditor_tag]} to read buckets in tenancy",
    "allow group ${local.group_tag_map[local.auditor_tag]} to read nat-gateways in tenancy",
    "allow group ${local.group_tag_map[local.auditor_tag]} to read public-ips in tenancy",
    "allow group ${local.group_tag_map[local.auditor_tag]} to read file-family in tenancy",
    "allow group ${local.group_tag_map[local.auditor_tag]} to read instance-configurations in tenancy",
    "allow group ${local.group_tag_map[local.auditor_tag]} to read network-security-groups in tenancy",
    "allow group ${local.group_tag_map[local.auditor_tag]} to read resource-availability in tenancy",
    "allow group ${local.group_tag_map[local.auditor_tag]} to read audit-events in tenancy",
    "allow group ${local.group_tag_map[local.auditor_tag]} to read users in tenancy",
    #"allow group ${local.group_tag_map[local.auditor_tag]} to use cloud-shell in tenancy",
    "allow group ${local.group_tag_map[local.auditor_tag]} to read vss-family in tenancy",       
    #"allow group ${local.group_tag_map[local.auditor_tag]} to read usage-budgets in tenancy" ,
    #"allow group ${local.group_tag_map[local.auditor_tag]} to read usage-reports in tenancy",
    "allow group ${local.group_tag_map[local.auditor_tag]} to read data-safe-family in tenancy"
  ] : []

  #-- Policy
  auditor_policy = length(local.auditor_grants) > 0 ? {
    (local.auditor_policy_key) = {
      name           = local.auditor_policy_name
      compartment_id = var.tenancy_id
      description    = "CIS Landing Zone root compartment policy for auditors."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.auditor_grants
    }
  } : {}

  #--------------------------------------------------------------------------------------------  
  #-- Announcement reader policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  announcement_reader_policy_key = "${var.policy_name_prefix}-announcement_reader-policy"
  default_announcement_reader_policy_name = "announcement_reader-policy"
  announcement_reader_policy_name = var.announcement_reader_policy_name != null ? var.announcement_reader_policy_name : "${var.policy_name_prefix}-${local.default_announcement_reader_policy_name}"

  #-- Grants
  announcement_reader_grants = contains(keys(local.group_tag_map),local.announcement_reader_tag) ? [
    "allow group ${local.group_tag_map[local.announcement_reader_tag]} to read announcements in tenancy"
    #"allow group ${local.group_tag_map[local.announcement_reader_tag]} to use cloud-shell in tenancy"
  ] : []

  #-- Policy
  announcement_reader_policy = length(local.announcement_reader_grants) > 0 ? {
    (local.announcement_reader_policy_key) = {
      name           = local.announcement_reader_policy_name
      compartment_id = var.tenancy_id
      description    = "CIS Landing Zone root compartment policy for announcement readers."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.announcement_reader_grants
    }
  } : {}

  #--------------------------------------------------------------------------------------------  
  #-- Final root policies
  #--------------------------------------------------------------------------------------------  
  root_policies = merge(local.common_admin_root_policy, local.iam_admin_root_policy, local.cred_admin_root_policy,
                        local.cost_admin_root_policy, local.security_admin_root_policy, local.auditor_policy,
                        local.announcement_reader_policy)
}  

resource "oci_identity_policy" "root" {
  for_each = local.root_policies
    name           = each.value.name
    description    = each.value.description
    compartment_id = each.value.compartment_id
    statements     = each.value.statements
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags
}