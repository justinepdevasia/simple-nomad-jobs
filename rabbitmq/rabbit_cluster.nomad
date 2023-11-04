job "rabbit-mq" {

  datacenters = ["dc1"]
  type = "service"
  namespace = "applications"

  group "cluster" {
    count = 3

    update {
      max_parallel = 1
    }

    migrate {
      max_parallel = 1
      health_check = "checks"
      min_healthy_time = "5s"
      healthy_deadline = "30s"
    }

    network {
        port "ui" {  static = 15672 }
        port "amqp" { static = 5672 }
        port "epmd" { static = 4369 }
        port "clustering" { static = 25672 }
    }


    task "rabbit" {
      driver = "docker"

      config {
        image = "justinepdevasia/rabbitmq:3.11.11-management-consul"
        hostname = "${attr.unique.hostname}"
        ports = ["ui", "amqp", "epmd", "clustering" ]
      }

      resources {
        cpu    = 500 # Mhz
        memory = 500 # MB
      }

      env {
        RABBITMQ_ERLANG_COOKIE = "569a12ad-813f-4b34-a40a-a8b5946dec8c"
        RABBITMQ_DEFAULT_USER = "guest"
        RABBITMQ_DEFAULT_PASS = "guest"
        CONSUL_HOST = "172.17.0.1"
      }

      service {
        name = "rabbitmq-ui"
        port = "ui"
        provider = "consul"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      service {
        name = "rabbitmq"
        port = "amqp"
        provider = "consul"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

    }
  }
}
