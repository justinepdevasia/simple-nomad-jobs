job "clickhouse-grafana" {
    datacenters = ["dc1"]
    type = "service"
    
    group "clickhouse" {
        count = 1

        network {
            mode = "host"
            port "clickhouse-http" {
                to = 8123
            }
            port "clickhouse-native" {
                to = 9000
            }
        }

        service {
            name = "clickhouse-http"
            port = "clickhouse-http"
            provider = "nomad"
            tags = [
                "traefik.enable=true",
                "traefik.http.routers.code.rule=Host(`clickhouse.local`)",
            ]
        }

        task "code" {
            driver = "docker"
            config {
                image = "clickhouse/clickhouse-server:23.7.4.5"
                volumes = [
                    "/var/run/docker.sock:/var/run/docker.sock"
                ]
                ports = ["clickhouse-http","clickhouse-native"]
                
            }

            env {

            }
            resources {
                cpu = 1000
                memory = 1000
            }
        }
    }

    group "grafana" {
        count = 1

        network {
        mode = "host"

        port "grafana-http" {
            to = 3000
        }
        }

        task "grafana" {
        driver = "docker"

        env {
            GF_LOG_LEVEL          = "DEBUG"
            GF_LOG_MODE           = "console"
            GF_SERVER_HTTP_PORT   = "$${NOMAD_PORT_http}"
            GF_PATHS_PROVISIONING = "/local/grafana/provisioning"
        }

        user = "root"

        config {
            image = "grafana/grafana:9.5.8-ubuntu"
            ports = ["grafana-http"]
        }

        resources {
            cpu    = 256
            memory = 300
        }

        service {
            name = "grafana-web"
            port = "grafana-http"
            provider = "nomad"
            tags = [
                "monitoring",
                "traefik.enable=true",
                "traefik.http.routers.grafana.rule=Host(`grafana.local`)",
            ]
        }
        }
    }


}