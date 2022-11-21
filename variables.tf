# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_id" {
  description = "The tenancy ocid."
  type = string
}

variable "enable_compartment_level_template_policies" {
  description = "Enables the module to manage template (pre-configured) policies at the compartment level (compartments other than root)."
  type = string
  default = true
}

variable "cislz_tag_lookup_value" {
  description = "The cislz tag value used for looking up compartments. This module searches for compartments that are freeform tagged with cislz = <cislz_tag_lookup_value>. The selected compartments are eligible for template (pre-configured) policies. If the lookup fails, no template policies are applied."
  type = string
  default = ""
}

variable "enable_tenancy_level_template_policies" {
  description = "Enables the module to manage template (pre-configured) policies at the tenancy level (root compartment). Variable groups_with_tenancy_level_roles only applies if this is set to true."
  type = string
  default = false
}

variable "groups_with_tenancy_level_roles" {
  description = "A list of group names and their roles at the root compartment (a.k.a tenancy) level. Pre-configured policies are assigned to each group in the root compartment. Only applicable if variable enable_tenancy_level_policies is set to true."
  type = list(object({
    name = string
    roles = string
  }))
  default = []
}

variable "defined_tags" {
  description = "Any defined tags to apply on the template (pre-configured) policies." 
  type = map(string)
  default = null
}

variable "freeform_tags" {
  description = "Any freeform tags to apply on the template (pre-configured) policies."
  type = map(string)
  default = null
}

variable "policy_name_prefix" {
  description = "A string used as naming prefix to template (pre-configured) policy names."
  type = string
  default = null
}

variable "custom_policies" {
  description = "A map of custom policies. Use this to suplement the template (pre-configured) policies. For completely overriding the template policies, set variables enable_compartment_level_template_policies and enable_tenancy_level_template_policies to false."
  type = map(object({
    name           = string
    description    = string
    compartment_id = string
    statements     = list(string)
    defined_tags   = map(string)
    freeform_tags  = map(string)
  }))
  default = {}
}

variable "enable_cis_benchmark_checks" {
  description = "Whether to check policies for CIS Benchmark recommendations."
  type = bool
  default = true
}
  
variable "enable_output" {
  description = "Whether to show module output."
  type = bool
  default = false
}

variable "enable_debug" {
  description = "Whether to show module debug output."
  type = bool
  default = false
}