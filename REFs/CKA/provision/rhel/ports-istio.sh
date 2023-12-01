
## Istio ports : 150NN : https://istio.io/latest/docs/ops/deployment/requirements/
## firewall-cmd is interface to firewalld

[[ $(systemctl is-active firewalld.service) == 'active' ]] || sudo systemctl enable --now firewalld.service

## @ Worker nodes
# Istio sidecar proxy (Envoy)
sudo firewall-cmd --permanent --add-port=15001/tcp      # Istio Envoy outbound
sudo firewall-cmd --permanent --add-port=15006/tcp      # Istio Envoy inbound
sudo firewall-cmd --permanent --add-port=15008/h2       # Istio HBONE mTLS tunnel
sudo firewall-cmd --permanent --add-port=15009/h2c      # Istio HBONE secure networks
sudo firewall-cmd --permanent --add-port=15020/http     # Istio telemetry (merged)
sudo firewall-cmd --permanent --add-port=15021/http     # Istio Health checks
sudo firewall-cmd --permanent --add-port=15090/http     # Istio telemetry (Envoy)


## @ Control Plane nodes
# Istio sidecar proxy (Envoy)
sudo firewall-cmd --permanent --add-port=15001/tcp      # Istio Envoy outbound
sudo firewall-cmd --permanent --add-port=15006/tcp      # Istio Envoy inbound
sudo firewall-cmd --permanent --add-port=15008/h2       # Istio HBONE mTLS tunnel
sudo firewall-cmd --permanent --add-port=15009/h2c      # Istio HBONE secure networks
sudo firewall-cmd --permanent --add-port=15010/grpc     # Istio XDS and CA services
sudo firewall-cmd --permanent --add-port=15012/grpc     # Istio XDS and CA services (TLS, mTLS)
sudo firewall-cmd --permanent --add-port=15014/http     # Istio Control Plane monitoring
sudo firewall-cmd --permanent --add-port=15017/https    # Istio Webhook container port (443 forward)
sudo firewall-cmd --permanent --add-port=15020/http     # Istio telemetry (merged)
sudo firewall-cmd --permanent --add-port=15021/http     # Istio Health checks
sudo firewall-cmd --permanent --add-port=15090/http     # Istio telemetry (Envoy)
