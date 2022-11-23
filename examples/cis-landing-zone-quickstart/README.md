# OCI Policy Module Example - CIS Landing Zone Quick Start

## Introduction

This example shows how to manage IAM (Identity & Access Management) policy resources in Oracle Cloud Infrastructure as in [CIS Landing Zone Quick Start](https://github.com/oracle-quickstart/oci-cis-landingzone-quickstart)

It showcases the two supported usage modes of the [policy module](../..): template policies and supplied policies.

In template policies mode, both compartment level and tenancy level policies are enabled.

- Compartment level policies are managed based on freeform tags applied to compartments. It selects compartments where *cislz* freeform tag matches *cislz_tag_lookup_value* input variable. Then it applies template policies based on *cislz-cmp-type* and *cislz-consumer-groups-\<suffix\>* freeform tags. This example matches compartments example https://github.com/andrecorreaneto/terraform-oci-secure-landing-zone-compartments/tree/main/examples/cis-landing-zone-quickstart.

- Tenancy level policies are managed based on *enable_tenancy_level_template_policies* and *groups_with_tenancy_level_roles* variables passed to the module.

Supplied policies mode is enabled by passing *custom_policies* variable to the module.

Check the [policy module documentation](../../README.md) for details.

## Using this example
1. Prepare one variable file named *terraform.tfvars* with the required information for authenticating to OCI. The contents of *terraform.tfvars* should look something like the following (or copy and re-use the contents of *terraform.tfvars.template*):

```
### TENANCY DETAILS
#
# Get this from OCI Console (after logging in, go to top-right-most menu item and click option "Tenancy: <your tenancy name>").
tenancy_id="<tenancy OCID>"
#
# Get this from OCI Console (after logging in, go to top-right-most menu item and click option "My profile").
user_id="<user OCID>"
#
# The fingerprint can be gathered from your user account. In the "My profile page, click "API keys" on the menu in left hand side).
fingerprint="<PEM key fingerprint>"
#
# This is the full path on your local system to the private key used for the API signing key pair.
private_key_path="<path to the private key that matches the fingerprint above>"
#
# This is the password that protects the private key, if any.
private_key_password=""
#
# This is your tenancy home region.
home_region="<your tenancy home region>"
```

2. Check the provided *main.tf* file. It calls the underlying tags module for resource management.

`main.tf`:

```
module "cislz_policies" {
  source     = "../.."
  tenancy_id = var.tenancy_id

  #policy_name_prefix     = "vision" # Uncomment to add the prefix to all pre-configured policy names.
  cislz_tag_lookup_value = "vision" # tells the module to lookup compartments with freeform tag cislz : "vision"
  
  enable_tenancy_level_template_policies = true
  groups_with_tenancy_level_roles = [
    {"name":"vision-iam-admin-group",     "roles":"iam"},
    {"name":"vision-cred-admin-group",    "roles":"cred"},
    {"name":"vision-cost-admin-group",    "roles":"cost"},
    {"name":"vision-security-admin-group","roles":"security"},
    {"name":"vision-app-admin-group",     "roles":"application"},
    {"name":"vision-auditor-group",       "roles":"auditor"},
    {"name":"vision-announcement_reader-group","roles":"announcement-reader"},
    {"name":"vision-database-admin-group","roles":"basic"},
    {"name":"vision-exainfra-admin-group","roles":"basic"},
    {"name":"vision-storage-admin-group", "roles":"basic"}
  ]

  custom_policies = {
    "CUSTOM-POLICY" : {
      name : "custom-policy"
      description : "Custom policy"
      compartment_id : var.tenancy_id
      #-- The "not ok" statements below are flagged by the module if variable enable_cis_benchmark_checks = true (default)
      statements : [
        #"allow group-a to manage all-resources in tenancy", # not ok
        #"allow group-b to manage all-resources in tenancy ", # not ok
        "allow group group-a to use groups in tenancy where target.group.name != 'Administrators'", # ok
        "allow group group-a to use groups in tenancy where target.group.name = 'group-a'", # ok
        "allow group vision-cred-admin-group to manage users in tenancy where any {target.group.name != 'Administrators'}", # ok
        #"allow group vision-cred-admin-group to manage users in tenancy where any {target.group.name != 'Administrators', request.operation = 'UpdateGroup'}", # not ok
        "allow group vision-cred-admin-group to manage users in tenancy where any {target.group.name != 'Administrators', request.operation = 'ListAPiKeys'}" # ok
        #"allow group vision-cred-admin-group to manage groups in tenancy", # not ok
        #"allow group vision-cred-admin-group to manage users in tenancy" # not ok
      ]             
      defined_tags : null
      freeform_tags : null
    }
  }

  #enable_cis_benchmark_checks = false # uncomment to disable CIS Benchmark policy checks.
}  
```

3. Then execute the example using the usual Terraform workflow:

```
$ terraform init
$ terraform plan
$ terraform apply
```