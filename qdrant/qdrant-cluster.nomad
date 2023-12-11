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
    group "qdrant-primary" {
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
        port "cluster" {
          to = 6335
        }
      }

      task "qdrant" {
        driver = "docker"
        config {
          image = "qdrant/qdrant:v1.6.1"
          ports = ["qdrant", "cluster"]
          command = "./qdrant"
          args = [
            "--uri", 
            "${NOMAD_HOST_ADDR_cluster}",
          ]
        }
        resources {
          cpu    = 800
          memory = 500
        }
        env {
          QDRANT__CLUSTER__ENABLED=true
        }
        service {
          name = "qdrant-primary"
          port = "cluster"
          provider = "nomad"
        }
      }
    }
    group "qdrant-cluster" {
      count = 2
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
        port "cluster" {
          to = 6335
        }
      }

      task "qdrant" {
        driver = "docker"
        config {
          image = "qdrant/qdrant:v1.6.1"
          ports = ["qdrant", "cluster"]
          command = "./qdrant"
          args = [
            "--bootstrap", 
            "${QDRANT_PRIMARY_ADDRESS}",
            "--uri", 
            "${NOMAD_HOST_ADDR_cluster}",
          ]
        }
        resources {
          cpu    = 800
          memory = 500
        }
        env {
          QDRANT__CLUSTER__ENABLED=true
        }

        template {
          destination = "local/qdrant.env"
          env         = true
          data = <<EOH
          QDRANT_PRIMARY_ADDRESS=http://{{ range nomadService "qdrant-primary" }}{{ .Address }}:{{ .Port }}{{ end }}
          EOH
        }

        service {
          name = "qdrant-cluster"
          port = "qdrant"
          provider = "nomad"
          check {
            name     = "qdrant healthcheck"
            port     = "qdrant"
            type     = "http"
            path     = "/healthz"
            interval = "20s"
            timeout  = "5s"
          }
        }
      }
    }
  }
