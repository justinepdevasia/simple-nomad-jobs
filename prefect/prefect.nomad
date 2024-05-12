job "prefect-server" {
  datacenters = ["dc1"]
  type = "service"

  group "prefect" {

    count = 1

    network {
      port "http" {
        static = 4200
        to = 4200
      }
    }

    task "prefect" {

      driver = "docker"

      config {
        image   = "prefecthq/prefect:2-python3.11"
        command = "prefect"
        args    = ["server", "start"]
        ports = ["http"]
      }

      env {
        PREFECT_SERVER_API_HOST=0.0.0.0
      }

      resources {
        cpu    = 1000
        memory = 1000
      }
    }
  }
}