# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  #--------------------------------------------------------------------------------------------
  #-- Application compartments policies
  #--------------------------------------------------------------------------------------------
  
  #-- Application read grants on application compartment
  application_read_grants_on_application_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"application") && v["read-group"] != null) ? [
      "allow group ${v["read-group"]} to read all-resources in compartment ${k}"
    ] : []
  }

  #-- Application admin grants on application compartment
  application_admin_grants_on_application_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"application") && v["app-group"] != null) ? [
      "allow group ${v["app-group"]} to read all-resources in compartment ${k}",
      "allow group ${v["app-group"]} to manage functions-family in compartment ${k}",
      "allow group ${v["app-group"]} to manage api-gateway-family in compartment ${k}",
      "allow group ${v["app-group"]} to manage ons-family in compartment ${k}",
      "allow group ${v["app-group"]} to manage streams in compartment ${k}",
      "allow group ${v["app-group"]} to manage cluster-family in compartment ${k}",
      "allow group ${v["app-group"]} to manage alarms in compartment ${k}",
      "allow group ${v["app-group"]} to manage metrics in compartment ${k}",
      "allow group ${v["app-group"]} to manage logging-family in compartment ${k}",
      "allow group ${v["app-group"]} to manage instance-family in compartment ${k}",
      # CIS 1.2 - 1.14 Level 2 
      "allow group ${v["app-group"]} to manage volume-family in compartment ${k} where all{request.permission != 'VOLUME_BACKUP_DELETE', request.permission != 'VOLUME_DELETE', request.permission != 'BOOT_VOLUME_BACKUP_DELETE'}",
      "allow group ${v["app-group"]} to manage object-family in compartment ${k} where all{request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
      "allow group ${v["app-group"]} to manage file-family in compartment ${k} where all{request.permission != 'FILE_SYSTEM_DELETE', request.permission != 'MOUNT_TARGET_DELETE', request.permission != 'EXPORT_SET_DELETE', request.permission != 'FILE_SYSTEM_DELETE_SNAPSHOT', request.permission != 'FILE_SYSTEM_NFSv3_UNEXPORT'}",
      "allow group ${v["app-group"]} to manage repos in compartment ${k}",
      "allow group ${v["app-group"]} to manage orm-stacks in compartment ${k}",
      "allow group ${v["app-group"]} to manage orm-jobs in compartment ${k}",
      "allow group ${v["app-group"]} to manage orm-config-source-providers in compartment ${k}",
      #"allow group ${v["app-group"]} to read audit-events in compartment ${k}",
      #"allow group ${v["app-group"]} to read work-requests in compartment ${k}",
      "allow group ${v["app-group"]} to manage bastion-session in compartment ${k}",
      "allow group ${v["app-group"]} to manage cloudevents-rules in compartment ${k}",
      #"allow group ${v["app-group"]} to read instance-agent-plugins in compartment ${k}"
    ] : []
  }  

  #-- Storage admin grants on application compartment
  storage_admin_grants_on_application_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"application") && v["stg-group"] != null) ? [
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

  #-- Compute Agent grants on application compartment
  compute_agent_grants_on_application_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"application") && v["ca-dyn-group"] != null) ? [
      "allow dynamic-group ${v["ca-dyn-group"]} to manage management-agents in compartment ${k}",
      "allow dynamic-group ${v["ca-dyn-group"]} to use metrics in compartment ${k}",
      "allow dynamic-group ${v["ca-dyn-group"]} to use tag-namespaces in compartment ${k}"
    ] : []
  }  

  #-- Policies
  application_cmps_policies = {for k, v in local.cmp_name_to_cislz_tag_map : 
    (upper("${k}-application-policy")) => {
      name           = "${local.policy_name_prefix}${k}-application-policy"
      compartment_id = v.id
      description    = "CIS Landing Zone policy for Application compartment."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = concat(local.application_admin_grants_on_application_cmp_map[k],local.application_read_grants_on_application_cmp_map[k],
                              local.storage_admin_grants_on_application_cmp_map[k],local.compute_agent_grants_on_application_cmp_map[k])
    }
  }
}