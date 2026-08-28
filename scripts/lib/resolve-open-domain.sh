#!/usr/bin/env bash
# Resolve Feishu/Lark Open Platform API domain (NOT the marketing site feishu.cn).
# Usage: OPEN_DOMAIN="$(resolve_lark_open_domain)"
resolve_lark_open_domain() {
  local domain="${LARK_OPEN_DOMAIN:-}"

  if [[ -z "$domain" ]]; then
    case "${FEISHU_DOMAIN:-feishu.cn}" in
      larksuite.com | open.larksuite.com)
        domain="https://open.larksuite.com"
        ;;
      feishu.cn | open.feishu.cn | *)
        domain="https://open.feishu.cn"
        ;;
    esac
  fi

  if [[ "$domain" != http* ]]; then
    domain="https://${domain}"
  fi

  # Guard against using marketing site as API host
  domain="${domain//https:\/\/feishu.cn/https://open.feishu.cn}"
  domain="${domain//https:\/\/larksuite.com/https://open.larksuite.com}"

  echo "${domain%/}"
}
