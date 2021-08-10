module "ldap-storage" {
  source      = "./modules/buckets"
  project     = var.project
  region      = var.region
  bucket-name = "${var.project}-ldap-bucket"
  role-bucket = "roles/storage.objectAdmin"
}

module "ldap-server" {
  source  = "./modules/instances"
  project = var.project
  name    = "ldap-server"
  network = "default"
  service-account-email = module.ldap-storage.service-account-email
  startup-script = "mkdir /resources && cd /resources ; gsutil cp -r ${module.ldap-storage.bucket-url}/resources/* . ; sudo chmod 744 server.sh; sudo ./server.sh"
}

module "ldap-client" {
  source  = "./modules/instances"
  project = var.project
  name    = "ldap-client"
  network = "default"
  service-account-email = module.ldap-storage.service-account-email
  startup-script = "mkdir -p /resources && cd /resources; gsutil cp -r ${module.ldap-storage.bucket-url}/resources/* . ; sudo chmod 744 client.sh; sudo ./client.sh""
}