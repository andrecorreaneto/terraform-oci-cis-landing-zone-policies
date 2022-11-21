# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  #--------------------------------------------------------------------------------------------
  #-- Database compartments policies
  #--------------------------------------------------------------------------------------------
  
  #-- Database read grants on Database compartment
  database_read_grants_on_database_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"database") && v["read-group"] != null) ? [
      "allow group ${v["read-group"]} to read all-resources in compartment ${k}"
    ] : []
  }

  #-- Database admin grants on Database compartment
  database_admin_grants_on_database_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"database") && v["db-group"] != null) ? [
      "allow group ${v["db-group"]} to read all-resources in compartment ${k}",
      "allow group ${v["db-group"]} to manage database-family in compartment ${k}",
      "allow group ${v["db-group"]} to manage autonomous-database-family in compartment ${k}",
      "allow group ${v["db-group"]} to manage alarms in compartment ${k}",
      "allow group ${v["db-group"]} to manage metrics in compartment ${k}",
      "allow group ${v["db-group"]} to manage cloudevents-rules in compartment ${k}",
      # CIS 1.2 - 1.14 Level 2 
      "allow group ${v["db-group"]} to manage object-family in compartment ${k} where all{request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
      "allow group ${v["db-group"]} to manage instance-family in compartment ${k}",
      "allow group ${v["db-group"]} to manage volume-family in compartment ${k} where all{request.permission != 'VOLUME_BACKUP_DELETE', request.permission != 'VOLUME_DELETE', request.permission != 'BOOT_VOLUME_BACKUP_DELETE'}",
      "allow group ${v["db-group"]} to manage file-family in compartment ${k} where all{request.permission != 'FILE_SYSTEM_DELETE', request.permission != 'MOUNT_TARGET_DELETE', request.permission != 'EXPORT_SET_DELETE', request.permission != 'FILE_SYSTEM_DELETE_SNAPSHOT', request.permission != 'FILE_SYSTEM_NFSv3_UNEXPORT'}",
      "allow group ${v["db-group"]} to manage orm-stacks in compartment ${k}",
      "allow group ${v["db-group"]} to manage orm-jobs in compartment ${k}",
      "allow group ${v["db-group"]} to manage orm-config-source-providers in compartment ${k}",
      "allow group ${v["db-group"]} to manage ons-family in compartment ${k}", 
      "allow group ${v["db-group"]} to manage logging-family in compartment ${k}", 
      #"allow group ${v["db-group"]} to read audit-events in compartment ${k}",
      #"allow group ${v["db-group"]} to read work-requests in compartment ${k}",
      "allow group ${v["db-group"]} to manage bastion-session in compartment ${k}",
      #"allow group ${v["db-group"]} to read instance-agent-plugins in compartment ${k}",
      "allow group ${v["db-group"]} to manage data-safe-family in compartment ${k}"
    ] : []
  }  

  #-- Application admin grants on Database compartment
  appdev_admin_grants_on_database_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"database") && v["app-group"] != null) ? [
      "allow group ${v["app-group"]} to read autonomous-database-family in compartment ${k}",
      "allow group ${v["app-group"]} to read database-family in compartment ${k}"
    ] : [] 
  }  

  #-- Storage admin grants in database compartment
  storage_admin_grants_on_database_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"database") && v["stg-group"] != null) ? [
      # Object Storage
      "allow group ${v["stg-group"]} to read bucket in compartment ${k}",
      "allow group ${v["stg-group"]} to inspect object in compartment ${k}",
      "allow group ${v["stg-group"]} to manage object-family in compartment ${k} where any {request.permission = 'OBJECT_DELETE', request.permission = 'BUCKET_DELETE'}",
      # Volume Storage
      "allow group ${v["stg-group"]} to read volume-family in compartment ${k}",
      "allow group ${v["stg-group"]} to manage volume-family in compartment ${k} where any {request.permission = 'VOLUME_DELETE', request.permission = 'VOLUME_BACKUP_DELETE', request.permission = 'BOOT_VOLUME_BACKUP_DELETE'}",
      # File Storage
      "allow group ${v["stg-group"]} to read file-family in compartment ${k}",
      "allow group ${v["stg-group"]} to manage file-family in compartment ${k} where any {request.permission = 'FILE_SYSTEM_DELETE', request.permission = 'MOUNT_TARGET_DELETE', request.permission = 'EXPORT_SET_UPDATE', request.permission = 'FILE_SYSTEM_NFSv3_UNEXPORT', request.permission = 'EXPORT_SET_DELETE', request.permission = 'FILE_SYSTEM_DELETE_SNAPSHOT'}"
    ] : []
  }  

  #-- Policies
  database_cmps_policies = {for k, v in local.cmp_name_to_cislz_tag_map : 
    (upper("${k}-database-policy")) => {
      name           = "${local.policy_name_prefix}${k}-database-policy"
      compartment_id = v.id
      description    = "CIS Landing Zone policy for Database compartment."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = concat(local.database_admin_grants_on_database_cmp_map[k],local.database_read_grants_on_database_cmp_map[k],
                              local.appdev_admin_grants_on_database_cmp_map[k],local.storage_admin_grants_on_database_cmp_map[k])
    }
  }
}