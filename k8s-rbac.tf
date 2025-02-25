resource "kubernetes_service_account" "tasky_service" {
  metadata {
    name = "tasky-service"
  }
}

resource "kubernetes_role_binding" "tasky_role_binding" {
  metadata {
    name      = "tasky_role_binding"
    namespace = "default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tasky-service" 
    namespace = "default"
  }
}
