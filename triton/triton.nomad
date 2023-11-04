job "tritonserver2" {
  datacenters = ["dc1"]

  group "tritongroup" {
    count = 1

    network {
      dns {
        servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
      }

      port "webapi" {
        to = 8000
      }
      port "rpc" {
        to = 8001
      }
      port "port2" {
        to = 8002
      }


    }

    task "tritontask" {
      driver = "docker"

      config {
        image = "nvcr.io/nvidia/tritonserver:22.12-py3"
        ports = ["webapi", "rpc", "port2"]
        volumes = ["/local/triton/server-main/docs/examples/model_repository/densenet_onnx:/models"]
        command = "tritonserver"
        args = [
          "--model-repository=/models",
          "--model-control-mode=poll",
          "--repository-poll-secs=30"
        ]
      }

      resources {
        cpu = 2000  # 2000 MHz (2 cores)
        memory = 4096  # 4096 MB (4 GB)
        device "nvidia/gpu" {
          count = 1
        }
      }

      service {
        name = "triton-server"
        port = "webapi"

        check {
          name     = "HTTP"
          type     = "http"
          path     = "/v2/health/ready"
          interval = "10s"
          timeout  = "2s"
        }
      }

      artifact {
        source = "https://github.com/triton-inference-server/server/archive/main.tar.gz"
        destination = "/local/triton"
      }
    }
  }
}
