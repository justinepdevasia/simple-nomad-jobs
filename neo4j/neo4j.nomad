job "neo4j" {
    datacenters = ["dc1"]

    group "neo4j" {
        count = 1
        network {
            mode = "host"
            port "http" {
                to = 7474
            }
            port "bolt" {
                to = 7687
            }
        }

        service {
            name = "neo4j"
            port = "http"
            provider = "nomad"

            tags = [
                "monitoring",
                "traefik.enable=true",
                "traefik.http.routers.neo4j.rule=Host(`neo4j.local`)"
            ]

            check {
                type     = "http"
                port     = "http"
                path     = "/"
                interval = "15s"
                timeout  = "5s"
            }
        }

        task "neo4j" {
            driver = "docker"
            config {
                image = "neo4j:5.15.0-community-bullseye"
                ports = ["http", "bolt"]
            }
            env {
                NEO4J_AUTH="neo4j/password"
            }
            resources {
                cpu = 3000
                memory = 1000
            }
        }
    }
}