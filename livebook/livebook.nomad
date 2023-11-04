job "dev-setup" {
    datacenters = ["dc1"]
    type = "service"
    group "livebook" {
        count = 1

        network {
            mode = "host"
            port "port1" {
                to = 8080
            }
            port "port2" {
                to = 8081
            }
            dns {
                servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
            }
        }

        service {
            name = "code"
            port = "3000"
            provider = "nomad"
            tags = [
                "traefik.enable=true",
                "traefik.consulcatalog.connect=true",
                "traefik.http.routers.livebook.rule=Host(`livebook.local`)",
            ]
        }

        task "code" {
            driver = "docker"
            config {
                image = "ghcr.io/livebook-dev/livebook:nomad"
                volumes = [
                    "/var/run/docker.sock:/var/run/docker.sock"
                ]
                ports = ["port1", "port2"]
            }

            env {
                LIVEBOOK_PASSWORD="livebook1234"

            }
            resources {
                cpu = 1000
                memory = 1000
            }
        }
    }
}