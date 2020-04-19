module "ziis" {
  name   = "ziis"
  source = "./kube"
  email      = "b@zi.is"
  nameserver = "10.67.1.2"
  registry   = "10.105.250.202"
}
module "sentry" {
  source   = "./sentry"
  host     = "sentry.zi.is"
  has_kube = module.ziis.has_kube
}
module "ping_img" {
  source   = "./docker_push"
  folder   = "./ping"
  registry = module.ziis.registry
  image    = "ping"
}

module "ping" {
  source = "./simple"
  host   = "ping.zi.is"
  image  = module.ping_img.image
}
module "mta-sts-zi-is_img" {
  source   = "./docker_push"
  folder   = "./mta-sts.zi.is"
  registry = module.ziis.registry
  image    = "mta-sts-zi-is"
}

module "mta-sts-zi-is" {
  source = "./simple"
  host   = "mta-sts.zi.is"
  image  = module.mta-sts-zi-is_img.image
}
module "mta-sts-gmail_img" {
  source   = "./docker_push"
  folder   = "./mta-sts.gmail"
  registry = module.ziis.registry
  image    = "mta-sts-gmail"
}
module "mta-sts-iware-co-uk" {
  source = "./simple"
  host   = "mta-sts.iware.co.uk"
  image  = module.mta-sts-gmail_img.image
}
module "mta-sts-rockpool-net" {
  source = "./simple"
  host   = "mta-sts.rockpool.net"
  image  = module.mta-sts-gmail_img.image
}
