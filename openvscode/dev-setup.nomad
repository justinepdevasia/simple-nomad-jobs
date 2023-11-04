job "dev-setup" {
    datacenters = ["dc1"]
    type = "service"

    group "postgres" {
        count = 1
        
        network {
            mode = "bridge"
            port "db" { 
                to = 5432 
            }
            
            dns {
            servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
            }
        }

        task "postgres" {
        driver = "docker"
        config {
            image = "postgres"
        }
        env {
            POSTGRES_USER="devatc"
            POSTGRES_PASSWORD="GsNtyFa4^nHBP7$rjR"
        }
        logs {
            max_files     = 5
            max_file_size = 15
        }

        resources {
            cpu = 256
            memory = 1024
        }
        }

        service {
            name = "dev-postgres"
            provider = "consul"
            port = "5432"
            connect {
                sidecar_service {}
            }
        }
        
        restart {
        attempts = 10
        interval = "5m"
        delay = "25s"
        mode = "delay"
        }

    }
    group "rabbitmq" {
        count = 1

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
        mode = "bridge"
          port "ui" {
              to = 15672 
          } 
          port "amqp" { 
              to = 5672 
          }
          
          dns {
          servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
        }
      }


      task "rabbitmq" {
        driver = "docker"

        config {
          image = "rabbitmq:3.11-management"
          ports = ["ui", "amqp"]
        }

        resources {
          cpu    = 512 # Mhz
          memory = 512 # MB
        }
      }

      service {
          name = "dev-rabbitmq"
          port = "5672"
          provider = "consul"
          connect {
                sidecar_service {}
            }
        }

        service {
          name = "dev-rabbitmq-ui"
          port = "15672"
          provider = "consul"
          connect {
                sidecar_service {}
            }
        }
    }
    group "redis" {
        count = 1

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
            mode = "bridge" 
            dns {
                servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
            }
            port "dev-redis" {  to = 6379 } 
        }

        task "redis" {
            driver = "docker"

            config {
                image = "redis:7.0.8"
                ports = [
                    "redis_port"
                ]
            }

            resources {
                cpu    = 512 # Mhz
                memory = 512 # MB
            }

        }

        service {
            name = "dev-redis"
            port = "6379"
            provider = "consul"
            connect {
                sidecar_service {}
            }
        }
    }
    group "vscode" {
        count = 1

        network {
            mode = "bridge"
            port "code" {
                to = 3000
            }
            dns {
                servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
            }
        }

        service {
            name = "code"
            port = "3000"
            provider = "consul"
            tags = [
                "traefik.enable=true",
                "traefik.consulcatalog.connect=true",
                "traefik.http.routers.vscode.rule=Host(`code.local`)",
            ]
            connect {
                sidecar_service {
                    proxy {
                        upstreams {
                            destination_name = "dev-rabbitmq"
                            local_bind_port  = 5672
                        }
                        upstreams {
                            destination_name = "dev-rabbitmq-ui"
                            local_bind_port  = 15672
                        }
                        upstreams {
                            destination_name = "dev-redis"
                            local_bind_port  = 6379
                        }
                        upstreams {
                            destination_name = "dev-postgres"
                            local_bind_port  = 5432
                        }
                    }
                }
            }
        }

        task "code" {
            driver = "docker"
            config {
                image = "vscode:1"
                volumes = [
                    "/var/run/docker.sock:/var/run/docker.sock"
                ]
                ports = ["code"]
                args = [
                    "--without-connection-token",
                    "false",
                    "--connection-token",
                    "${CODE_TOKEN}",
                    "--host",
                    "0.0.0.0",
                ]
            }

            env {
                CODE_TOKEN = "anything"

            }
            resources {
                cpu = 1000
                memory = 1000
            }
        }
    }
}
