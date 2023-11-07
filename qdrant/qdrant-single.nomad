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
  group "qdrant" {
    count = 1
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
        ports = ["qdrant"]
      }
      resources {
        cpu    = 1024
        memory = 1024
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