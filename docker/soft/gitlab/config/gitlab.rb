gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "13037125104@163.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "13037125104@163.com"
gitlab_rails['smtp_password'] = "193427a"
gitlab_rails['smtp_domain'] = "163.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = true

gitlab_rails['gitlab_email_from'] = "13037125104@163.com"
user["git_user_email"] = "13037125104@163.com"

external_url "http://192.168.50.58"