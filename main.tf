provider "google" {
  project = "kheopsys-lab"
  region  = "us-central1"
  zone    = "us-central1-a"
}


resource "google_project_service" "kubernetes_engine" {
  project = "kheopsys-lab"
  service = "container.googleapis.com"

  disable_on_destroy = false
}

resource "google_service_account" "default" {
  account_id   = "kheopsys-data-lab"
  display_name = "Service Account"
}

resource "google_container_cluster" "primary" {
  name     = "kuber-global-infra"
  location = "us-central1"
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "airflow_namespace2" {
  metadata {
    name = "airflow"
  }
}


resource "kubernetes_deployment" "airflow_deployment2" {
  metadata {
    name      = "airflow"
    namespace = kubernetes_namespace.airflow_namespace2.metadata[0].name
    labels = {
      app = "airflow"
    }
  }
  spec {

  
    replicas = 1

    selector {
      match_labels = {
        app = "airflow"
      }
    }

    template {
      metadata {
        labels = {
          app = "airflow"
        }
      }

      spec {
        container {
          image = "apache/airflow:latest" 
          name  = "airflow"

          env {
            name  = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
            value = "mysql://Airflow-dbb-user:password@35.232.232.61:3306/airflow_database"  

          }
         
/*
          env {
            name  = "AIRFLOW__CORE__EXECUTOR"
            value = "KubernetesExecutor"
          }

*/         
	
        }
        #restart_policy = "OnFailure"
      }
    }
  }
}




resource "kubernetes_service" "airflow_service" {
  metadata {
    name      = "airflow"
    namespace = kubernetes_namespace.airflow_namespace2.metadata[0].name
  }
  spec {
    selector = {
      app = "airflow"
    }
    session_affinity = "ClientIP"
    port {
      port        = 8080
      target_port = 8080
    }
    type = "LoadBalancer"  
  }
}









