resource "helm_release" "elasticsearch" {
  depends_on = ["kubernetes_cluster_role_binding.tiller"]
  name       = "elasticsearch"
  namespace  = "logging"
  chart      = "stable/elasticsearch"
}

resource "helm_release" "fluentd-elasticsearch" {
  depends_on = ["kubernetes_cluster_role_binding.tiller"]
  name       = "fluentd-elasticsearch"
  namespace  = "logging"
  chart      = "stable/fluentd-elasticsearch"

  values = [<<EOF
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "24231"
EOF
  ]
}

resource "helm_release" "kibana" {
  depends_on = ["kubernetes_cluster_role_binding.tiller"]
  name       = "kibana"
  namespace  = "logging"
  chart      = "stable/kibana"

  values = [<<EOF
env:
  ELASTICSEARCH_URL: http://elasticsearch-client:9200
EOF
  ]
}
