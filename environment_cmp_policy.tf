# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
/* 
locals {
  manage_grants_on_div_cmp = {
    for tag, name in local.cmp_tag_map : tag => [
      "allow group ${local.group_tag_map[tag]} to manage all-resources in compartment ${local.cmp_tag_map[tag]}"
    ] if contains(keys(local.group_tag_map),tag) && upper(substr(tag,0,4)) == "DIV:"
  }

  #-- Division policies
  div_policies = {for tag, id in local.cmp_tag_to_id_map : upper("${replace(replace(tag,":","-"),"|","-")}-policy") => {
    name           = lower("${replace(replace(tag,":","-"),"|","-")}-policy")
    compartment_id = id
    description    = "CIS Landing Zone ${lower(split(":",tag)[1])} division policy."
    defined_tags   = var.defined_tags
    freeform_tags  = var.freeform_tags
    statements     = local.manage_grants_on_div_cmp[tag]
  } if contains(keys(local.manage_grants_on_div_cmp),tag)}

  manage_grants_on_env_cmp = {
    for tag, name in local.cmp_tag_map : tag => [
      "allow group ${local.group_tag_map[tag]} to manage all-resources in compartment ${local.cmp_tag_map[tag]}"
    ] if contains(keys(local.group_tag_map),tag) && upper(substr(tag,0,4)) == "ENV:"
  }

  all_manage_grants = merge(local.manage_grants_on_div_cmp, local.manage_grants_on_env_cmp)  

  #-- Environment policies
  env_policies = {for tag, id in local.cmp_tag_to_id_map : upper("${replace(replace(tag,":","-"),"|","-")}-policy") => {
    name           = lower("${replace(replace(tag,":","-"),"|","-")}-policy")
    compartment_id = id
    description    = "CIS Landing Zone ${lower(split(":",split("|",tag)[0])[1])} ${lower(split(":",split("|",tag)[1])[1])} environment policy."
    defined_tags   = var.defined_tags
    freeform_tags  = var.freeform_tags
    statements     = local.manage_grants_on_env_cmp[tag]
  } if contains(keys(local.manage_grants_on_env_cmp),tag)}
}   */