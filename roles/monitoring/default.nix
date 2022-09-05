{ config, lib, pkgs, ... }:

let
  cfg = config.my.roles.monitoring;

  promPort = 8036;
  grafanaPort = 8037;
in {
  options.my.roles.monitoring.enable = lib.mkEnableOption "Monitoring infrastructure";

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;

      listenAddress = "127.0.0.1";
      port = promPort;
      webExternalUrl = "https://prom.dolphin-emu.org/";
    };

    age.secrets.grafana-admin-password = {
      file = ../../secrets/grafana-admin-password.age;
      owner = "grafana";
    };

    age.secrets.grafana-secret-key = {
      file = ../../secrets/grafana-secret-key.age;
      owner = "grafana";
    };

    services.grafana = {
      enable = true;
      port = grafanaPort;
      domain = "mon.dolphin-emu.org";
      rootUrl = "https://mon.dolphin-emu.org/";

      security = {
        adminUser = "grafana";
        adminPasswordFile = config.age.secrets.grafana-admin-password.path;
        secretKeyFile = config.age.secrets.grafana-secret-key.path;
      };

      provision = {
        enable = true;
      };
    };

    my.http.vhosts."prom.dolphin-emu.org".proxyLocalPort = promPort;
    my.http.vhosts."mon.dolphin-emu.org".proxyLocalPort = grafanaPort;
  };
}