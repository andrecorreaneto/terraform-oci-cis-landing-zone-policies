# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  #--------------------------------------------------------------------------------------------
  #-- Exadata Cloud Service infrastructure compartments policies
  #--------------------------------------------------------------------------------------------
  
  #-- Exainfra read grants on Exinfra compartment
  exainfra_read_grants_on_exainfra_cmp_map = {
    for cmp, values in local.cmp_name_to_cislz_tag_map : cmp => (contains(split(",",values["cmp-type"]),"exainfra") && values["read-group"] != null) ? [
      "allow group ${values["read-group"]} to read all-resources in compartment ${cmp}"
    ] : []
  }

  #-- Exainfra admin grants on Exinfra compartment
  exainfra_admin_grants_on_exainfra_cmp_map = {
    for cmp, values in local.cmp_name_to_cislz_tag_map : cmp => (contains(split(",",values["cmp-type"]),"exainfra") && values["exa-group"] != null) ? [
      "allow group ${values["exa-group"]} to read all-resources in compartment ${cmp}",
      "allow group ${values["exa-group"]} to manage cloud-exadata-infrastructures in compartment ${cmp}",
      "allow group ${values["exa-group"]} to manage cloud-vmclusters in compartment ${cmp}",
      "allow group ${values["exa-group"]} to read work-requests in compartment ${cmp}",
      "allow group ${values["exa-group"]} to manage bastion-session in compartment ${cmp}",
      "allow group ${values["exa-group"]} to manage instance-family in compartment ${cmp}",
      #"allow group ${values["exa-group"]} to read instance-agent-plugins in compartment ${cmp}",
      "allow group ${values["exa-group"]} to manage ons-family in compartment ${cmp}",
      "allow group ${values["exa-group"]} to manage alarms in compartment ${cmp}",
      "allow group ${values["exa-group"]} to manage metrics in compartment ${cmp}",
      "allow group ${values["exa-group"]} to manage data-safe-family in compartment ${cmp}"
    ] : []
  }  

  #-- Database admin grants on Exainfra compartment
  database_admin_grants_on_exainfra_cmp_map = {
    for cmp, values in local.cmp_name_to_cislz_tag_map : cmp => (contains(split(",",values["cmp-type"]),"exainfra") && values["db-group"] != null) ? [
      "allow group ${values["db-group"]} to read cloud-exadata-infrastructures in compartment ${cmp}",
      "allow group ${values["db-group"]} to use cloud-vmclusters in compartment ${cmp}",
      "allow group ${values["db-group"]} to read work-requests in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage db-nodes in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage db-homes in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage databases in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage db-backups in compartment ${cmp}",
      "allow group ${values["db-group"]} to manage data-safe-family in compartment ${cmp}"
    ] : []
  }  

  #-- Policies
  exainfra_cmps_policies = {for cmp, values in local.cmp_name_to_cislz_tag_map : 
    ("exainfra-policy") => {
      name           = "${local.policy_name_prefix}${cmp}-exainfra-policy"
      compartment_id = values.id
      description    = "CIS Landing Zone policy for Exadata Cloud Service infrastructure compartment."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = concat(local.exainfra_admin_grants_on_exainfra_cmp_map[cmp],
                              local.exainfra_read_grants_on_exainfra_cmp_map[cmp],
                              local.database_admin_grants_on_exainfra_cmp_map[cmp])
    }
  }
}