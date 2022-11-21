# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {  
  
  cmp_name_to_cislz_tag_map = {for cmp in data.oci_identity_compartments.all.compartments : cmp.name => {
    cmp-type     : lookup(cmp.freeform_tags,"cislz-cmp-type",""),
    iam-group    : length(regexall("iam:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))) > 0 ? regexall("iam:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))[0][0] : null,
    sec-group    : length(regexall("security:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))) > 0 ? regexall("security:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))[0][0] : null,
    read-group   : length(regexall("read:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))) > 0 ? regexall("read:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))[0][0] : null,
    app-group    : length(regexall("application:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))) > 0 ? regexall("application:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))[0][0] : null,
    db-group     : length(regexall("database:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))) > 0 ? regexall("database:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))[0][0] : null,
    net-group    : length(regexall("network:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))) > 0 ? regexall("network:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))[0][0] : null,
    exa-group    : length(regexall("exainfra:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))) > 0 ? regexall("exainfra:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))[0][0] : null,
    stg-group    : length(regexall("storage:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))) > 0 ? regexall("storage:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))[0][0] : null,
    db-dyn-group : length(regexall("database-kms-dyn:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))) > 0 ? regexall("database-kms-dyn:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))[0][0] : null,
    ca-dyn-group : length(regexall("compute-agent-dyn:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))) > 0 ? regexall("compute-agent-dyn:(.*?)(,|$)",lookup(cmp.freeform_tags,"cislz-consumer-groups",""))[0][0] : null,
    id           : cmp.id
  } if lookup(cmp.freeform_tags,"cislz","") == var.cislz_tag_lookup_value }

  policy_name_prefix = var.policy_name_prefix != null ? "${var.policy_name_prefix}-" : ""

}  