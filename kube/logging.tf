resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
}

resource "helm_release" "elasticsearch" {
  name      = "elasticsearch"
  namespace = kubernetes_namespace.logging.metadata.0.name

  chart      = "elasticsearch"
  repository = "https://helm.elastic.co"
  version    = "7.15.0"

  values = [<<EOF
antiAffinity: soft
EOF
  ]
}

resource "helm_release" "logstash" {
  name       = "logstash"
  namespace  = kubernetes_namespace.logging.metadata.0.name
  chart      = "logstash"
  repository = "https://helm.elastic.co"
  version    = "7.15.0"

  values = [<<EOF
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "24231"
EOF
  ]
}

resource "helm_release" "kibana" {
  name       = "kibana"
  namespace  = kubernetes_namespace.logging.metadata.0.name
  chart      = "kibana"
  repository = "https://helm.elastic.co"
  version    = "7.15.0"

  values = [<<EOF
env:
  ELASTICSEARCH_URL: http://elasticsearch-client:9200
EOF
  ]
}
