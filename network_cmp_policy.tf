# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  #--------------------------------------------------------------------------------------------
  #-- Network compartments policies
  #--------------------------------------------------------------------------------------------
  
  #-- Network read-only grants on Network compartment
  network_read_grants_on_network_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"network") && v["read-group"] != null) ? [
      "allow group ${v["read-group"]} to read all-resources in compartment ${k}"
    ] : []
  }

  #-- Network admin grants on Network compartment
  network_admin_grants_on_network_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"network") && v["net-group"] != null) ? [
      "allow group ${v["net-group"]} to read all-resources in compartment ${k}",
      "allow group ${v["net-group"]} to manage virtual-network-family in compartment ${k}",
      "allow group ${v["net-group"]} to manage dns in compartment ${k}",
      "allow group ${v["net-group"]} to manage load-balancers in compartment ${k}",
      "allow group ${v["net-group"]} to manage alarms in compartment ${k}",
      "allow group ${v["net-group"]} to manage metrics in compartment ${k}",
      "allow group ${v["net-group"]} to manage ons-family in compartment ${k}", 
      "allow group ${v["net-group"]} to manage orm-stacks in compartment ${k}",
      "allow group ${v["net-group"]} to manage orm-jobs in compartment ${k}",
      "allow group ${v["net-group"]} to manage orm-config-source-providers in compartment ${k}",
      #"allow group ${v["net-group"]} to read audit-events in compartment ${k}",
      #"allow group ${v["net-group"]} to read work-requests in compartment ${k}",
      # CIS 1.2 - 1.14 Level 2
      "allow group ${v["net-group"]} to manage instance-family in compartment ${k}",
      "allow group ${v["net-group"]} to manage volume-family in compartment ${k} where all{request.permission != 'VOLUME_BACKUP_DELETE', request.permission != 'VOLUME_DELETE', request.permission != 'BOOT_VOLUME_BACKUP_DELETE'}",
      "allow group ${v["net-group"]} to manage object-family in compartment ${k} where all{request.permission != 'OBJECT_DELETE', request.permission != 'BUCKET_DELETE'}",
      "allow group ${v["net-group"]} to manage file-family in compartment ${k} where all{request.permission != 'FILE_SYSTEM_DELETE', request.permission != 'MOUNT_TARGET_DELETE', request.permission != 'EXPORT_SET_DELETE', request.permission != 'FILE_SYSTEM_DELETE_SNAPSHOT', request.permission != 'FILE_SYSTEM_NFSv3_UNEXPORT'}",
      "allow group ${v["net-group"]} to manage bastion-session in compartment ${k}",
      "allow group ${v["net-group"]} to manage cloudevents-rules in compartment ${k}",
      "allow group ${v["net-group"]} to manage alarms in compartment ${k}",
      "allow group ${v["net-group"]} to manage metrics in compartment ${k}",
      #"allow group ${v["net-group"]} to read instance-agent-plugins in compartment ${k}"
    ] : []
  }  

  #-- Security admin grants on Network compartment
  security_admin_grants_on_network_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"network") && v["sec-group"] != null) ? [
      "allow group ${v["sec-group"]} to read virtual-network-family in compartment ${k}",
      "allow group ${v["sec-group"]} to use subnets in compartment ${k}",
      "allow group ${v["sec-group"]} to use network-security-groups in compartment ${k}",
      "allow group ${v["sec-group"]} to use vnics in compartment ${k}"
    ] : []
  }

  #-- Database admin grants on Network compartment
  database_admin_grants_on_network_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"network") && v["db-group"] != null) ? [
      "allow group ${v["db-group"]} to read virtual-network-family in compartment ${k}",
      "allow group ${v["db-group"]} to use vnics in compartment ${k}",
      "allow group ${v["db-group"]} to use subnets in compartment ${k}",
      "allow group ${v["db-group"]} to use network-security-groups in compartment ${k}"
    ] : [] 
  }  

  #-- Application admin grants on Network compartment
  appdev_admin_grants_on_network_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"network") && v["app-group"] != null) ? [
      "allow group ${v["app-group"]} to read virtual-network-family in compartment ${k}",
      "allow group ${v["app-group"]} to use subnets in compartment ${k}",
      "allow group ${v["app-group"]} to use network-security-groups in compartment ${k}",
      "allow group ${v["app-group"]} to use vnics in compartment ${k}",
      "allow group ${v["app-group"]} to use load-balancers in compartment ${k}"
    ] : []
  }  

  #-- Exainfra admin grants on Network compartment
  exainfra_admin_grants_on_network_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"network") && v["exa-group"] != null) ? [
      "allow group ${v["exa-group"]} to read virtual-network-family in compartment ${k}"
    ] : []
  }  

  #-- Storag admin grants on Network compartment
  storage_admin_grants_on_network_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"network") && v["stg-group"] != null) ? [
      # Object Storage
      "allow group ${v["stg-group"]} to read bucket in compartment ${k}",
      "allow group ${v["stg-group"]} to inspect object in compartment ${k}",
      "allow group ${v["stg-group"]} to manage object-family in compartment ${k} where any {request.permission = 'OBJECT_DELETE', request.permission = 'BUCKET_DELETE'}",
      # Volume Storage
      "allow group ${v["stg-group"]} to read volume-family in compartment ${k}",
      "allow group ${v["stg-group"]} to manage volume-family in compartment ${k} where any {request.permission = 'VOLUME_DELETE', request.permission = 'VOLUME_BACKUP_DELETE', request.permission = 'BOOT_VOLUME_BACKUP_DELETE'}",
      # File Storage
      "allow group ${v["stg-group"]} to read file-family in compartment ${k}",
      "allow group ${v["stg-group"]} to manage file-family in compartment ${k} where any {request.permission = 'FILE_SYSTEM_DELETE', request.permission = 'MOUNT_TARGET_DELETE', request.permission = 'VNIC_DELETE', request.permission = 'SUBNET_DETACH', request.permission = 'VNIC_DETACH', request.permission = 'PRIVATE_IP_DELETE', request.permission = 'PRIVATE_IP_UNASSIGN', request.permission = 'VNIC_UNASSIGN', request.permission = 'EXPORT_SET_UPDATE', request.permission = 'FILE_SYSTEM_NFSv3_UNEXPORT', request.permission = 'EXPORT_SET_DELETE', request.permission = 'FILE_SYSTEM_DELETE_SNAPSHOT'}",
    ] : [] 
  }  

  #-- Policy
  network_cmps_policies = {for k, v in local.cmp_name_to_cislz_tag_map : 
    (upper("${k}-network-policy")) => {
      name           = "${local.policy_name_prefix}${k}-network-policy"
      compartment_id = v.id
      description    = "CIS Landing Zone policy for Network compartment."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = concat(local.network_admin_grants_on_network_cmp_map[k],local.network_read_grants_on_network_cmp_map[k],
                              local.security_admin_grants_on_network_cmp_map[k],local.appdev_admin_grants_on_network_cmp_map[k],
                              local.database_admin_grants_on_network_cmp_map[k],local.exainfra_admin_grants_on_network_cmp_map[k],
                              local.storage_admin_grants_on_network_cmp_map[k])
    }
  }                           
}