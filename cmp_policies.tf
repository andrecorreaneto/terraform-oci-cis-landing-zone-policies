# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
/* 
locals {

  #--------------------------------------------------------------------------------------------
  #-- IAM admin policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  iam_admin_policy_key = "${var.cislz_tag_lookup_value}-iam-admin-policy"
  default_iam_admin_policy_name = "iam-admin-policy"
  iam_admin_policy_name = var.iam_admin_policy_name != null ? var.iam_admin_policy_name : "${var.cislz_tag_lookup_value}-${local.default_iam_admin_policy_name}"

  #-- IAM admin grants at the enclosing compartment level, which *can* be the root compartment
  iam_admin_grants_on_enclosing_cmp = contains(keys(local.group_tag_map),local.iam_admin_tag) ? [
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to manage policies in ${local.policy_scope}", 
    "allow group ${local.group_tag_map[local.iam_admin_tag]} to manage compartments in ${local.policy_scope}"
  ] : []

  iam_admin_grants = local.policy_scope != "tenancy" ? local.iam_admin_grants_on_enclosing_cmp : []

  #-- Policy
  iam_admin_policy = length(local.iam_admin_grants) > 0 ? {
    (local.iam_admin_policy_key) = {
      name           = local.iam_admin_policy_name
      compartment_id = data.oci_identity_compartments.enclosing[0].compartments[0].id
      description    = "CIS Landing Zone policy for IAM administrators."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.iam_admin_grants
    }
  } : {}

  #--------------------------------------------------------------------------------------------
  #-- Security admin policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  security_admin_policy_key = "${var.cislz_tag_lookup_value}-security-admin-policy"
  default_security_admin_policy_name = "security-admin-policy"
  security_admin_policy_name = var.security_admin_policy_name != null ? var.security_admin_policy_name : "${var.cislz_tag_lookup_value}-${local.default_security_admin_policy_name}"

  #-- Security admin grants at the enclosing compartment level, which *can* be the root compartment
  security_admin_grants_on_enclosing_cmp = contains(keys(local.group_tag_map),local.security_admin_tag) ? [
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage tag-namespaces in ${local.policy_scope}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage tag-defaults in ${local.policy_scope}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage repos in ${local.policy_scope}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to read audit-events in ${local.policy_scope}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to read app-catalog-listing in ${local.policy_scope}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to read instance-images in ${local.policy_scope}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to inspect buckets in ${local.policy_scope}"
  ] : [] 

  #-- Security admin grants on Security compartment
  security_admin_grants_on_security_cmp = contains(keys(local.group_tag_map),local.security_admin_tag) && contains(keys(local.cmp_tag_map),local.security_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.security_admin_tag]} to read all-resources in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage instance-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    # CIS 1.2 - 1.14 Level 2
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage volume-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]} where all{request.permission != 'VOLUME_BACKUP_DELETE', request.permission != 'VOLUME_DELETE', request.permission != 'BOOT_VOLUME_BACKUP_DELETE'}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage object-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]} where all{request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage file-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]} where all{request.permission != 'FILE_SYSTEM_DELETE', request.permission != 'MOUNT_TARGET_DELETE', request.permission != 'EXPORT_SET_DELETE', request.permission != 'FILE_SYSTEM_DELETE_SNAPSHOT', request.permission != 'FILE_SYSTEM_NFSv3_UNEXPORT'}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage vaults in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage keys in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage secret-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage logging-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage serviceconnectors in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage streams in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage ons-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage functions-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage waas-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage security-zone in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage orm-stacks in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage orm-jobs in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage orm-config-source-providers in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage vss-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to read work-requests in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage bastion-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to read instance-agent-plugins in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage cloudevents-rules in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage alarms in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to manage metrics in compartment ${local.cmp_tag_map[local.security_cmp_tag]}"
  ] : []

  #-- Security admin grants on Network compartment
  security_admin_grants_on_network_cmp = contains(keys(local.group_tag_map),local.security_admin_tag) && contains(keys(local.cmp_tag_map),local.network_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.security_admin_tag]} to read virtual-network-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to use subnets in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to use network-security-groups in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.security_admin_tag]} to use vnics in compartment ${local.cmp_tag_map[local.network_cmp_tag]}"
  ] : []

  security_admin_grants = concat(local.policy_scope != "tenancy" ? local.security_admin_grants_on_enclosing_cmp : [], 
                                 local.security_admin_grants_on_security_cmp, 
                                 local.security_admin_grants_on_network_cmp)

  #-- Policy
  security_admin_policy = length(local.security_admin_grants) > 0 ? {
    (local.security_admin_policy_key) = {
      name           = local.security_admin_policy_name
      compartment_id = data.oci_identity_compartments.security[0].compartments[0].compartment_id
      description    = "CIS Landing Zone policy for Security administrators."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.security_admin_grants
    }
  } : {}
  
  #--------------------------------------------------------------------------------------------
  #-- Network admin policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  network_admin_policy_key = "${var.cislz_tag_lookup_value}-network-admin-policy"
  default_network_admin_policy_name = "network-admin-policy"
  network_admin_policy_name = var.network_admin_policy_name != null ? var.network_admin_policy_name : "${var.cislz_tag_lookup_value}-${local.default_network_admin_policy_name}"

  #network_admin_grants_on_root_cmp = contains(keys(local.group_tag_map),local.network_admin_tag) ? [
  #  "allow group ${local.group_tag_map[local.network_admin_tag]} to use cloud-shell in tenancy",
  #  "allow group ${local.group_tag_map[local.network_admin_tag]} to read usage-budgets in tenancy",
  #  "allow group ${local.group_tag_map[local.network_admin_tag]} to read usage-reports in tenancy"
  #] : []

  #-- Network admin grants on Network compartment
  network_admin_grants_on_network_cmp = contains(keys(local.group_tag_map),local.network_admin_tag) && contains(keys(local.cmp_tag_map),local.network_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.network_admin_tag]} to read all-resources in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage virtual-network-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage dns in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage load-balancers in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage alarms in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage metrics in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage ons-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]}", 
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage orm-stacks in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage orm-jobs in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage orm-config-source-providers in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to read audit-events in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to read work-requests in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    # CIS 1.2 - 1.14 Level 2
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage instance-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage volume-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]} where all{request.permission != 'VOLUME_BACKUP_DELETE', request.permission != 'VOLUME_DELETE', request.permission != 'BOOT_VOLUME_BACKUP_DELETE'}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage object-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]} where all{request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage file-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]} where all{request.permission != 'FILE_SYSTEM_DELETE', request.permission != 'MOUNT_TARGET_DELETE', request.permission != 'EXPORT_SET_DELETE', request.permission != 'FILE_SYSTEM_DELETE_SNAPSHOT', request.permission != 'FILE_SYSTEM_NFSv3_UNEXPORT'}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage bastion-session in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage cloudevents-rules in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage alarms in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage metrics in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to read instance-agent-plugins in compartment ${local.cmp_tag_map[local.network_cmp_tag]}"
  ] : []

  #-- Network admin grants on Security compartment
  network_admin_grants_on_security_cmp = contains(keys(local.group_tag_map),local.network_admin_tag) && contains(keys(local.cmp_tag_map),local.security_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.network_admin_tag]} to read vss-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to use bastion in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.network_admin_tag]} to manage bastion-session in compartment ${local.cmp_tag_map[local.security_cmp_tag]}"
  ] : []

  network_admin_grants = concat(local.network_admin_grants_on_network_cmp, local.network_admin_grants_on_security_cmp)

  #-- Policy
  network_admin_policy = length(local.network_admin_grants) > 0 ? {
    (local.network_admin_policy_key) = {
      name           = local.network_admin_policy_name
      compartment_id = data.oci_identity_compartments.network[0].compartments[0].compartment_id
      description    = "CIS Landing Zone policy for Network administrators."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.network_admin_grants
    }
  } : {}

  #--------------------------------------------------------------------------------------------
  #-- Database admin policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  database_admin_policy_key = "${var.cislz_tag_lookup_value}-database-admin-policy"
  default_database_admin_policy_name = "database-admin-policy"
  database_admin_policy_name = var.database_admin_policy_name != null ? var.database_admin_policy_name : "${var.cislz_tag_lookup_value}-${local.default_database_admin_policy_name}"

  #-- Database admin grants on Root compartment
  #database_admin_grants_on_root_cmp = contains(keys(local.group_tag_map),local.database_admin_tag) ? [
  #  "allow group ${local.group_tag_map[local.database_admin_tag]} to use cloud-shell in tenancy",
  #  "allow group ${local.group_tag_map[local.database_admin_tag]} to read usage-budgets in tenancy",
  #  "allow group ${local.group_tag_map[local.database_admin_tag]} to read usage-reports in tenancy"
  #] : []
  #-- Database admin grants on Database compartment
  database_admin_grants_on_database_cmp = contains(keys(local.group_tag_map),local.database_admin_tag) && contains(keys(local.cmp_tag_map),local.database_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.database_admin_tag]} to read all-resources in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage database-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage autonomous-database-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage alarms in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage metrics in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage cloudevents-rules in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    # CIS 1.2 - 1.14 Level 2 
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage object-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]} where all{request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage instance-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage volume-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]} where all{request.permission != 'VOLUME_BACKUP_DELETE', request.permission != 'VOLUME_DELETE', request.permission != 'BOOT_VOLUME_BACKUP_DELETE'}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage file-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]} where all{request.permission != 'FILE_SYSTEM_DELETE', request.permission != 'MOUNT_TARGET_DELETE', request.permission != 'EXPORT_SET_DELETE', request.permission != 'FILE_SYSTEM_DELETE_SNAPSHOT', request.permission != 'FILE_SYSTEM_NFSv3_UNEXPORT'}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage orm-stacks in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage orm-jobs in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage orm-config-source-providers in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage ons-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]}", 
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage logging-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]}", 
    "allow group ${local.group_tag_map[local.database_admin_tag]} to read audit-events in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to read work-requests in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage bastion-session in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to read instance-agent-plugins in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage data-safe-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]}"
  ] : []

  #-- Database admin grants on Network compartment
  database_admin_grants_on_network_cmp = contains(keys(local.group_tag_map),local.database_admin_tag) && contains(keys(local.cmp_tag_map),local.network_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.database_admin_tag]} to read virtual-network-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to use vnics in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to use subnets in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to use network-security-groups in compartment ${local.cmp_tag_map[local.network_cmp_tag]}"
  ] : [] 

  #-- Database admin grants on Security compartment
  database_admin_grants_on_security_cmp = contains(keys(local.group_tag_map),local.database_admin_tag) && contains(keys(local.cmp_tag_map),local.security_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.database_admin_tag]} to read vss-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to read vaults in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to inspect keys in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to use bastion in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage bastion-session in compartment ${local.cmp_tag_map[local.security_cmp_tag]}"
  ] : []

  #-- Database admin grants on Exainfra compartment
  database_admin_grants_on_exainfra_cmp = contains(keys(local.group_tag_map),local.database_admin_tag) && contains(keys(local.cmp_tag_map),local.exainfra_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.database_admin_tag]} to read cloud-exadata-infrastructures in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to use cloud-vmclusters in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to read work-requests in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage db-nodes in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage db-homes in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage databases in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage db-backups in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.database_admin_tag]} to manage data-safe-family in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}"
  ] : []

  database_admin_grants = concat(local.database_admin_grants_on_database_cmp, local.database_admin_grants_on_network_cmp,
                                 local.database_admin_grants_on_security_cmp, local.database_admin_grants_on_exainfra_cmp)

  #-- Policy
  database_admin_policy = length(local.database_admin_grants) > 0 ? {
    (local.database_admin_policy_key) = {
      name           = local.database_admin_policy_name
      compartment_id = data.oci_identity_compartments.database[0].compartments[0].compartment_id
      description    = "CIS Landing Zone policy for Database administrators."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.database_admin_grants
    }
  } : {}                               

  #--------------------------------------------------------------------------------------------
  #-- Application admin policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  appdev_admin_policy_key = "${var.cislz_tag_lookup_value}-appdev-admin-policy"
  default_appdev_admin_policy_name = "appdev-admin-policy"
  appdev_admin_policy_name = var.appdev_admin_policy_name != null ? var.appdev_admin_policy_name : "${var.cislz_tag_lookup_value}-${local.default_appdev_admin_policy_name}"

  #-- Application admin grants on Root compartment
  #appdev_admin_grants_on_root_cmp = contains(keys(local.group_tag_map),local.appdev_admin_tag) ? [
  #  "allow group ${local.group_tag_map[local.appdev_admin_tag]} to use cloud-shell in tenancy",
  #  "allow group ${local.group_tag_map[local.appdev_admin_tag]} to read usage-budgets in tenancy",
  #  "allow group ${local.group_tag_map[local.appdev_admin_tag]} to read usage-reports in tenancy"
  #] : []
  #-- Application admin grants on enclosing compartment
  appdev_admin_grants_on_enclosing_cmp = contains(keys(local.group_tag_map),local.application_admin_tag) ? [
    "allow group ${local.group_tag_map[local.application_admin_tag]} to read app-catalog-listing in ${local.policy_scope}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to read instance-images in ${local.policy_scope}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to read repos in ${local.policy_scope}"
  ] : [] 
  #-- Application admin grants on AppDev compartment
  appdev_admin_grants_on_appdev_cmp = contains(keys(local.group_tag_map),local.application_admin_tag) && contains(keys(local.cmp_tag_map),local.application_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.application_admin_tag]} to read all-resources in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage functions-family in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage api-gateway-family in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage ons-family in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage streams in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage cluster-family in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage alarms in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage metrics in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage logging-family in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage instance-family in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
     # CIS 1.2 - 1.14 Level 2 
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage volume-family in compartment ${local.cmp_tag_map[local.application_cmp_tag]} where all{request.permission != 'VOLUME_BACKUP_DELETE', request.permission != 'VOLUME_DELETE', request.permission != 'BOOT_VOLUME_BACKUP_DELETE'}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage object-family in compartment ${local.cmp_tag_map[local.application_cmp_tag]} where all{request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage file-family in compartment ${local.cmp_tag_map[local.application_cmp_tag]} where all{request.permission != 'FILE_SYSTEM_DELETE', request.permission != 'MOUNT_TARGET_DELETE', request.permission != 'EXPORT_SET_DELETE', request.permission != 'FILE_SYSTEM_DELETE_SNAPSHOT', request.permission != 'FILE_SYSTEM_NFSv3_UNEXPORT'}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage repos in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage orm-stacks in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage orm-jobs in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage orm-config-source-providers in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to read audit-events in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to read work-requests in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage bastion-session in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage cloudevents-rules in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to read instance-agent-plugins in compartment ${local.cmp_tag_map[local.application_cmp_tag]}"
  ] : []

  #-- Application admin grants on Network compartment
  appdev_admin_grants_on_network_cmp = contains(keys(local.group_tag_map),local.application_admin_tag) && contains(keys(local.cmp_tag_map),local.network_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.application_admin_tag]} to read virtual-network-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to use subnets in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to use network-security-groups in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to use vnics in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to use load-balancers in compartment ${local.cmp_tag_map[local.network_cmp_tag]}"
  ] : []    

  #-- Application admin grants on Security compartment
  appdev_admin_grants_on_security_cmp = contains(keys(local.group_tag_map),local.application_admin_tag) && contains(keys(local.cmp_tag_map),local.security_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.application_admin_tag]} to read vaults in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to inspect keys in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage instance-images in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to read vss-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to use bastion in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to manage bastion-session in compartment ${local.cmp_tag_map[local.security_cmp_tag]}"
  ] : []

  #-- Application admin grants on Database compartment
  appdev_admin_grants_on_database_cmp = contains(keys(local.group_tag_map),local.application_admin_tag) && contains(keys(local.cmp_tag_map),local.database_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.application_admin_tag]} to read autonomous-database-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.application_admin_tag]} to read database-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]}"
  ] : []  

  appdev_admin_grants = concat(local.policy_scope != "tenancy" ? local.appdev_admin_grants_on_enclosing_cmp : [],
                               local.appdev_admin_grants_on_appdev_cmp, local.appdev_admin_grants_on_database_cmp,
                               local.appdev_admin_grants_on_network_cmp, local.appdev_admin_grants_on_security_cmp) 

  #-- Policy
  appdev_admin_policy = length(local.appdev_admin_grants) > 0 ? {
    (local.appdev_admin_policy_key) = {
      name           = local.appdev_admin_policy_name
      compartment_id = data.oci_identity_compartments.application[0].compartments[0].compartment_id
      description    = "CIS Landing Zone policy for Application administrators."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.appdev_admin_grants
    }
  } : {}                             

  #--------------------------------------------------------------------------------------------
  #-- Exadata Cloud Service infrastructure admin policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  exainfra_admin_policy_key = "${var.cislz_tag_lookup_value}-exainfra-admin-policy"
  default_exainfra_admin_policy_name = "exainfra-admin-policy"
  exainfra_admin_policy_name = var.exainfra_admin_policy_name != null ? var.exainfra_admin_policy_name : "${var.cislz_tag_lookup_value}-${local.default_exainfra_admin_policy_name}"

  #-- Exainfra admin grants on Root compartment
  #exainfra_admin_grants_on_root_cmp = contains(keys(local.group_tag_map),local.exainfra_admin_tag) ? [
  #  "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to use cloud-shell in tenancy",
  #  "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to read usage-budgets in tenancy",
  #  "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to read usage-reports in tenancy"
  #] : []
  #-- Exainfra admin grants on Exinfra compartment
  exainfra_admin_grants_on_exainfra_cmp = contains(keys(local.group_tag_map),local.exainfra_admin_tag) && contains(keys(local.cmp_tag_map),local.exainfra_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to manage cloud-exadata-infrastructures in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to manage cloud-vmclusters in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to read work-requests in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to manage bastion-session in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to manage instance-family in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to read instance-agent-plugins in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to manage ons-family in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to manage alarms in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to manage metrics in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}",
    "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to manage data-safe-family in compartment ${local.cmp_tag_map[local.exainfra_cmp_tag]}"
  ] : []

  #-- Exainfra admin grants on Security compartment
  exainfra_admin_grants_on_security_cmp = contains(keys(local.group_tag_map),local.exainfra_admin_tag) && contains(keys(local.cmp_tag_map),local.security_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to use bastion in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to manage bastion-session in compartment ${local.cmp_tag_map[local.security_cmp_tag]}"
  ] : [] 

  #-- Exainfra admin grants on Network compartment
  exainfra_admin_grants_on_network_cmp = contains(keys(local.group_tag_map),local.exainfra_admin_tag) && contains(keys(local.cmp_tag_map),local.network_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.exainfra_admin_tag]} to read virtual-network-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]}"
  ] : []

  exainfra_admin_grants = concat(local.exainfra_admin_grants_on_exainfra_cmp, local.exainfra_admin_grants_on_security_cmp, local.exainfra_admin_grants_on_network_cmp)

  #-- Policy
  exainfra_admin_policy = length(local.exainfra_admin_grants) > 0 ? {
    (local.exainfra_admin_policy_key) = {
      name           = local.exainfra_admin_policy_name
      compartment_id = data.oci_identity_compartments.exainfra[0].compartments[0].compartment_id
      description    = "CIS Landing Zone policy for Exadata Cloud Service infrastructure administrators."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.exainfra_admin_grants
    }
  } : {}

  #--------------------------------------------------------------------------------------------
  #-- Storage admin policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  storage_admin_policy_key = "${var.cislz_tag_lookup_value}-storage-admin-policy"
  default_storage_admin_policy_name = "storage-admin-policy"
  storage_admin_policy_name = var.storage_admin_policy_name != null ? var.storage_admin_policy_name : "${var.cislz_tag_lookup_value}-${local.default_storage_admin_policy_name}"

  #-- Storage admin grants on Root compartment
  #storage_admin_grants_on_root_cmp = contains(keys(local.group_tag_map),local.storage_admin_tag) ? [
  #  "allow group ${local.group_tag_map[local.storage_admin_tag]} to use cloud-shell in tenancy",
  #  "allow group ${local.group_tag_map[local.storage_admin_tag]} to read usage-budgets in tenancy",
  #  "allow group ${local.group_tag_map[local.storage_admin_tag]} to read usage-reports in tenancy"
  #] : []
  #-- Grants in application compartment
  storage_admin_grants_on_appdev_cmp = contains(keys(local.group_tag_map),local.storage_admin_tag) && contains(keys(local.cmp_tag_map),local.application_cmp_tag) ? [
    # Object Storage
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to read bucket in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to inspect object in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to manage object-family in compartment ${local.cmp_tag_map[local.application_cmp_tag]} where any {request.permission = 'OBJECT_DELETE', request.permission = 'BUCKET_DELETE'}",
    # Volume Storage
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to read volume-family in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to manage volume-family in compartment ${local.cmp_tag_map[local.application_cmp_tag]} where any {request.permission = 'VOLUME_DELETE', request.permission = 'VOLUME_BACKUP_DELETE', request.permission = 'BOOT_VOLUME_BACKUP_DELETE'}",
    # File Storage
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to read file-family in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to manage file-family in compartment ${local.cmp_tag_map[local.application_cmp_tag]} where any {request.permission = 'FILE_SYSTEM_DELETE', request.permission = 'MOUNT_TARGET_DELETE', request.permission = 'EXPORT_SET_UPDATE', request.permission = 'FILE_SYSTEM_NFSv3_UNEXPORT', request.permission = 'EXPORT_SET_DELETE', request.permission = 'FILE_SYSTEM_DELETE_SNAPSHOT'}"
  ] : []
  #-- Grants in database compartment
  storage_admin_grants_on_database_cmp = contains(keys(local.group_tag_map),local.storage_admin_tag) && contains(keys(local.cmp_tag_map),local.database_cmp_tag) ? [  
    # Object Storage
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to read bucket in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to inspect object in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to manage object-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]} where any {request.permission = 'OBJECT_DELETE', request.permission = 'BUCKET_DELETE'}",
    # Volume Storage
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to read volume-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to manage volume-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]} where any {request.permission = 'VOLUME_DELETE', request.permission = 'VOLUME_BACKUP_DELETE', request.permission = 'BOOT_VOLUME_BACKUP_DELETE'}",
    # File Storage
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to read file-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to manage file-family in compartment ${local.cmp_tag_map[local.database_cmp_tag]} where any {request.permission = 'FILE_SYSTEM_DELETE', request.permission = 'MOUNT_TARGET_DELETE', request.permission = 'EXPORT_SET_UPDATE', request.permission = 'FILE_SYSTEM_NFSv3_UNEXPORT', request.permission = 'EXPORT_SET_DELETE', request.permission = 'FILE_SYSTEM_DELETE_SNAPSHOT'}"
  ] : []
  #-- Grants in security compartment
  storage_admin_grants_on_security_cmp = contains(keys(local.group_tag_map),local.storage_admin_tag) && contains(keys(local.cmp_tag_map),local.security_cmp_tag) ? [
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to read bucket in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to inspect object in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to manage object-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]} where any {request.permission = 'OBJECT_DELETE', request.permission = 'BUCKET_DELETE'}",
    # Volume Storage
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to read volume-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to manage volume-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]} where any {request.permission = 'VOLUME_DELETE', request.permission = 'VOLUME_BACKUP_DELETE', request.permission = 'BOOT_VOLUME_BACKUP_DELETE'}",
    # File Storage
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to read file-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to manage file-family in compartment ${local.cmp_tag_map[local.security_cmp_tag]} where any {request.permission = 'FILE_SYSTEM_DELETE', request.permission = 'MOUNT_TARGET_DELETE', request.permission = 'EXPORT_SET_UPDATE', request.permission = 'FILE_SYSTEM_NFSv3_UNEXPORT', request.permission = 'EXPORT_SET_DELETE', request.permission = 'FILE_SYSTEM_DELETE_SNAPSHOT'}"
  ] : []
  #-- Grants in network compartment
  storage_admin_grants_on_network_cmp = contains(keys(local.group_tag_map),local.storage_admin_tag) && contains(keys(local.cmp_tag_map),local.network_cmp_tag) ? [
    # Object Storage
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to read bucket in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to inspect object in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to manage object-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]} where any {request.permission = 'OBJECT_DELETE', request.permission = 'BUCKET_DELETE'}",
    # Volume Storage
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to read volume-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to manage volume-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]} where any {request.permission = 'VOLUME_DELETE', request.permission = 'VOLUME_BACKUP_DELETE', request.permission = 'BOOT_VOLUME_BACKUP_DELETE'}",
    # File Storage
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to read file-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]}",
    "allow group ${local.group_tag_map[local.storage_admin_tag]} to manage file-family in compartment ${local.cmp_tag_map[local.network_cmp_tag]} where any {request.permission = 'FILE_SYSTEM_DELETE', request.permission = 'MOUNT_TARGET_DELETE', request.permission = 'VNIC_DELETE', request.permission = 'SUBNET_DETACH', request.permission = 'VNIC_DETACH', request.permission = 'PRIVATE_IP_DELETE', request.permission = 'PRIVATE_IP_UNASSIGN', request.permission = 'VNIC_UNASSIGN', request.permission = 'EXPORT_SET_UPDATE', request.permission = 'FILE_SYSTEM_NFSv3_UNEXPORT', request.permission = 'EXPORT_SET_DELETE', request.permission = 'FILE_SYSTEM_DELETE_SNAPSHOT'}",
  ] : [] 

  storage_admin_grants = concat(local.storage_admin_grants_on_appdev_cmp, local.storage_admin_grants_on_database_cmp,
                                local.storage_admin_grants_on_security_cmp, local.storage_admin_grants_on_network_cmp)

  #-- Policy
  storage_admin_policy = length(local.storage_admin_grants) > 0 ? {
    (local.storage_admin_policy_key) = {
      name           = local.storage_admin_policy_name
      compartment_id = data.oci_identity_compartments.network[0].compartments[0].compartment_id ############## REVIEW THIS
      description    = "CIS Landing Zone policy for Storage administrators."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.storage_admin_grants
    }
  } : {}                              

  #--------------------------------------------------------------------------------------------
  #-- Dynamic groups policies
  #--------------------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------------------
  #-- Compute Agent policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  compute_agent_policy_key = "${var.cislz_tag_lookup_value}-compute-agent-policy"
  default_compute_agent_policy_name = "compute-agent-policy"
  compute_agent_policy_name = var.compute_agent_policy_name != null ? var.compute_agent_policy_name : "${var.cislz_tag_lookup_value}-${local.default_compute_agent_policy_name}"

  #-- Compute Agent grants
  compute_agent_grants = contains(keys(local.dyn_group_tag_map),local.dyn_compute_agent_tag) && contains(keys(local.cmp_tag_map),local.application_cmp_tag) ? [
    "allow dynamic-group ${local.dyn_group_tag_map[local.dyn_compute_agent_tag]} to manage management-agents in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow dynamic-group ${local.dyn_group_tag_map[local.dyn_compute_agent_tag]} to use metrics in compartment ${local.cmp_tag_map[local.application_cmp_tag]}",
    "allow dynamic-group ${local.dyn_group_tag_map[local.dyn_compute_agent_tag]} to use tag-namespaces in compartment ${local.cmp_tag_map[local.application_cmp_tag]}"
  ] : []

  #-- Policy
  compute_agent_policy = length(local.compute_agent_grants) > 0 ? {
    (local.compute_agent_policy_key) = {
      name           = local.compute_agent_policy_name
      compartment_id = data.oci_identity_compartments.application[0].compartments[0].compartment_id
      description    = "CIS Landing Zone policy for Compute Agent dynamic group."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.compute_agent_grants
    }
  } : {}

  #--------------------------------------------------------------------------------------------
  #-- Database KMS policy
  #--------------------------------------------------------------------------------------------
  #-- Naming
  database_kms_policy_key = "${var.cislz_tag_lookup_value}-database-kms-policy"
  default_database_kms_policy_name = "database-kms-policy"
  database_kms_policy_name = var.database_kms_policy_name != null ? var.database_kms_policy_name : "${var.cislz_tag_lookup_value}-${local.default_database_kms_policy_name}"
  
  #-- The grants
  database_kms_grants = contains(keys(local.dyn_group_tag_map),local.dyn_database_kms_tag) && contains(keys(local.cmp_tag_map),local.security_cmp_tag) ? [
    "allow dynamic-group ${local.dyn_group_tag_map[local.dyn_database_kms_tag]} to read vaults in compartment ${local.cmp_tag_map[local.security_cmp_tag]}",
    "allow dynamic-group ${local.dyn_group_tag_map[local.dyn_database_kms_tag]} to use keys in compartment ${local.cmp_tag_map[local.security_cmp_tag]}"
  ] : []

  #-- Policy
  database_kms_policy = length(local.database_kms_grants) > 0 ? {
    (local.database_kms_policy_key) = {
      name           = local.database_kms_policy_name
      compartment_id = data.oci_identity_compartments.security[0].compartments[0].compartment_id
      description    = "CIS Landing Zone policy for Database KMS dynamic group."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = local.database_kms_grants
    }
  } : {}

  #--------------------------------------------------------------------------------------------
  #-- Final policies
  #--------------------------------------------------------------------------------------------  
  policies = merge(local.iam_admin_policy, local.security_admin_policy, local.network_admin_policy,
                   local.appdev_admin_policy, local.database_admin_policy, local.exainfra_admin_policy,
                   local.storage_admin_policy, local.compute_agent_policy, local.database_kms_policy)

}

resource "oci_identity_policy" "these" {
  for_each = local.policies
    name           = each.value.name
    description    = each.value.description
    compartment_id = each.value.compartment_id
    statements     = each.value.statements
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags
}
 */