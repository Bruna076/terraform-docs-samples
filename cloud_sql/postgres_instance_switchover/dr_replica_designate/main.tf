/**
 * Copyright 2025 Google LLC
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

# [START cloud_sql_postgres_instance_switchover_dr_replica_designate]
data "google_project" "default" {
}

resource "google_sql_database_instance" "original-primary" {
  name             = "postgres-original-primary-instance"
  region           = "us-east1"
  database_version = "POSTGRES_12"
  instance_type    = "CLOUD_SQL_INSTANCE"

  replication_cluster {
    # Designate the DR replica.
    # The format for setting the DR replica is `project-id:dr-replica-name`.
    failover_dr_replica_name = "${data.google_project.default.project_id}:postgres-dr-replica-instance"
  }

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }
  }
  # Set `deletion_protection` to true to ensure that one can't accidentally
  # delete this instance by use of Terraform whereas
  # `deletion_protection_enabled` flag protects this instance at the Google Cloud level.
  deletion_protection = false
  # Optional. Add more settings.
}

resource "google_sql_database_instance" "dr-replica" {
  name                 = "postgres-dr-replica-instance"
  region               = "us-west2"
  database_version     = "POSTGRES_12"
  instance_type        = "READ_REPLICA_INSTANCE"
  master_instance_name = google_sql_database_instance.original-primary.name

  settings {
    tier    = "db-perf-optimized-N-2"
    edition = "ENTERPRISE_PLUS"
  }

  # Set `deletion_protection` to true to ensure that one can't accidentally
  # delete this instance by use of Terraform whereas
  # `deletion_protection_enabled` flag protects this instance at the Google Cloud level.
  deletion_protection = false
  # Optional. Add more settings.
}

# [END cloud_sql_postgres_instance_switchover_dr_replica_designate]
