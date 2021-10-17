provider "google" {
  project     = "cloud-run-sandbox-329314"
  region      = "asia-northeast1"
}

resource "google_project_service" "cloudrun" {
  project = "cloud-run-sandbox-329314"
  service = "run.googleapis.com"

  timeouts {
    create = "10m"
    update = "10m"
  }

  disable_dependent_services = true
}

resource "google_cloud_run_service" "default" {
  name     = "hello-cloud-run"
  location = "asia-northeast1"

  depends_on = [
    google_project_service.cloudrun,
  ]

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
