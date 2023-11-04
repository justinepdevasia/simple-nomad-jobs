job "postgres" {
    datacenters = ["dc1"]
    type = "service"

    group "postgres" {
        count = 1
        
        network {
            mode = "host"
            port "db" { 
                to = 5432 
                static = 5432
            }
            
            dns {
            servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
            }
        }

        task "postgres" {
        driver = "docker"
        config {
            image = "postgres"
            ports = ["db"]
        }
        env {
            POSTGRES_USER="postgres"
            POSTGRES_PASSWORD="postgres"
        }
        logs {
            max_files     = 5
            max_file_size = 15
        }

        resources {
            cpu = 500
            memory = 1024
        }
        }

        service {
            name = "postgres"
            provider = "nomad"
            port = "5432"
        }
        
        restart {
        attempts = 10
        interval = "5m"
        delay = "25s"
        mode = "delay"
        }

    }
}
