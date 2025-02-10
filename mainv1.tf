# Creamos provider del K3s
provider "kubernetes" {
  config_path = "./terraform-provider/k3s.config" 
}


# Namespace
resource "kubernetes_namespace" "app_ns" {
  metadata {
    name = "server-stats-space"
  }
}


# CONFIG MAP

resource "kubernetes_config_map" "script_config" {
   metadata {
    name      = "script-config"
    namespace = "server-stats-space"
  }

  data = {
    "server-stats.sh" =  file("${path.module}/server-stats.sh")
  }
}


# PERSISTENT VOLUMES


resource "kubernetes_persistent_volume" "output_pv" {
  metadata {
    name = "output-imput-pv"
  }

  spec {
    capacity = {
      storage = "1Gi"
    }

    access_modes = ["ReadWriteMany"]

    persistent_volume_source {
      host_path {
        path = "/mnt/data/output"
      }
    }
    storage_class_name = "local-path" 
  }
}

resource "kubernetes_persistent_volume_claim" "output_pvc" {
  metadata {
    name = "output-imput-pvc"
    namespace = "server-stats-space"
  }

  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.output_pv.metadata[0].name
  }
}



#  SERVER

resource "kubernetes_deployment_v1" "script_server" {
  metadata {
    name = "script-server"
    namespace = "server-stats-space"
    labels = {
      app = "script-server"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "script-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "script-server"
        }
      }

      spec {
        container {
          name  = "script-container"
          image = "ubuntu:latest"

          command = ["/bin/sh", "-c"]
          args = [
            "ls && cp /shared/server-stats.sh ./script.sh&& ls && chmod +x ./script.sh && ls -l && sh script.sh %% && cat /output/stats.html"
          ]

          # Montar el ConfigMap en /scripts
          volume_mount {
            name       = "script-volume-archivo"
            mount_path = "/shared"
          }

           volume_mount {
            name       = "script-volume-output"
            mount_path = "/output"
          }

        }

        volume {
          name = "script-volume-archivo"
          config_map {
            name = kubernetes_config_map.script_config.metadata[0].name
          }
          
        }
        volume {
          name= "script-volume-output"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.output_pvc.metadata[0].name
          }
        }  

      }
    }
  }
}




# NGINX 

resource "kubernetes_deployment_v1" "web_server" {
  metadata {
    name = "web-server"
    namespace = "server-stats-space"
    labels = {
      app = "web-server"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "web-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "web-server"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          volume_mount {
            name       = "output-volume"
            mount_path = "/usr/share/nginx/html"
          }
        }

        volume {
          name = "output-volume"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.output_pvc.metadata[0].name
          }
        }
      }
    }
  }
}



#  SERVICE 

resource "kubernetes_service" "web_service" {
  metadata {
    name = "web-service"
    namespace = "server-stats-space"
  }

  spec {
    selector = {
      app = "web-server"
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}

#  INGRESS

resource "kubernetes_ingress_v1" "web_ingress" {
  metadata {
    name = "web-ingress"
    namespace = "server-stats-space"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      host = "script.local"   # http://script.local/stats.html.
      http {
        path {
          path = "/"
          backend {
            service {
              name = "web-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}