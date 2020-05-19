# Terraform #
# Introduction #
Welcome to Hands on Workshop! Are you bored with managing your cloud environment via Cloud portal? Are you tired with clicking icons repeatedly in Cloud portal to create resources?  Then it is the workshop you should try. This workshop will give you some different kind of experience for handling Cloud Resources. 
In this workshop we will not going to touch web portal, instead we learn and manage all the Cloud resources through Code, i.e Infrastructure As A Code. We are going to create resources through Terraform script. We could discuss in detail about Terraform scripting for each Cloud resource and also we shall learn about creating an Instance in OCI with all dependent resources through Terraform.
##  Steps
1)	Creation of Network Resources
2)	Creation of Instance (Linux & Windows)

Remember we need to create resources in cloud, so first we need to specify OCI credentials for terraform to login into OCI. The credentials will be specified in terraform.tfvars file. The basic credentials required are User OCID, Tenancy OCID, fingerprint, compartment OCID, region and Private key. 

First create a folder to store Terraform scripts.
Inside the folder create terraform.tfvars with below details.
    #tenancy and user information
    tenancy_ocid = <Tenancy OCID>
    user_ocid = <User OCID>
    fingerprint= <FinerPrint value>
    private_key_path = <Private key file with location>


### Tenancy OCID 
Open the Profile menu (User menu icon)  and click Tenancy: <your_tenancy_name>.
The tenancy OCID is shown under Tenancy Information. Click Copy to copy it to your clipboard.
![Tenancy](https://github.com/kmkittu/Terraform/blob/master/Tenancy.png)

The tenancy OCID looks something like this
ocid1.tenancy.oc1..<unique_ID>     (notice the word "tenancy" in it)

### User OCID    
If you're signed in as the user to OCI console: Open the Profile menu (User menu icon)   and click User Settings.
If you're an administrator doing this for another user: Open the navigation menu. Under Governance and Administration, go to Identity and click Users. Select the user from the list.
The user OCID is shown under User Information. Click Copy to copy it to your clipboard.
<Picture>
 
### Private key 
SSH key pair is required to login into OCI console
If SSH key pair is not created, then follow the below steps.

    $ openssl genrsa -out oci_key.pem 2048 
    Generating RSA private key, 2048 bit long modulus
    ...................................................................................+++
    .....+++
    e is 65537 (0x10001)

-out denotes output location of the generated private key.  In the above example, oci_key.pem is the private key. 

    [oracle@db key]$ ls -lrt
    -rw-r--r-- 1 oracle oinstall 1679 Apr  3 07:35 oci_key.pem

Generate Public Key with Pem(Privacy Enhanced Mail) format

    [oracle@db key]$ openssl rsa -pubout -in oci_key.pem -out oci_key_public.pem
    writing RSA key
    [oracle@db key]$ ls -lrt
    -rw-r--r-- 1 oracle oinstall 1679 Apr  3 07:35 oci_key.pem
    -rw-r--r-- 1 oracle oinstall  451 Apr  3 07:40 oci_key_public.pem

### Fingerprint   
You can get the key's fingerprint with the following OpenSSL command. If you're using Windows, you'll need to install Git Bash for Windows and run the command with that tool.

    openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c

Also in other way when you upload the public key in the Console (In the user details page) , the fingerprint is also automatically displayed there. It looks something like this: 12:34:56:78:90:ab:cd:ef:12:34:56:78:90:ab:cd:ef
<Picture> 

### Region
Region at which OCI account is associated. You can find this information in the console easily

### Compartment OCID
Open the navigation menu, under Identity you can find compartments. Click that. It will list all the compartments available with the account. Choose the compartment on which we need to create instance. That will show the compartment details including OCID as shown in the picture.
<Picture>

Some additional credentials might be required based on requirement like Vault OCID, Key OCID, Management Endpoint, Crypto Endpoint. 

### Vault OCID
Login into OCI account and Open the navigation menu, under Security you can find Vault. Click that.
Click Create Vault and specify vault name to create.  You can collect VAULT OCID
<Picture>
Inside the vault create Keys. While creating Key you can specify the Algorithm and Key length.
Collect the details of vault_id, key_id, management_endpoint and Crypto_endpoint. Except key OCID all other information is available in Vault page as seen in the below picture.  
<Picture>
Key OCID will be available in Keys details page
<Picture>

### Example:

        #tenancy and user information
        tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaalxltbjsgjhukykkd6trlxdfbwjuulnavxqehvv3crknt7ewhlpa"
        user_ocid = "ocid1.user.oc1..aaaaaaaaqidqcqnx6mfprmzt2nn6xudu3t4pgj4bbqlk23axlr4abbjbfyja"
        fingerprint= "bf:0a:e6:c7:9c:93:d2:84:87:94:4f:fc:d4:24:ec:c1"
        private_key_path = "/root/hol/oci_key.pem"


        # Region
        region = "us-ashburn-1"

        # Compartment
        compartment_ocid = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxedffdfdhhghgq7swk426b5hnflyvpq"

        #vaults and key information
        vault_id = "ocid1.vault.oc1.iad.bbpcqhz3aaeug.abuwcljszxj7rps3vxe4x5awnblkvirt2erscvhtdr54ccbz4p46vkzr4fva"
        key_id = "ocid1.key.oc1.iad.bbpcqhz3aaeug.abuwcljrauzipeizeb5v5qomlcw3cymli4yrceu2e4uffq4nlzqfyd54sixa"
        management_endpoint = "https://bbpcufnhinetg-management.kms.us-ashburn-1.oraclecloud.com"
        #crypto_endpoint = "https://bbpcufnhinetg-crypto.kms.us-ashburn-1.oraclecloud.com"


## 1) Network Resources
Creation of VCN
Creation of Gateways

### VCN
  Virutal cloud network is the first cloud resource to be created. VCN has all the network related resources. While creating VCN, we could also create its components subnet and gateways

Create a file in the name of VCN.tf and copy the below contents. This file has different sections to create various cloud resources and that has been mentioned in the comments at the begining of the section.

    #resource block for oci vcn.
    resource "oci_core_vcn" "test_vcn" {
        #Required
        cidr_block = "${var.vcn_cidr_block}"
        compartment_id = "${var.compartment_ocid}"
        display_name = "${var.vcn_display_name}"
        dns_label = "${var.vcn_dns_label}"

    }

    #resource block for defining public subnet
    resource "oci_core_subnet" "publicsubnet"{
    dns_label = "${var.publicSubnet_dns_label}"
    compartment_id = "${var.compartment_ocid}"
    vcn_id = "${oci_core_vcn.test_vcn.id}"
    display_name = "${var.display_name_publicsubnet}"
    cidr_block = "${var.cidr_block_publicsubnet}"
    route_table_id = "${oci_core_route_table.publicRT.id}"
    security_list_ids = ["${oci_core_security_list.publicSL.id}"]
    }
    #resource for creating private route table
    resource "oci_core_route_table" "privateRT"{
    compartment_id = "${var.compartment_ocid}"
    vcn_id = "${oci_core_vcn.test_vcn.id}"
    display_name = "private_route_table"
    }
    #resource block for defining Private subnet
    resource "oci_core_subnet" "privatesubnet"{
    dns_label = "${var.privateSubnet_dns_label}"
    compartment_id = "${var.compartment_ocid}"
    vcn_id = "${oci_core_vcn.test_vcn.id}"
    display_name = "${var.display_name_privatesubnet}"
    cidr_block = "${var.cidr_block_privatesubnet}"
    prohibit_public_ip_on_vnic="true"
    route_table_id = "${oci_core_route_table.privateRT.id}"
    security_list_ids = ["${oci_core_security_list.privateSL.id}"]
    }
    #resource block for internet gateway
    resource "oci_core_internet_gateway" "test_internet_gateway" {
    compartment_id = "${var.compartment_ocid}"
    vcn_id         = "${oci_core_vcn.test_vcn.id}"
    }
    #resource block for route table with route rule for internet gateway
    resource "oci_core_route_table" "publicRT" {
    vcn_id = "${oci_core_vcn.test_vcn.id}"
    compartment_id = "${var.compartment_ocid}"
    route_rules {
        destination       = "0.0.0.0/0"
        network_entity_id = "${oci_core_internet_gateway.test_internet_gateway.id}"
    }
    }

    #resource block for security list
    resource "oci_core_security_list" "publicSL" {
    compartment_id = "${var.compartment_ocid}"
    vcn_id         = "${oci_core_vcn.test_vcn.id}"
    display_name   = "public_security_list"

    egress_security_rules {
        protocol    = "all"
        destination = "0.0.0.0/0"
    }
    ingress_security_rules {
        tcp_options {
        max = "22"
        min = "22"
        }

        protocol = "6"
        source   = "0.0.0.0/0"
    }
    ingress_security_rules {
        icmp_options {
        type = "0"
        }

        protocol = "1"
        source   = "0.0.0.0/0"
    }
    ingress_security_rules {
        icmp_options {
        type = "3"
        code = "4"
        }

        protocol = "1"
        source   = "0.0.0.0/0"
    }
    ingress_security_rules {
        icmp_options {
        type = "8"
        }

        protocol = "1"
        source   = "0.0.0.0/0"
    }
    }


Also create variables.tf with below content

        #define oci provider configuaration
        provider "oci"{
            tenancy_ocid = "${var.tenancy_ocid}"
            user_ocid = "${var.user_ocid}"
            region ="${var.region}"
            private_key_path = "${var.private_key_path}"
            fingerprint = "${var.fingerprint}"
        }

        #provide the list of availability domain
        data "oci_identity_availability_domain" "ad" {
        compartment_id = "${var.compartment_ocid}"
        ad_number = "${var.availability_domain}"
        }
        #common variables
        variable "tenancy_ocid"{}
        variable "user_ocid"{}
        variable "private_key_path"{}
        variable "fingerprint"{}
        variable "region"{}
        variable "compartment_ocid"{}
        variable "availability_domain"{
        default = "1"
        }

        #variables to define vcn
        variable "vcn_cidr_block"{
        description = "provide the valid IPV4 cidr block for vcn"
        }
        variable "vcn_dns_label" {
        description = "A DNS label for the VCN, used in conjunction with the VNIC's hostname and subnet's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet. "
        default     = "vcn"
        }
        variable "vcn_display_name" {
        description = "provide a display name for vcn"
        }


        #variables to define the public subnet
        variable "cidr_block_publicsubnet"{
    description = "note that the cidr block for the subnet must be smaller and part of the vcn cidr block"
        }
        variable "publicSubnet_dns_label" {
        description = "A DNS label prefix for the subnet, used in conjunction with the VNIC's hostname and VCN's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet. "
        default     = "publicsubnet"
        }
        variable "display_name_publicsubnet"{
        description = "privide a displayname for public subnet"
        }
    variable "privateSubnet_dns_label" {
    description = "A DNS label prefix for the subnet, used in conjunction with the VNIC's hostname and VCN's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet. "
    default     = "privatesubnet"
    }

    variable "display_name_privatesubnet"{
    description = "privide a displayname for Private subnet"
    }

    variable "cidr_block_privatesubnet"{
    description = "note that the Private cidr block for the subnet must be smaller and part of the vcn cidr block"
    }

VCN has private subnet and we need to specify security list for that. Create private security list file (private_security_list.tf).

    resource "oci_core_security_list" "privateSL" {
    compartment_id = "${var.compartment_ocid}"
    vcn_id         = "${oci_core_vcn.test_vcn.id}"
    display_name   = "private_security_list"

    egress_security_rules {
        protocol    = "all"
        destination = "0.0.0.0/0"
    }
    ingress_security_rules {
        tcp_options {
        max = "22"
        min = "22"
        }

        protocol = "6"
        source   = "0.0.0.0/0"
    }
    ingress_security_rules {
        icmp_options {
        type = "0"
        }

        protocol = "1"
        source   = "0.0.0.0/0"
    }
    ingress_security_rules {
        icmp_options {
        type = "3"
        code = "4"
        }

        protocol = "1"
        source   = "0.0.0.0/0"
    }
    ingress_security_rules {
    icmp_options {
        type = "8"
        }

        protocol = "1"
        source   = "0.0.0.0/0"
    }
    }

So far we have created two terraform files. Its time to execute those.
Init the Terraform to the current directory

        #terraform init

                # terraform init

        Initializing the backend...

        Initializing provider plugins...

        The following providers do not have any version constraints in configuration,
        so the latest version was installed.

        To prevent automatic upgrades to new major versions that may contain breaking
        changes, it is recommended to add version = "..." constraints to the
        corresponding provider blocks in configuration, with the constraint strings
        suggested below.

        * provider.oci: version = "~> 3.74"

        Terraform has been successfully initialized!

        You may now begin working with Terraform. Try running "terraform plan" to see
        any changes that are required for your infrastructure. All Terraform commands
        should now work.

        If you ever set or change modules or backend configuration for Terraform,
        rerun this command to reinitialize your working directory. If you forget, other
        commands will detect it and remind you to do so if necessary.


Execute the Terraform plan to verify everything fine. We need to provide CIDR values for VCN, Public Subnet, Private Subnet and names of VPN, Public Subnet and Private Subnet.

        # terraform plan
        var.cidr_block_privatesubnet
        note that the Private cidr block for the subnet must be smaller and part of the vcn cidr block

        Enter a value: 10.0.1.0/24

        var.cidr_block_publicsubnet
        note that the cidr block for the subnet must be smaller and part of the vcn cidr block

        Enter a value: 10.0.0.0/24

        var.display_name_privatesubnet
        privide a displayname for Private subnet

        Enter a value: PVsubnet

        var.display_name_publicsubnet
        privide a displayname for public subnet

        Enter a value: PUBsubnet

        var.vcn_cidr_block
        provide the valid IPV4 cidr block for vcn

        Enter a value: 10.0.0.0/16

        var.vcn_display_name
        provide a display name for vcn

        Enter a value: VCNHub

        Refreshing Terraform state in-memory prior to plan...
        The refreshed state will be used to calculate this plan, but will not be
        persisted to local or remote state storage.

        data.oci_identity_availability_domain.ad: Refreshing state...

        ------------------------------------------------------------------------

        An execution plan has been generated and is shown below.
        Resource actions are indicated with the following symbols:
        + create

        Terraform will perform the following actions:

        # oci_core_internet_gateway.test_internet_gateway will be created
        + resource "oci_core_internet_gateway" "test_internet_gateway" {
            + compartment_id = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + defined_tags   = (known after apply)
            + display_name   = (known after apply)
            + enabled        = true
            + freeform_tags  = (known after apply)
            + id             = (known after apply)
            + state          = (known after apply)
            + time_created   = (known after apply)
            + vcn_id         = (known after apply)
            }

        # oci_core_route_table.privateRT will be created
        + resource "oci_core_route_table" "privateRT" {
            + compartment_id = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + defined_tags   = (known after apply)
            + display_name   = "private_route_table"
            + freeform_tags  = (known after apply)
            + id             = (known after apply)
            + state          = (known after apply)
            + time_created   = (known after apply)
            + vcn_id         = (known after apply)
            }

        # oci_core_route_table.publicRT will be created
        + resource "oci_core_route_table" "publicRT" {
            + compartment_id = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + defined_tags   = (known after apply)
            + display_name   = (known after apply)
            + freeform_tags  = (known after apply)
            + id             = (known after apply)
            + state          = (known after apply)
            + time_created   = (known after apply)
            + vcn_id         = (known after apply)

            + route_rules {
                + cidr_block        = (known after apply)
                + description       = (known after apply)
                + destination       = "0.0.0.0/0"
                + destination_type  = (known after apply)
                + network_entity_id = (known after apply)
                }
            }

        # oci_core_security_list.privateSL will be created
        + resource "oci_core_security_list" "privateSL" {
            + compartment_id = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + defined_tags   = (known after apply)
            + display_name   = "private_security_list"
            + freeform_tags  = (known after apply)
            + id             = (known after apply)
            + state          = (known after apply)
            + time_created   = (known after apply)
            + vcn_id         = (known after apply)

            + egress_security_rules {
                + description      = (known after apply)
                + destination      = "0.0.0.0/0"
                + destination_type = (known after apply)
                + protocol         = "all"
                + stateless        = (known after apply)
                }

            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "1"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + icmp_options {
                    + code = -1
                    + type = 0
                    }
                }
            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "1"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + icmp_options {
                    + code = -1
                    + type = 8
                    }
                }
            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "1"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + icmp_options {
                    + code = 4
                    + type = 3
                    }
                }
            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "6"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + tcp_options {
                    + max = 22
                    + min = 22
                    }
                }
            }

        # oci_core_security_list.publicSL will be created
        + resource "oci_core_security_list" "publicSL" {
            + compartment_id = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + defined_tags   = (known after apply)
            + display_name   = "public_security_list"
            + freeform_tags  = (known after apply)
            + id             = (known after apply)
            + state          = (known after apply)
            + time_created   = (known after apply)
            + vcn_id         = (known after apply)

            + egress_security_rules {
                + description      = (known after apply)
                + destination      = "0.0.0.0/0"
                + destination_type = (known after apply)
                + protocol         = "all"
                + stateless        = (known after apply)
                }

            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "1"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + icmp_options {
                    + code = -1
                    + type = 0
                    }
                }
            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "1"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + icmp_options {
                    + code = -1
                    + type = 8
                    }
                }
            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "1"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + icmp_options {
                    + code = 4
                    + type = 3
                    }
                }
            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "6"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + tcp_options {
                    + max = 22
                    + min = 22
                    }
                }
            }

        # oci_core_subnet.privatesubnet will be created
        + resource "oci_core_subnet" "privatesubnet" {
            + availability_domain        = (known after apply)
            + cidr_block                 = "10.0.1.0/24"
            + compartment_id             = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + defined_tags               = (known after apply)
            + dhcp_options_id            = (known after apply)
            + display_name               = "PVsubnet"
            + dns_label                  = "privatesubnet"
            + freeform_tags              = (known after apply)
            + id                         = (known after apply)
            + ipv6cidr_block             = (known after apply)
            + ipv6public_cidr_block      = (known after apply)
            + ipv6virtual_router_ip      = (known after apply)
            + prohibit_public_ip_on_vnic = true
            + route_table_id             = (known after apply)
            + security_list_ids          = (known after apply)
            + state                      = (known after apply)
            + subnet_domain_name         = (known after apply)
            + time_created               = (known after apply)
            + vcn_id                     = (known after apply)
            + virtual_router_ip          = (known after apply)
            + virtual_router_mac         = (known after apply)
            }

        # oci_core_subnet.publicsubnet will be created
        + resource "oci_core_subnet" "publicsubnet" {
            + availability_domain        = (known after apply)
            + cidr_block                 = "10.0.0.0/24"
            + compartment_id             = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + defined_tags               = (known after apply)
            + dhcp_options_id            = (known after apply)
            + display_name               = "PUBsubnet"
            + dns_label                  = "publicsubnet"
            + freeform_tags              = (known after apply)
            + id                         = (known after apply)
            + ipv6cidr_block             = (known after apply)
            + ipv6public_cidr_block      = (known after apply)
            + ipv6virtual_router_ip      = (known after apply)
            + prohibit_public_ip_on_vnic = (known after apply)
            + route_table_id             = (known after apply)
            + security_list_ids          = (known after apply)
            + state                      = (known after apply)
            + subnet_domain_name         = (known after apply)
            + time_created               = (known after apply)
            + vcn_id                     = (known after apply)
            + virtual_router_ip          = (known after apply)
            + virtual_router_mac         = (known after apply)
            }

        # oci_core_vcn.test_vcn will be created
        + resource "oci_core_vcn" "test_vcn" {
            + cidr_block               = "10.0.0.0/16"
            + compartment_id           = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + default_dhcp_options_id  = (known after apply)
            + default_route_table_id   = (known after apply)
            + default_security_list_id = (known after apply)
            + defined_tags             = (known after apply)
            + display_name             = "VCNHub"
            + dns_label                = "vcn"
            + freeform_tags            = (known after apply)
            + id                       = (known after apply)
            + ipv6cidr_block           = (known after apply)
            + ipv6public_cidr_block    = (known after apply)
            + is_ipv6enabled           = (known after apply)
            + state                    = (known after apply)
            + time_created             = (known after apply)
            + vcn_domain_name          = (known after apply)
            }

        Plan: 8 to add, 0 to change, 0 to destroy.

        Warning: Value for undeclared variable

        The root module does not declare a variable named "key_id" but a value was
        found in file "terraform.tfvars". To use this value, add a "variable" block to
        the configuration.

        Using a variables file to set an undeclared variable is deprecated and will
        become an error in a future release. If you wish to provide certain "global"
        settings to all configurations in your organization, use TF_VAR_...
        environment variables to set these instead.


        Warning: Value for undeclared variable

        The root module does not declare a variable named "vault_id" but a value was
        found in file "terraform.tfvars". To use this value, add a "variable" block to
        the configuration.

        Using a variables file to set an undeclared variable is deprecated and will
        become an error in a future release. If you wish to provide certain "global"
        settings to all configurations in your organization, use TF_VAR_...
        environment variables to set these instead.


        Warning: Value for undeclared variable

        The root module does not declare a variable named "crypto_endpoint" but a
        value was found in file "terraform.tfvars". To use this value, add a
        "variable" block to the configuration.

        Using a variables file to set an undeclared variable is deprecated and will
        become an error in a future release. If you wish to provide certain "global"
        settings to all configurations in your organization, use TF_VAR_...
        environment variables to set these instead.


        Warning: Values for undeclared variables

        In addition to the other similar warnings shown, 2 other variable(s) defined
        without being declared.


        Warning: Interpolation-only expressions are deprecated

        on private_security_list.tf line 2, in resource "oci_core_security_list" "privateSL":
        2:   compartment_id = "${var.compartment_ocid}"

        Terraform 0.11 and earlier required all non-constant expressions to be
        provided via interpolation syntax, but this pattern is now deprecated. To
        silence this warning, remove the "${ sequence from the start and the }"
        sequence from the end of this expression, leaving just the inner expression.

        Template interpolation syntax is still used to construct strings from
        expressions when the template includes multiple interpolation sequences or a
        mixture of literal strings and interpolations. This deprecation applies only
        to templates that consist entirely of a single interpolation sequence.

        (and 31 more similar warnings elsewhere)


        ------------------------------------------------------------------------

        Note: You didn't specify an "-out" parameter to save this plan, so Terraform
        can't guarantee that exactly these actions will be performed if
        "terraform apply" is subsequently run.


Plan is almost like an execution. It collects inputs from user and cross checks whether the execution will go smoother. Warnings and Errors will be shown. If there are errors in plan execution, we need to address that first. Else proceed with execution using apply command.

        #Terraform apply

Apply will connect OCI and create the VCN and asociated resources.
        #terraform apply
        var.cidr_block_privatesubnet
        note that the Private cidr block for the subnet must be smaller and part of the vcn cidr block

        Enter a value: 10.0.1.0/24

        var.cidr_block_publicsubnet
        note that the cidr block for the subnet must be smaller and part of the vcn cidr block

        Enter a value: 10.0.0.0/24

        var.display_name_privatesubnet
        privide a displayname for Private subnet

        Enter a value: PVsub

        var.display_name_publicsubnet
        privide a displayname for public subnet

        Enter a value: PUBsub

        var.vcn_cidr_block
        provide the valid IPV4 cidr block for vcn

        Enter a value: 10.0.0.0/16

        var.vcn_display_name
        provide a display name for vcn

        Enter a value: VCNHub

        data.oci_identity_availability_domain.ad: Refreshing state...

        An execution plan has been generated and is shown below.
        Resource actions are indicated with the following symbols:
        + create

        Terraform will perform the following actions:

        # oci_core_internet_gateway.test_internet_gateway will be created
        + resource "oci_core_internet_gateway" "test_internet_gateway" {
            + compartment_id = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + defined_tags   = (known after apply)
            + display_name   = (known after apply)
            + enabled        = true
            + freeform_tags  = (known after apply)
            + id             = (known after apply)
            + state          = (known after apply)
            + time_created   = (known after apply)
            + vcn_id         = (known after apply)
            }

        # oci_core_route_table.privateRT will be created
        + resource "oci_core_route_table" "privateRT" {
            + compartment_id = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + defined_tags   = (known after apply)
            + display_name   = "private_route_table"
            + freeform_tags  = (known after apply)
            + id             = (known after apply)
            + state          = (known after apply)
            + time_created   = (known after apply)
            + vcn_id         = (known after apply)
            }

        # oci_core_route_table.publicRT will be created
        + resource "oci_core_route_table" "publicRT" {
            + compartment_id = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + defined_tags   = (known after apply)
            + display_name   = (known after apply)
            + freeform_tags  = (known after apply)
            + id             = (known after apply)
            + state          = (known after apply)
            + time_created   = (known after apply)
            + vcn_id         = (known after apply)

            + route_rules {
                + cidr_block        = (known after apply)
                + description       = (known after apply)
                + destination       = "0.0.0.0/0"
                + destination_type  = (known after apply)
                + network_entity_id = (known after apply)
                }
            }

        # oci_core_security_list.privateSL will be created
        + resource "oci_core_security_list" "privateSL" {
            + compartment_id = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + defined_tags   = (known after apply)
            + display_name   = "private_security_list"
            + freeform_tags  = (known after apply)
            + id             = (known after apply)
            + state          = (known after apply)
            + time_created   = (known after apply)
            + vcn_id         = (known after apply)

            + egress_security_rules {
                + description      = (known after apply)
                + destination      = "0.0.0.0/0"
                + destination_type = (known after apply)
                + protocol         = "all"
                + stateless        = (known after apply)
                }

            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "1"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + icmp_options {
                    + code = -1
                    + type = 0
                    }
                }
            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "1"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + icmp_options {
                    + code = -1
                    + type = 8
                    }
                }
            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "1"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + icmp_options {
                    + code = 4
                    + type = 3
                    }
                }
            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "6"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + tcp_options {
                    + max = 22
                    + min = 22
                    }
                }
            }

        # oci_core_security_list.publicSL will be created
        + resource "oci_core_security_list" "publicSL" {
            + compartment_id = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + defined_tags   = (known after apply)
            + display_name   = "public_security_list"
            + freeform_tags  = (known after apply)
            + id             = (known after apply)
            + state          = (known after apply)
            + time_created   = (known after apply)
            + vcn_id         = (known after apply)

            + egress_security_rules {
                + description      = (known after apply)
                + destination      = "0.0.0.0/0"
                + destination_type = (known after apply)
                + protocol         = "all"
                + stateless        = (known after apply)
                }

            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "1"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + icmp_options {
                    + code = -1
                    + type = 0
                    }
                }
            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "1"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + icmp_options {
                    + code = -1
                    + type = 8
                    }
                }
            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "1"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + icmp_options {
                    + code = 4
                    + type = 3
                    }
                }
            + ingress_security_rules {
                + description = (known after apply)
                + protocol    = "6"
                + source      = "0.0.0.0/0"
                + source_type = (known after apply)
                + stateless   = false

                + tcp_options {
                    + max = 22
                    + min = 22
                    }
                }
            }

        # oci_core_subnet.privatesubnet will be created
        + resource "oci_core_subnet" "privatesubnet" {
            + availability_domain        = (known after apply)
            + cidr_block                 = "10.0.1.0/24"
            + compartment_id             = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + defined_tags               = (known after apply)
            + dhcp_options_id            = (known after apply)
            + display_name               = "PVsub"
            + dns_label                  = "privatesubnet"
            + freeform_tags              = (known after apply)
            + id                         = (known after apply)
            + ipv6cidr_block             = (known after apply)
            + ipv6public_cidr_block      = (known after apply)
            + ipv6virtual_router_ip      = (known after apply)
            + prohibit_public_ip_on_vnic = true
            + route_table_id             = (known after apply)
            + security_list_ids          = (known after apply)
            + state                      = (known after apply)
            + subnet_domain_name         = (known after apply)
            + time_created               = (known after apply)
            + vcn_id                     = (known after apply)
            + virtual_router_ip          = (known after apply)
            + virtual_router_mac         = (known after apply)
            }

        # oci_core_subnet.publicsubnet will be created
        + resource "oci_core_subnet" "publicsubnet" {
            + availability_domain        = (known after apply)
            + cidr_block                 = "10.0.0.0/24"
            + compartment_id             = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + defined_tags               = (known after apply)
            + dhcp_options_id            = (known after apply)
            + display_name               = "PUBsub"
            + dns_label                  = "publicsubnet"
            + freeform_tags              = (known after apply)
            + id                         = (known after apply)
            + ipv6cidr_block             = (known after apply)
            + ipv6public_cidr_block      = (known after apply)
            + ipv6virtual_router_ip      = (known after apply)
            + prohibit_public_ip_on_vnic = (known after apply)
            + route_table_id             = (known after apply)
            + security_list_ids          = (known after apply)
            + state                      = (known after apply)
            + subnet_domain_name         = (known after apply)
            + time_created               = (known after apply)
            + vcn_id                     = (known after apply)
            + virtual_router_ip          = (known after apply)
            + virtual_router_mac         = (known after apply)
            }

        # oci_core_vcn.test_vcn will be created
        + resource "oci_core_vcn" "test_vcn" {
            + cidr_block               = "10.0.0.0/16"
            + compartment_id           = "ocid1.compartment.oc1..aaaaaaaacd43nqpjqwl2tgg7rq5ysabiyxee6k6yi7q7swk426b5hnflyvpq"
            + default_dhcp_options_id  = (known after apply)
            + default_route_table_id   = (known after apply)
            + default_security_list_id = (known after apply)
            + defined_tags             = (known after apply)
            + display_name             = "VCNHub"
            + dns_label                = "vcn"
            + freeform_tags            = (known after apply)
            + id                       = (known after apply)
            + ipv6cidr_block           = (known after apply)
            + ipv6public_cidr_block    = (known after apply)
            + is_ipv6enabled           = (known after apply)
            + state                    = (known after apply)
            + time_created             = (known after apply)
            + vcn_domain_name          = (known after apply)
            }

        Plan: 8 to add, 0 to change, 0 to destroy.


        Warning: Value for undeclared variable

        The root module does not declare a variable named "management_endpoint" but a
        value was found in file "terraform.tfvars". To use this value, add a
        "variable" block to the configuration.

        Using a variables file to set an undeclared variable is deprecated and will
        become an error in a future release. If you wish to provide certain "global"
        settings to all configurations in your organization, use TF_VAR_...
        environment variables to set these instead.


        Warning: Value for undeclared variable

        The root module does not declare a variable named "vault_id" but a value was
        found in file "terraform.tfvars". To use this value, add a "variable" block to
        the configuration.

        Using a variables file to set an undeclared variable is deprecated and will
        become an error in a future release. If you wish to provide certain "global"
        settings to all configurations in your organization, use TF_VAR_...
        environment variables to set these instead.


        Warning: Value for undeclared variable

        The root module does not declare a variable named "crypto_endpoint" but a
        value was found in file "terraform.tfvars". To use this value, add a
        "variable" block to the configuration.

        Using a variables file to set an undeclared variable is deprecated and will
        become an error in a future release. If you wish to provide certain "global"
        settings to all configurations in your organization, use TF_VAR_...
        environment variables to set these instead.


        Warning: Values for undeclared variables

        In addition to the other similar warnings shown, 2 other variable(s) defined
        without being declared.


        Warning: Interpolation-only expressions are deprecated

        on private_security_list.tf line 2, in resource "oci_core_security_list" "privateSL":
        2:   compartment_id = "${var.compartment_ocid}"

        Terraform 0.11 and earlier required all non-constant expressions to be
        provided via interpolation syntax, but this pattern is now deprecated. To
        silence this warning, remove the "${ sequence from the start and the }"
        sequence from the end of this expression, leaving just the inner expression.

        Template interpolation syntax is still used to construct strings from
        expressions when the template includes multiple interpolation sequences or a
        mixture of literal strings and interpolations. This deprecation applies only
        to templates that consist entirely of a single interpolation sequence.

        (and 31 more similar warnings elsewhere)

        Do you want to perform these actions?
        Terraform will perform the actions described above.
        Only 'yes' will be accepted to approve.

        Enter a value: yes

        oci_core_vcn.test_vcn: Creating...
        oci_core_vcn.test_vcn: Creation complete after 1s [id=ocid1.vcn.oc1.iad.amaaaaaazxsy2naa2yaohdf3ajjg4okh4y3anflzs4kvwhyoz7ah6fsdkkza]
        oci_core_internet_gateway.test_internet_gateway: Creating...
        oci_core_route_table.privateRT: Creating...
        oci_core_security_list.publicSL: Creating...
        oci_core_security_list.privateSL: Creating...
        oci_core_route_table.privateRT: Creation complete after 0s [id=ocid1.routetable.oc1.iad.aaaaaaaafeswabjcsfw3sy7zy2tkwpqq5qg7h3fya4l47ylehh54npl7gelq]
        oci_core_security_list.privateSL: Creation complete after 0s [id=ocid1.securitylist.oc1.iad.aaaaaaaabftl45ssnrk5atpwh2wtsdx5vk555hmmsnkxnoig4zscqjvzz2bq]
        oci_core_subnet.privatesubnet: Creating...
        oci_core_internet_gateway.test_internet_gateway: Creation complete after 0s [id=ocid1.internetgateway.oc1.iad.aaaaaaaagfhsrzihhubmd2ou7ctt4ozkazmce7anoyganabngzzrzyhtvtxq]
        oci_core_route_table.publicRT: Creating...
        oci_core_route_table.publicRT: Creation complete after 0s [id=ocid1.routetable.oc1.iad.aaaaaaaaouzquk67yp7gqp3fxvrhomnosoq7hgil7s6fnkvxu6dqco62smya]
        oci_core_security_list.publicSL: Creation complete after 0s [id=ocid1.securitylist.oc1.iad.aaaaaaaa2oedaqz5i32dpqqlvjbpopo6ydwiy2x6jy7vdtliin2bauqjmtxq]
        oci_core_subnet.publicsubnet: Creating...
        oci_core_subnet.publicsubnet: Creation complete after 1s [id=ocid1.subnet.oc1.iad.aaaaaaaa7l3vzbgyygmtabnindl73zq5bvzl7iqda7kfl5er577ipyqwu5uq]
        oci_core_subnet.privatesubnet: Creation complete after 1s [id=ocid1.subnet.oc1.iad.aaaaaaaasplgluksu7e7oi2svevqjk2dophpmy2ji4pzmjevfdgaao2eddqq]

        Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

You could Check the Cloud portal to know VCN and other resources are created.

Lets move on the next topic Instance creation. At this stage our network resources are setup and security list and route table enteries are defined.

## Instance creation

Instance creation requires Below information.
Availability domain
Shape
Operating System Information
VCN
Subnet

In this workshop lets fix the Shape to VM.Standard2.1 (which has 1 OCPU, 15GB Memory, Block storage as network storage, 1Gbps Network bandwidth and 2 VNIC) and Operting system as Oracle Linux.
During the execution we shall collect details about Availability domain, VCN and Subnet information.




