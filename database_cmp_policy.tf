# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  #--------------------------------------------------------------------------------------------
  #-- Database compartments policies
  #--------------------------------------------------------------------------------------------
  
  #-- Database read grants on Database compartment
  database_read_grants_on_database_cmp_map = {
    for cmp, values in local.cmp_name_to_cislz_tag_map : cmp => (contains(split(",",values["cmp-type"]),"database") && values["read-group"] != null) ? [
      "allow group ${values["read-group"]} to read all-resources in compartment ${cmp}"
    ] : []
  }

  #-- Database admin grants on Database compartment
  database_admin_grants_on_database_cmp_map = {
    for cmp, values in local.cmp_name_to_cislz_tag_map : cmp => (contains(split(",",values["cmp-type"]),"database") && values["db-group"] != null) ? [
      "allow group ${values["db-group"]} to read all-resources in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage database-family in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage autonomous-database-family in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage alarms in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage metrics in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage cloudevents-rules in compartment ${cmp}",
      # CIS 1.2 - 1.14 Level 2 
      "allow group ${values["db-group"]} to manage object-family in compartment ${cmp} where all{request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
      "allow group ${values["db-group"]} to manage instance-family in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage volume-family in compartment ${cmp} where all{request.permission != 'VOLUME_BACKUP_DELETE', request.permission != 'VOLUME_DELETE', request.permission != 'BOOT_VOLUME_BACKUP_DELETE'}",
      "allow group ${values["db-group"]} to manage file-family in compartment ${cmp} where all{request.permission != 'FILE_SYSTEM_DELETE', request.permission != 'MOUNT_TARGET_DELETE', request.permission != 'EXPORT_SET_DELETE', request.permission != 'FILE_SYSTEM_DELETE_SNAPSHOT', request.permission != 'FILE_SYSTEM_NFSv3_UNEXPORT'}",
      "allow group ${values["db-group"]} to manage orm-stacks in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage orm-jobs in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage orm-config-source-providers in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage ons-family in compartment ${cmp}", 
      "allow group ${values["db-group"]} to manage logging-family in compartment ${cmp}", 
      #"allow group ${values["db-group"]} to read audit-events in compartment ${cmp}",
      #"allow group ${values["db-group"]} to read work-requests in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage bastion-session in compartment ${cmp}",
      #"allow group ${values["db-group"]} to read instance-agent-plugins in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage data-safe-family in compartment ${cmp}"
    ] : []
  }  

  #-- Application admin grants on Database compartment
  appdev_admin_grants_on_database_cmp_map = {
    for cmp, values in local.cmp_name_to_cislz_tag_map : cmp => (contains(split(",",values["cmp-type"]),"database") && values["app-group"] != null) ? [
      "allow group ${values["app-group"]} to read autonomous-database-family in compartment ${cmp}",
      "allow group ${values["app-group"]} to read database-family in compartment ${cmp}"
    ] : [] 
  }  

  #-- Storage admin grants in database compartment
  storage_admin_grants_on_database_cmp_map = {
    for cmp, values in local.cmp_name_to_cislz_tag_map : cmp => (contains(split(",",values["cmp-type"]),"database") && values["stg-group"] != null) ? [
      # Object Storage
      "allow group ${values["stg-group"]} to read bucket in compartment ${cmp}",
      "allow group ${values["stg-group"]} to inspect object in compartment ${cmp}",
      "allow group ${values["stg-group"]} to manage object-family in compartment ${cmp} where any {request.permission = 'OBJECT_DELETE', request.permission = 'BUCKET_DELETE'}",
      # Volume Storage
      "allow group ${values["stg-group"]} to read volume-family in compartment ${cmp}",
      "allow group ${values["stg-group"]} to manage volume-family in compartment ${cmp} where any {request.permission = 'VOLUME_DELETE', request.permission = 'VOLUME_BACKUP_DELETE', request.permission = 'BOOT_VOLUME_BACKUP_DELETE'}",
      # File Storage
      "allow group ${values["stg-group"]} to read file-family in compartment ${cmp}",
      "allow group ${values["stg-group"]} to manage file-family in compartment ${cmp} where any {request.permission = 'FILE_SYSTEM_DELETE', request.permission = 'MOUNT_TARGET_DELETE', request.permission = 'EXPORT_SET_UPDATE', request.permission = 'FILE_SYSTEM_NFSv3_UNEXPORT', request.permission = 'EXPORT_SET_DELETE', request.permission = 'FILE_SYSTEM_DELETE_SNAPSHOT'}"
    ] : []
  }  

  #-- Policies
  database_cmps_policies = {for cmp, values in local.cmp_name_to_cislz_tag_map : 
    ("${cmp}-database-policy") => {
      name           = "${local.policy_name_prefix}${cmp}-database-policy"
      compartment_id = values.id
      description    = "CIS Landing Zone policy for Database compartment."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = concat(local.database_admin_grants_on_database_cmp_map[cmp],local.database_read_grants_on_database_cmp_map[cmp],
                              local.appdev_admin_grants_on_database_cmp_map[cmp],local.storage_admin_grants_on_database_cmp_map[cmp])
    }
  }
}