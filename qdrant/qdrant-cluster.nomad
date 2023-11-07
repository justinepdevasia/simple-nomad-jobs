job "qdrant" {
  datacenters = ["dc1"]
  type        = "service"
  update {
    max_parallel      = 1
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "3m"
    progress_deadline = "5m"
  }
  group "qdrant-cluster" {
    count = 3
    restart {
      attempts = 3
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }
    network {
      mode = "host"
      port "qdrant" {
        to = 6333 
      }
    }

    task "qdrant" {
      driver = "docker"
      config {
        image = "qdrant/qdrant:v1.6.1"
        args = [
          "-config.file",
          "local/config.yml",
        ]
        ports = ["qdrant"]
      }
      template {
        data        = file(abspath("./configs/config.tpl.yml"))
        destination = "local/config.yml"
        change_mode = "restart"
      }
      resources {
        cpu    = 800
        memory = 500
      }
      service {
        name = "qdrant"
        port = "qdrant"
        check {
          name     = "qdrant healthcheck"
          port     = "qdrant"
          type     = "http"
          path     = "/ready"
          interval = "20s"
          timeout  = "5s"
          check_restart {
            limit           = 3
            grace           = "60s"
            ignore_warnings = false
          }
        }
      }
    }
  }
}