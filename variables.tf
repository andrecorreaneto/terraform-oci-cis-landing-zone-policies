# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_id" {
  type = string
}

variable "policy_name_prefix" {
  description = "Used as naming prefix to default policy names. Ignored if the default policy names are overriden with the *_policy_name variables."
  type = string
}

variable "compartments" {
  type = list(object({
    name = string
    freeform_tags = map(string)
  }))
}

variable "groups" {
  type = list(object({
    name = string
    freeform_tags = map(string)
  }))
}

variable "dynamic_groups" {
  type = list(object({
    name = string
    freeform_tags = map(string)
  }))
  default = null
}

variable "defined_tags" {
  description = "Any defined tags to apply on the Landing Zone policies." 
  type = map(string)
  default = null
}

variable "freeform_tags" {
  description = "Any freeform tags to apply on the Landing Zone policies."
  type = map(string)
  default = null
}

variable "common_admin_root_policy_name" {
  type = string
  default = null
}

variable "iam_admin_root_policy_name" {
  type = string
  default = null
}

variable "cred_admin_root_policy_name" {
  type = string
  default = null
}

variable "cost_admin_root_policy_name" {
  type = string
  default = null
}

variable "security_admin_root_policy_name" {
  type = string
  default = null
}

variable "auditor_policy_name" {
  type = string
  default = null
}

variable "announcement_reader_policy_name" {
  type = string
  default = null
}

variable "iam_admin_policy_name" {
  type = string
  default = null
}

variable "security_admin_policy_name" {
  type = string
  default = null
}

variable "network_admin_policy_name" {
  type = string
  default = null
}

variable "database_admin_policy_name" {
  type = string
  default = null
}

variable "appdev_admin_policy_name" {
  type = string
  default = null
}

variable "exainfra_admin_policy_name" {
  type = string
  default = null
}

variable "storage_admin_policy_name" {
  type = string
  default = null
}

variable "compute_agent_policy_name" {
  type = string
  default = null
}

variable "database_kms_policy_name" {
  type = string
  default = null
}