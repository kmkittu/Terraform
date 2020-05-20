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