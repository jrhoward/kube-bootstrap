variable region {

}

variable zones {

}

variable project_id {

}

variable http_loadbalancing {
    description = "enable the default http loadbalancer config for GKE"
    type = bool
    default = false
}

variable "google_compute_address_type" {
    description = "will IP be private or public address"
    default = "EXTERNAL"
}

variable "preemptable_gke_nodes" {
    type = bool
    default = true
}