# Terraform #
# Introduction #
Welcome to Hands on Workshop! Are you bored with managing things with Cloud portal? Are you bored with clicking icons in Cloud portal to create resources and looking for some change for managing Cloud resources? Then it is the workshop you should must try. It will give you some different kind of work style for handling Cloud Resources. 
In this workshop we will not going to touch web portal, instead we learn and manage all the Cloud resources through Code, i.e Infrastructure As the Code. We are going to create resource through Terraform script. We could discuss in detail about Terraform scripting for each Cloud resource and also we shall experience of creating an Instance in OCI with all dependent resources through Terraform.
##  Steps
1)	Creation of Network Resources
2)	Creation of Security Resources
3)	Creation of Instance (Linux & Windows)

Before proceeding to resources creation, we need to specify OCI credentials for terraform to login.
The credentials can be specified in terraform.tfvars file. The basic credentials required are User OCID, Tenancy OCID, fingerprint, compartment OCID, region and Private key. 
First create a folder to store Terraform scripts.
Create terraform.tfvars with below details in that folder.
#tenancy and user information
tenancy_ocid = <Tenancy OCID>
user_ocid = <User OCID>
fingerprint= <FinerPrint value>
private_key_path = <Private key file with location>


### Tenancy OCID 
Open the Profile menu (User menu icon)  and click Tenancy: <your_tenancy_name>.
The tenancy OCID is shown under Tenancy Information. Click Copy to copy it to your clipboard.
<picture>
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

Generate Public key using the private key through openssl command.

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

## Network Resources
Creation of VCN
Creation of Gateways

### VCN
  Virutal cloud network is the first cloud resource to be created. VCN has all the network related resources. While creating VCN, we could also create its components subnet and gateways

Create a file in the name of VCN.tf and copy the below contents.

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

Init the Terraform to the current directory

        #Terraform init

Execute the Terraform plan to verify everything fine 

        #Terraform plan

Plan is almost like an execution. It collects inputs from user and cross checks whether the execution will go smoother. If there are errors in plan execution, we need to address that. Else we are good to proceed apply

        #Terraform apply

Apply will connect OCI and create the VCN and asociated resources.