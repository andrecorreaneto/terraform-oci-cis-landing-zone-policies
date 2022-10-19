# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_compartments" "enclosing" {
  count = contains(keys(local.cmp_tag_map),local.enclosing_cmp_tag) ? 1 : 0
  compartment_id = var.tenancy_id
  compartment_id_in_subtree = true
  access_level = "ANY"
  filter {
    name = "name"
    values = [local.cmp_tag_map[local.enclosing_cmp_tag]]
  }
}

data "oci_identity_compartments" "security" {
  count = contains(keys(local.cmp_tag_map),local.security_cmp_tag) ? 1 : 0
  compartment_id = var.tenancy_id
  compartment_id_in_subtree = true
  access_level = "ANY"
  filter {
    name = "name"
    values = [local.cmp_tag_map[local.security_cmp_tag]]
  }
}

data "oci_identity_compartments" "network" {
  count = contains(keys(local.cmp_tag_map),local.network_cmp_tag) ? 1 : 0
  compartment_id = var.tenancy_id
  compartment_id_in_subtree = true
  access_level = "ANY"
  filter {
    name = "name"
    values = [local.cmp_tag_map[local.network_cmp_tag]]
  }
}

data "oci_identity_compartments" "application" {
  count = contains(keys(local.cmp_tag_map),local.application_cmp_tag) ? 1 : 0
  compartment_id = var.tenancy_id
  compartment_id_in_subtree = true
  access_level = "ANY"
  filter {
    name = "name"
    values = [local.cmp_tag_map[local.application_cmp_tag]]
  }
}

data "oci_identity_compartments" "database" {
  count = contains(keys(local.cmp_tag_map),local.database_cmp_tag) ? 1 : 0
  compartment_id = var.tenancy_id
  compartment_id_in_subtree = true
  access_level = "ANY"
  filter {
    name = "name"
    values = [local.cmp_tag_map[local.database_cmp_tag]]
  }
}

data "oci_identity_compartments" "exainfra" {
  count = contains(keys(local.cmp_tag_map),local.exainfra_cmp_tag) ? 1 : 0
  compartment_id = var.tenancy_id
  compartment_id_in_subtree = true
  access_level = "ANY"
  filter {
    name = "name"
    values = [local.cmp_tag_map[local.exainfra_cmp_tag]]
  }
}