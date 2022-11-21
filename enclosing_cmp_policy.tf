# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  #--------------------------------------------------------------------------------------------
  #-- Enclosing compartments policies
  #--------------------------------------------------------------------------------------------

  #-- Read grants on enclosing compartment.
  read_grants_on_enclosing_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"enclosing") && v["read-group"] != null) ? [
      "allow group ${v["read-group"]} to read all-resources in compartment ${k}"
    ] : []
  }

  #-- IAM admin grants on enclosing compartment.
  iam_admin_grants_on_enclosing_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"enclosing") && v["iam-group"] != null) ? [
      "allow group ${v["iam-group"]} to manage policies in compartment ${k}", 
      "allow group ${v["iam-group"]} to manage compartments in compartment ${k}"
    ] : []
  }  

  #-- Security admin grants on enclosing compartment.
  security_admin_grants_on_enclosing_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"enclosing") && v["sec-group"] != null) ? [
      "allow group ${v["sec-group"]} to manage tag-namespaces in compartment ${k}",
      "allow group ${v["sec-group"]} to manage tag-defaults in compartment ${k}",
      "allow group ${v["sec-group"]} to manage repos in compartment ${k}",
      "allow group ${v["sec-group"]} to read audit-events in compartment ${k}",
      "allow group ${v["sec-group"]} to read app-catalog-listing in compartment ${k}",
      "allow group ${v["sec-group"]} to read instance-images in compartment ${k}",
      "allow group ${v["sec-group"]} to inspect buckets in compartment ${k}"
    ] : []
  }   

  #-- Application admin grants on enclosing compartment.
  application_admin_grants_on_enclosing_cmp_map = {
    for k, v in local.cmp_name_to_cislz_tag_map : k => (contains(split(",",v["cmp-type"]),"enclosing") && v["app-group"] != null) ? [
      "allow group ${v["app-group"]} to read app-catalog-listing in compartment ${k}",
      "allow group ${v["app-group"]} to read instance-images in compartment ${k}",
      "allow group ${v["app-group"]} to read repos in compartment ${k}"
    ] : []
  }   
  
  #-- Policies
  enclosing_cmps_policies = {for k, v in local.cmp_name_to_cislz_tag_map : 
    (upper("${k}-policy")) => {
      name           = "${local.policy_name_prefix}${k}-policy"
      compartment_id = v.id
      description    = "CIS Landing Zone policy for enclosing compartment."
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      statements     = concat(local.read_grants_on_enclosing_cmp_map[k],local.iam_admin_grants_on_enclosing_cmp_map[k],
                              local.security_admin_grants_on_enclosing_cmp_map[k],local.application_admin_grants_on_enclosing_cmp_map[k])
    }
  }
}