${cluster_domain}:53 {
    errors
    health {
       lameduck 5s
    }
    ready
    kubernetes ${cluster_domain} in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
    forward . ${join(" ", upstream_dns)}
    cache 30
    loop
    reload
    loadbalance
}

.:53 {
    errors
    health
    ready
    prometheus :9153
    forward . ${join(" ", upstream_dns)}
    cache 30
    loop
    reload
    loadbalance
}
%{ for domain in search_domains ~}

${domain}:53 {
    errors
    forward . ${join(" ", upstream_dns)}
    cache 30
}
%{ endfor ~}
