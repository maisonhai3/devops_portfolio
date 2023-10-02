# resource "helm_release" "nginx" {
#   name       = "nginx"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "nginx"

#   values = [
#     file("${path.module}/helm_nginx/nginx-values.yaml")
#   ]
# }

resource "helm_release" "jenkins" {
  name       = "jenkins-terraform"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "jenkins"

  values = [
    file("${path.module}/helm_nginx/nginx-values.yaml")
  ]
}

# module jenkins {
#   source  = "terraform-module/release/helm"
#   version = "2.6.0"

#   namespace  = "app-namespace"
#   repository =  "https://charts.helm.sh/stable"

#   app = {
#     name          = "jenkins"
#     version       = "1.5.0"
#     chart         = "jenkins"
#     force_update  = true
#     wait          = false
#     recreate_pods = false
#     deploy        = 1
#   }
#   values = [templatefile("./helm_jenkins/jenkins.yml", {
#     region                = var.region
#     storage               = "4Gi"
#   })]

#   set = [
#     {
#       name  = "labels.kubernetes\\.io/name"
#       value = "jenkins"
#     },
#     {
#       name  = "service.labels.kubernetes\\.io/name"
#       value = "jenkins"
#     },
#   ]

#   set_sensitive = [
#     {
#       path  = "master.adminUser"
#       value = "jenkins"
#     },
#   ]
# }