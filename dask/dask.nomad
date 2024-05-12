job "dask" {
  datacenters = ["dc1"]
  type = "service"

  group "dask-scheduler" {

    count = 1

    network {
      mode = "host"
      port "dashboard" {
        to = 8787
      }
      port "tcp" {
        to = 8786
      }
    }

    task "dask" {

      driver = "docker"

      config {
        image   = "ghcr.io/dask/dask"
        command = "dask-scheduler"
        ports = ["dashboard", "tcp"]
      }


      resources {
        cpu    = 1000
        memory = 1000
      }
    }

    service {
      name = "dask-scheduler"
      port = "tcp"
      provider = "nomad"
    }
  }

  group "dask-workers" {

    count = 1

    network {
      mode = "host"
      port "http" {
        to = 8786
      }
    }

    task "dask-worker" {

      driver = "docker"

      config {
        image   = "ghcr.io/dask/dask"
        command = "dask-worker"
        args    = ["tcp://${DASK_SCHEDULER_URL}"]
        ports = ["http"]
      }

      template {
        destination = "local/dask.env"
        env         = true
        data = <<EOH
        DASK_SCHEDULER_URL={{ range nomadService "dask-scheduler" }}{{ .Address }}:{{ .Port }}{{ end }}
        EOH
      }

      resources {
        cpu    = 1000
        memory = 1000
      }
    }
  }
}