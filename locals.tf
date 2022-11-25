# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {  
  compartments = var.compartments != null ? var.compartments : data.oci_identity_compartments.all.compartments

  cmp_name_to_cislz_tag_map = {for cmp in local.compartments : cmp.name => {
    cmp-type     : lookup(cmp.freeform_tags,"cislz-cmp-type",""),
    iam-group    : length(lookup(cmp.freeform_tags,"cislz-consumer-groups-iam","")) > 0 ? lookup(cmp.freeform_tags,"cislz-consumer-groups-iam","") : null,
    sec-group    : length(lookup(cmp.freeform_tags,"cislz-consumer-groups-security","")) > 0 ? lookup(cmp.freeform_tags,"cislz-consumer-groups-security","") : null,
    read-group   : length(lookup(cmp.freeform_tags,"cislz-consumer-groups-read","")) > 0 ? lookup(cmp.freeform_tags,"cislz-consumer-groups-read","") : null,
    app-group    : length(lookup(cmp.freeform_tags,"cislz-consumer-groups-application","")) > 0 ? lookup(cmp.freeform_tags,"cislz-consumer-groups-application","") : null,
    db-group     : length(lookup(cmp.freeform_tags,"cislz-consumer-groups-database","")) > 0 ? lookup(cmp.freeform_tags,"cislz-consumer-groups-database","") : null,
    net-group    : length(lookup(cmp.freeform_tags,"cislz-consumer-groups-network","")) > 0 ? lookup(cmp.freeform_tags,"cislz-consumer-groups-network","") : null,
    exa-group    : length(lookup(cmp.freeform_tags,"cislz-consumer-groups-exainfra","")) > 0 ? lookup(cmp.freeform_tags,"cislz-consumer-groups-exainfra","") : null,
    stg-group    : length(lookup(cmp.freeform_tags,"cislz-consumer-groups-storage","")) > 0 ? lookup(cmp.freeform_tags,"cislz-consumer-groups-storage","") : null,
    db-dyn-group : length(lookup(cmp.freeform_tags,"cislz-consumer-groups-dyn-database-kms","")) > 0 ? lookup(cmp.freeform_tags,"cislz-consumer-groups-dyn-database-kms","") : null,
    ca-dyn-group : length(lookup(cmp.freeform_tags,"cislz-consumer-groups-dyn-compute-agent","")) > 0 ? lookup(cmp.freeform_tags,"cislz-consumer-groups-dyn-compute-agent","") : null,
    id           : cmp.id
  } if lookup(cmp.freeform_tags,"cislz","") == var.cislz_tag_lookup_value }

  policy_name_prefix = var.policy_name_prefix != null ? "${var.policy_name_prefix}-" : ""

}  