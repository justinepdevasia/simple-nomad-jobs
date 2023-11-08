job "flower" {
  datacenters = ["dc1"]
  type        = "service"

  group "flower" {
    count = 1
    network {
      mode = "host"
      dns {
        servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
      }
       port "http" {
        to = 5555
      }
    }

    task "flower" {
      driver = "docker"

      config {
        image = "mher/flower:latest"
        ports = [
          "http"
        ]
        command = "celery"
        args = [ "--broker=${BROKER_URL}", "flower","--broker-api=${BROKER_API}" ]
      }

      resources {
        cpu    = 500
        memory = 256 
      }
      template {
        destination = "local/docker.env"
        env         = true
        change_mode = "restart"
        data        = <<EOF
{{ range service "rabbitmqn" }}
BROKER_URL=amqp://guest:guest@{{.Address}}:{{.Port}}//
{{ end }}
{{ range service "rabbitmq-ui" }}
BROKER_API=http://guest:guest@{{.Address}}:{{.Port}}/api/
{{ end }}
EOF
     }

      service {
        name = "flower"
        port = "http"
        provider="consul"
        tags = [ 
          "traefik.enable=true",
          "traefik.http.routers.flowerrouter.rule=Host(`flower.local`)"
          ]
        check {
          name     = "alive"
          type     = "tcp"
          port     = "http"
          address_mode = "driver"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}