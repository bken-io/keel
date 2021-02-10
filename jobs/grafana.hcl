# Borrowed from
# https://github.com/burdandrei/nomad-monitoring
 
job "grafana" {
  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  update {
    stagger = "30s"
    max_parallel = 1
  }

  group "grafana" {
    restart {
      attempts = 10
      interval = "5m"
      delay = "10s"
      mode = "delay"
    }

    task "grafana" {
      driver = "docker"
      config {
        image = "grafana/grafana"
      }

      env {
        GF_LOG_LEVEL = "DEBUG"
        GF_LOG_MODE = "console"
        GF_SERVER_HTTP_PORT = "${NOMAD_PORT_http}"
        GF_PATHS_PROVISIONING = "/local/provisioning"
        GF_SERVER_ROOT_URL="/grafana/"
      }

      artifact {
        source      = "https://github.com/bkenio/keel/grafana/provisioning/dashboards"
        destination = "local/dashboards/"
      }

      artifact {
        source      = "github.com/burdandrei/nomad-monitoring/examples/grafana/provisioning"
        destination = "local/provisioning/"
      }

      resources {
        cpu    = 50
        memory = 100
        network {
          mbits = 10
          port "http" {}
        }
      }

      service {
        name = "grafana"
        port = "http"
        tags = ["urlprefix-/grafana/ strip=/grafana"]

        check {
          name     = "Grafana HTTP"
          type     = "http"
          path     = "/api/health"
          interval = "5s"
          timeout  = "2s"
           check_restart {
            limit = 2
            grace = "60s"
            ignore_warnings = false
          }
        }
      }
    }
  }
}