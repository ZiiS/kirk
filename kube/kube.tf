module "init" {
  source = "./init"
  name   = var.name
}

resource "kubernetes_namespace" "tiller" {
  metadata {
    name = "tiller"
  }
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = kubernetes_namespace.tiller.metadata.0.name
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tiller.metadata.0.name
    namespace = kubernetes_service_account.tiller.metadata.0.namespace
  }
}
