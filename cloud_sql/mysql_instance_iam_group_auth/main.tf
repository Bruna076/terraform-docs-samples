/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# [START cloud_sql_mysql_instance_iam_group_auth_create_instance]
resource "google_sql_database_instance" "default" {
  name             = "mysql-iam-group-auth-instance-name"
  region           = "us-west4"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }
  }
}

# Specify the email address of the Cloud Identity group to add to the instance
# This resource does not create a Cloud Identity group; the group must
# already exist

resource "google_sql_user" "iam_group" {
  name     = "example-group@example.com"
  instance = google_sql_database_instance.default.name
  type     = "CLOUD_IAM_GROUP"
}

# [START cloud_sql_mysql_instance_iam_group_auth_grant_roles]
data "google_project" "project" {
}

resource "google_project_iam_binding" "cloud_sql_user" {
  project = data.google_project.project.project_id
  role    = "roles/cloudsql.instanceUser"
  members = [
    "group:example-group@example.com"
  ]
}
# [END cloud_sql_mysql_instance_iam_group_auth_grant_roles]
# [END cloud_sql_mysql_instance_iam_group_auth_create_instance]
