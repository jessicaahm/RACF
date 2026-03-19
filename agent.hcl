pid_file = "./pidfile"

log_file = "/var/log/vault-agent.log"

vault {
  address = "http://172.17.0.2:8200"
  retry {
    num_retries = 5
  }
}

auto_auth {
  method {
    type = "token_file"

    config = {
      token_file_path = "/etc/.vault-token"
    }
  }

  sinks {
    sink {
      type = "file"

      config = {
        path = "/tmp/TOKEN"
      }
    }
  }
}

cache {
  // An empty cache stanza still enables caching
}

template_config {
  lease_renewal_threshold = 0.7
  exit_on_retry_failure = true
  max_connections_per_host = 20
}

env_template "PASSWORD" {
  contents             = "{{ with secret \"ldapui/static-cred/hashicorp\" }}{{ .Data.password }}{{ end }}"
  error_on_missing_key = true
}

exec {
  command                   = ["/etc/vault/exec.sh"]
  restart_on_secret_changes = "always"
  restart_stop_signal       = "SIGTERM"
}