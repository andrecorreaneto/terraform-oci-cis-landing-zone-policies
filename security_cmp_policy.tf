# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  #--------------------------------------------------------------------------------------------
  #-- Security compartments policies
  #--------------------------------------------------------------------------------------------
  
  #-- Security read-only grants on Security compartment
  security_read_grants_on_security_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"security") && v["read-group"] != null) ? [
      "allow group ${v["read-group"]} to read all-resources in compartment ${k}"
    ] : []
  }
  
  #-- Security admin grants on Security compartment
  security_admin_grants_on_security_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"security") && v["sec-group"] != null) ? [
      "allow group ${v["sec-group"]} to read all-resources in compartment ${k}",
      "allow group ${v["sec-group"]} to manage instance-family in compartment ${k}",
      # CIS 1.2 - 1.14 Level 2
      "allow group ${v["sec-group"]} to manage volume-family in compartment ${k} where all{request.permission != 'VOLUME_BACKUP_DELETE', request.permission != 'VOLUME_DELETE', request.permission != 'BOOT_VOLUME_BACKUP_DELETE'}",
      "allow group ${v["sec-group"]} to manage object-family in compartment ${k} where all{request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
      "allow group ${v["sec-group"]} to manage file-family in compartment ${k} where all{request.permission != 'FILE_SYSTEM_DELETE', request.permission != 'MOUNT_TARGET_DELETE', request.permission != 'EXPORT_SET_DELETE', request.permission != 'FILE_SYSTEM_DELETE_SNAPSHOT', request.permission != 'FILE_SYSTEM_NFSv3_UNEXPORT'}",
      "allow group ${v["sec-group"]} to manage vaults in compartment ${k}",
      "allow group ${v["sec-group"]} to manage keys in compartment ${k}",
      "allow group ${v["sec-group"]} to manage secret-family in compartment ${k}",
      "allow group ${v["sec-group"]} to manage logging-family in compartment ${k}",
      "allow group ${v["sec-group"]} to manage serviceconnectors in compartment ${k}",
      "allow group ${v["sec-group"]} to manage streams in compartment ${k}",
      "allow group ${v["sec-group"]} to manage ons-family in compartment ${k}",
      "allow group ${v["sec-group"]} to manage functions-family in compartment ${k}",
      "allow group ${v["sec-group"]} to manage waas-family in compartment ${k}",
      "allow group ${v["sec-group"]} to manage security-zone in compartment ${k}",
      "allow group ${v["sec-group"]} to manage orm-stacks in compartment ${k}",
      "allow group ${v["sec-group"]} to manage orm-jobs in compartment ${k}",
      "allow group ${v["sec-group"]} to manage orm-config-source-providers in compartment ${k}",
      "allow group ${v["sec-group"]} to manage vss-family in compartment ${k}",
      #"allow group ${v["sec-group"]} to read work-requests in compartment ${k}",
      "allow group ${v["sec-group"]} to manage bastion-family in compartment ${k}",
      #"allow group ${v["sec-group"]} to read instance-agent-plugins in compartment ${k}",
      "allow group ${v["sec-group"]} to manage cloudevents-rules in compartment ${k}",
      "allow group ${v["sec-group"]} to manage alarms in compartment ${k}",
      "allow group ${v["sec-group"]} to manage metrics in compartment ${k}"
    ] : []
  }

  #-- Network admin grants on Security compartment
  network_admin_grants_on_security_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"security") && v["net-group"] != null) ? [
      "allow group ${v["net-group"]} to read vss-family in compartment ${k}",
      "allow group ${v["net-group"]} to use bastion in compartment ${k}",
      "allow group ${v["net-group"]} to manage bastion-session in compartment ${k}"
    ] : []
  }
  
  #-- Database admin grants on Security compartment
  database_admin_grants_on_security_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"security") && v["db-group"] != null) ? [
      "allow group ${v["db-group"]} to read vss-family in compartment ${k}",
      "allow group ${v["db-group"]} to read vaults in compartment ${k}",
      "allow group ${v["db-group"]} to inspect keys in compartment ${k}",
      "allow group ${v["db-group"]} to use bastion in compartment ${k}",
      "allow group ${v["db-group"]} to manage bastion-session in compartment ${k}"
    ] : []
  }  

  #-- Application admin grants on Security compartment
  appdev_admin_grants_on_security_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"security") && v["app-group"] != null) ? [
      "allow group ${v["app-group"]} to read vaults in compartment ${k}",
      "allow group ${v["app-group"]} to inspect keys in compartment ${k}",
      "allow group ${v["app-group"]} to manage instance-images in compartment ${k}",
      "allow group ${v["app-group"]} to read vss-family in compartment ${k}",
      "allow group ${v["app-group"]} to use bastion in compartment ${k}",
      "allow group ${v["app-group"]} to manage bastion-session in compartment ${k}"
    ] : []
  }
  
  #-- Exainfra admin grants on Security compartment
  exainfra_admin_grants_on_security_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"security") && v["exa-group"] != null) ? [
      "allow group ${v["exa-group"]} to use bastion in compartment ${k}",
      "allow group ${v["exa-group"]} to manage bastion-session in compartment ${k}"
    ] : []
  } 

  #-- Storage admin grants on Security compartment
  storage_admin_grants_on_security_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"security") && v["stg-group"] != null) ? [
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

  #-- Database grants on Security compartment
  database_kms_grants_on_security_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"security") && v["db-dyn-group"] != null) ? [
      "allow dynamic-group ${v["db-dyn-group"]} to read vaults in compartment ${k}",
      "allow dynamic-group ${v["db-dyn-group"]} to use keys in compartment ${k}"
    ] : []
  }  
 
  #-- Policies
  security_cmps_policies = {for k, v in local.cmp_name_to_cislz_tag_map : 
    (upper("${k}-security-policy")) => {
      name           : "${local.policy_name_prefix}${k}-security-policy"
      compartment_id : v.id
      description    : "CIS Landing Zone policy for Security compartment."
      defined_tags   : var.defined_tags
      freeform_tags  : var.freeform_tags
      statements     : concat(local.security_read_grants_on_security_cmp_map[k],local.security_admin_grants_on_security_cmp_map[k],
                              local.network_admin_grants_on_security_cmp_map[k],local.database_admin_grants_on_security_cmp_map[k],
                              local.appdev_admin_grants_on_security_cmp_map[k],local.exainfra_admin_grants_on_security_cmp_map[k],
                              local.storage_admin_grants_on_security_cmp_map[k],local.database_kms_grants_on_security_cmp_map[k])
    }
  }
}
