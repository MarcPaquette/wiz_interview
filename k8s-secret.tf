resource "kubernetes_secret" "tasky-secret" {
  metadata {
    name = "tasky-secret"
  }

  data = {
    MONGODB_URI	 = "mongodb://mongodb:thisisinsecure@mongodb:27017"
    SECRET_KEY = "secret123"
  }
}
