data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}

resource "kubernetes_deployment_v1" "default" {
  metadata {
    name = "tasky-deployment"
  }

  spec {
    selector {
      match_labels = {
        app = "tasky-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "tasky-app"
        }
      }

      spec {
        container {
          image = "us-central1-docker.pkg.dev/clgcporg10-154/wizzardcloset/tasky:v1"
          name  = "tasky"

          env {
            name = "MONGODB_URI"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.tasky-secret.metadata[0].name
                key  = "MONGODB_URI"
              }
            }
          }

          env {
            name = "SECRET_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.tasky-secret.metadata[0].name
                key  = "SECRET_KEY"
              }
            }
          }

          port {
            container_port = 8080
            name           = "tasky-app-svc"
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false

            capabilities {
              add  = []
              drop = ["NET_RAW"]
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "tasky-app-svc"

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }

        service_account_name =  "tasky-service"
        security_context {
          run_as_non_root = true

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        # Toleration is currently required to prevent perpetual diff:
        # https://github.com/hashicorp/terraform-provider-kubernetes/pull/2380
        toleration {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "amd64"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "default" {
  metadata {
    name = "example-tasky-app-loadbalancer"
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.default.spec[0].selector[0].match_labels.app
    }


    port {
      port        = 80
      target_port = kubernetes_deployment_v1.default.spec[0].template[0].spec[0].container[0].port[0].name
    }

    type = "LoadBalancer"
  }

  depends_on = [time_sleep.wait_service_cleanup]
}

# Provide time for Service cleanup
resource "time_sleep" "wait_service_cleanup" {
  depends_on = [google_container_cluster.primary]

  destroy_duration = "180s"
}


resource "kubernetes_network_policy_v1" "tasky-egress" {
  metadata {
    name      = "tasky-network-policy"
    namespace = "default"
  }

  spec {
    pod_selector {
      match_expressions {
        key      = "app"
        operator = "In"
        values   = ["tasky-app"]
      }
    }

    ingress {
      ports {
        port     = "http"
        protocol = "TCP"
      }
    }

    egress {
      ports {
        port     = "27017"
        protocol = "TCP"
      }

    }

    policy_types = ["Ingress", "Egress"]
  }
}
