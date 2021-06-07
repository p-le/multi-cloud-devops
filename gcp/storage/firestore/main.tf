resource "google_service_account" "firestore_sa" {
    account_id   = "firestore-sa"
    display_name = "Firestore Service Account"
}

resource "google_project_iam_member" "firestore_owner" {
    role    = "roles/datastore.owner"
    member  = "serviceAccount:${google_service_account.firestore_sa.email}"
}
