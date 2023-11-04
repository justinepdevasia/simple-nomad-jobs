job "spark" {
    datacenters = ["dc1"]
    type = "service"
    group "spark-master" {
        count = 1

        network {
            mode = "host"
            port "spark" {
                to = 7077
            }
            port "web" {
                to = 8080
            }
        }

        service {
            name = "sparkui"
            port = "web"
            tags = [
                "traefik.enable=true",
                "traefik.http.routers.sparkui.rule=Host(`sparkui.local.anytypecompute.com`)",
            ]
        }

        service {
            name = "spark"
            port = "spark"
        }

        task "spark-master" {
            driver = "docker"
            config {
                image = "docker.io/bitnami/spark:3.4"
                volumes = [
                    "/var/run/docker.sock:/var/run/docker.sock"
                ]
                ports = ["spark", "web"]
            }

            env {
                SPARK_MODE = "master"
                SPARK_RPC_AUTHENTICATION_ENABLED = "no"
                SPARK_RPC_ENCRYPTION_ENABLED = "no"
                SPARK_LOCAL_STORAGE_ENCRYPTION_ENABLED = "no"
                SPARK_SSL_ENABLED = "no"
                SPARK_USER = "spark"

            }
            resources {
                cpu = 1000
                memory = 1000
            }
        }
    }

    group "spark-workers" {
        count = 1

        network {
            mode = "host"
        }

        task "spark-worker" {
            driver = "docker"
            config {
                image = "docker.io/bitnami/spark:3.4"
                volumes = [
                "/var/run/docker.sock:/var/run/docker.sock"
                ]
            }
            env {
                SPARK_MODE = "worker"
                SPARK_RPC_ENCRYPTION_ENABLED = "no"
                SPARK_LOCAL_STORAGE_ENCRYPTION_ENABLED = "no"
                SPARK_SSL_ENABLED = "no"
                SPARK_USER = "spark"
            }

            resources {
                cpu = 1000
                memory = 1000
            }

            template {
                destination = "local/spark.env"
                env         = true
                data = <<EOH
                SPARK_MASTER_URL={{ range service "spark" }}{{ .Address }}:{{ .Port }}{{ end }}
                EOH
            }
        }

    }

    group "beam_spark_job_server" {
        count = 1

        network {
            mode = "host"
            port "job_server" {
                to = 8099
            }
        }

        task "beam" {
            driver = "docker"
            config {
                image = "apache/beam_spark_job_server"
                volumes = [ 
                "/var/run/docker.sock:/var/run/docker.sock"
                ]
                args = [
                    "--spark-master-url=spark://${SPARK_MASTER_URL}",
                    "--job-host=0.0.0.0"
                ]
                ports = ["job_server"]
            }

            resources {
                cpu = 1000
                memory = 1000
            }

            template {
                destination = "local/spark.env"
                env         = true
                data = <<EOH
                SPARK_MASTER_URL={{ range service "spark" }}{{ .Address }}:{{ .Port }}{{ end }}
                EOH
            }
        }

    }
}