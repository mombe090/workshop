# Shared, non-secret bootstrap inputs. Values unique to an environment belong
# in <env>.tfvars; Talos / Kubernetes versions are pinned as locals in main.tf.

domain = "docker.io"
registry_username = "replaceme"
registry_password = "replaceme"
