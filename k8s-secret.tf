resource "kubernetes_secret" "tasky-secret" {
  metadata {
    name = "tasky-secret"
  }

  data = {
    MONGODB_URI	 = base64encode("mongodb://admin:thisisinsecure@mongodb:27017")
    SECRET_KEY = base64encode("secret123")
  }
}
