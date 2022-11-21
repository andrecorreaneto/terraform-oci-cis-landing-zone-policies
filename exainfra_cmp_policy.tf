# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  #--------------------------------------------------------------------------------------------
  #-- Exadata Cloud Service infrastructure compartments policies
  #--------------------------------------------------------------------------------------------
  
  #-- Exainfra read grants on Exinfra compartment
  exainfra_read_grants_on_exainfra_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"exainfra") && v["read-group"] != null) ? [
      "allow group ${v["read-group"]} to read all-resources in compartment ${k}"
    ] : []
  }

  #-- Exainfra admin grants on Exinfra compartment
  exainfra_admin_grants_on_exainfra_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"exainfra") && v["exa-group"] != null) ? [
      "allow group ${v["exa-group"]} to read all-resources in compartment ${k}",
      "allow group ${v["exa-group"]} to manage cloud-exadata-infrastructures in compartment ${k}",
      "allow group ${v["exa-group"]} to manage cloud-vmclusters in compartment ${k}",
      "allow group ${v["exa-group"]} to read work-requests in compartment ${k}",
      "allow group ${v["exa-group"]} to manage bastion-session in compartment ${k}",
      "allow group ${v["exa-group"]} to manage instance-family in compartment ${k}",
      #"allow group ${v["exa-group"]} to read instance-agent-plugins in compartment ${k}",
      "allow group ${v["exa-group"]} to manage ons-family in compartment ${k}",
      "allow group ${v["exa-group"]} to manage alarms in compartment ${k}",
      "allow group ${v["exa-group"]} to manage metrics in compartment ${k}",
      "allow group ${v["exa-group"]} to manage data-safe-family in compartment ${k}"
    ] : []
  }  

  #-- Database admin grants on Exainfra compartment
  database_admin_grants_on_exainfra_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"exainfra") && v["db-group"] != null) ? [
      "allow group ${v["db-group"]} to read cloud-exadata-infrastructures in compartment ${k}",
      "allow group ${v["db-group"]} to use cloud-vmclusters in compartment ${k}",
      "allow group ${v["db-group"]} to read work-requests in compartment ${k}",
      "allow group ${v["db-group"]} to manage db-nodes in compartment ${k}",
      "allow group ${v["db-group"]} to manage db-homes in compartment ${k}",
      "allow group ${v["db-group"]} to manage databases in compartment ${k}",
      "allow group ${v["db-group"]} to manage db-backups in compartment ${k}",
      "allow group ${v["db-group"]} to manage data-safe-family in compartment ${k}"
    ] : []
  }  

  #-- Policies
  exainfra_cmps_policies = {for k, v in local.cmp_name_to_cislz_tag_map : 
    (upper("${k}-exainfra-policy")) => {
      name           = "${local.policy_name_prefix}${k}-exainfra-policy"
      compartment_id = v.id
      description    = "CIS Landing Zone policy for Exadata Cloud Service infrastructure compartment."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = concat(local.exainfra_admin_grants_on_exainfra_cmp_map[k],
                              local.exainfra_read_grants_on_exainfra_cmp_map[k],
                              local.database_admin_grants_on_exainfra_cmp_map[k])
    }
  }
}