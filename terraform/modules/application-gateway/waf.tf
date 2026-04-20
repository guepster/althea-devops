# Politique WAF (OWASP CRS 3.2, mode Prevention) rattachée à l'App Gateway v2
resource "azurerm_web_application_firewall_policy" "this" {
  name                = "waf-${var.env}-saas-${var.site}-${var.idx}"
  resource_group_name = var.resource_group_name
  location            = var.location

  policy_settings {
    enabled                     = true
    mode                        = "Prevention" # JAMAIS Detection en PROD
    request_body_check          = true
    file_upload_limit_in_mb     = 25
    max_request_body_size_in_kb = 256
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
      rule_group_override {
        rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
        rule {
          id      = "942130"
          enabled = false # exclusion documentée - cf. ticket SEC-742
          action  = "Log"
        }
      }
    }
    managed_rule_set {
      type    = "Microsoft_BotManagerRuleSet"
      version = "1.0"
    }
  }

  custom_rules {
    name      = "BlockBadBots"
    priority  = 100
    rule_type = "MatchRule"
    action    = "Block"
    match_conditions {
      match_variables {
        variable_name = "RequestHeaders"
        selector      = "User-Agent"
      }
      operator           = "Contains"
      negation_condition = false
      match_values       = ["sqlmap", "nikto", "havij", "fimap", "nessus", "WPScan"]
    }
  }

  custom_rules {
    name                 = "RateLimitPerIP"
    priority             = 200
    rule_type            = "RateLimitRule"
    action               = "Block"
    rate_limit_threshold = 600
    rate_limit_duration  = "OneMin"
    match_conditions {
      match_variables { variable_name = "RemoteAddr" }
      operator           = "IPMatch"
      negation_condition = true # tout sauf IP whitelistées
      match_values       = ["10.0.0.0/8", "172.16.0.0/12"]
    }
  }

  tags = var.tags
}
