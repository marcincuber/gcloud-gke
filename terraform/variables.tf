variable "project" {
  description = "The name of the project in which to create the Kubernetes cluster."
  type        = "string"
  # default     = "marcincuber"
}

variable "region" {
  description = "The region in which to create the Kubernetes cluster."
  type        = "string"
  default     = "europe-west2"
}

variable "zones" {
  type    = "list"
  default = ["europe-west2-a", "europe-west2-b", "europe-west2-c"]
}

variable "cluster_name" {
  description = "The name to give the new Kubernetes cluster."
  type        = "string"
  default     = "k8s"
}

variable "environment" {
  description = "The environment name for cluster."
  type        = "string"
  default     = "test"
}

variable "initial_node_count" {
  description = "The number of nodes initially provisioned in the cluster"
  type        = "string"
  default     = "1"
}

variable "name" {
  default = "priv-pub-subs-test"
}

variable "private_subnet_name" {
  default = "private"
}

variable "private_subnet_ip_range" {
  default = "10.60.10.0/24"
}

variable "public_subnet_name" {
  default = "public"
}

variable "public_subnet_ip_range" {
  default = "10.60.1.0/24"
}

variable "enable_flow_logs_pub" {
  default = "true"
}

variable "enable_flow_logs_priv" {
  default = "true"
}

variable "enable_private_ip_google_access_pub" {
  default = "true"
}

variable "enable_private_ip_google_access_priv" {
  default = "true"
}

variable "bastion_image" {
  default = "ubuntu-1804-bionic-v20181024"
}

variable "bastion_instance_type" {
  default = "f1-micro"
}

variable "master_ipv4_cidr_block" {
  default = "10.70.0.0/28"
}

variable "pod_cidr_range_pub" {
  default = "10.82.0.0/15"
}

variable "service_cidr_range_pub" {
  default = "10.80.0.0/15"
}

variable "pod_cidr_range_priv" {
  default = "10.92.0.0/15"
}

variable "service_cidr_range_priv" {
  default = "10.90.0.0/15"
}
