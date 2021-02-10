region     = "us"
datacenter = "dc1"
data_dir   = "/var/lib/nomad"
bind_addr  = "{{ GetInterfaceIP \"eth1\" }}"

addresses {
  http = "0.0.0.0"
}

advertise {
  http = "{{ GetInterfaceIP \"eth1\" }}"
}

telemetry {
  disable_hostname = true
  prometheus_metrics = true
  collection_interval = "1s"
  publish_node_metrics = true
  publish_allocation_metrics = true
}

server {
  bootstrap_expect = 1
  enabled          = true
}

acl {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}

client { enabled = false }

plugin "raw_exec" {
  config {
    enabled = true
  }
}