# Import in /etc/nixos/configuration.nix:
#   imports = [ /path/to/finance-broker/nixos/finance-broker.nix ];
#
# Usage notes:
# 1) Build the broker binary:
#      cd /path/to/finance-broker/broker
#      cargo build --release
# 2) Deploy the SimpleFIN secret file:
#      install -d -m 0500 -o finance-broker -g finance-broker /run/finance-broker/secrets
#      install -m 0400 -o finance-broker -g finance-broker /path/to/simplefin_access_url /run/finance-broker/secrets/simplefin_access_url
# 3) Test over the Unix socket:
#      curl --unix-socket /run/finance-broker/broker.sock \
#        -H 'content-type: application/json' \
#        -H 'x-agent-id: smoke-test' \
#        -d '{}' http://localhost/v1/finance.get_accounts

{ config, lib, pkgs, localConfig, ... }:

let
  cfg = config.services.finance-broker;
in
{
  options.services.finance-broker = {
    enable = lib.mkEnableOption "finance capability broker";

    package = lib.mkOption {
      type = with lib.types; nullOr package;
      default = null;
      description = ''
        Optional package providing the `finance-broker` executable at
        ''${package}/bin/finance-broker.
      '';
    };

    binaryPath = lib.mkOption {
      type = lib.types.str;
      default = "/usr/local/bin/finance-broker";
      description = ''
        Absolute path to the finance-broker executable. If set, this is used for ExecStart.
      '';
    };

    configFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/finance-broker/config.toml";
      description = "Path to finance-broker TOML config file.";
    };

    secretSource = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "/var/lib/secrets/simplefin_access_url";
      description = ''
        Source file containing the SimpleFIN access URL. If set, ExecStartPre copies it to
        /run/finance-broker/secrets/simplefin_access_url with mode 0400.
      '';
    };

    socketPath = lib.mkOption {
      type = lib.types.str;
      default = "/run/finance-broker/broker.sock";
      description = "Unix socket path used by the broker.";
    };

    secretsDir = lib.mkOption {
      type = lib.types.str;
      default = "/run/finance-broker/secrets";
      description = "Runtime secrets directory for broker secret files.";
    };

    environment = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
      description = "Extra environment variables for the finance-broker service.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.finance-broker = { };

    users.users.finance-broker = {
      isSystemUser = true;
      group = "finance-broker";
      home = "/var/lib/finance-broker";
      createHome = true;
    };

    users.groups.finance.members = lib.mkAfter [ localConfig.username "finance-broker" ];

    systemd.services.finance-broker = {
      description = "Finance capability broker";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = cfg.environment;

      serviceConfig = {
        Type = "simple";
        ExecStart =
          let
            brokerBinary =
              if cfg.package != null then "${cfg.package}/bin/finance-broker" else cfg.binaryPath;
          in
          "${brokerBinary} --config ${cfg.configFile}";
        User = "finance-broker";
        Group = "finance-broker";

        RuntimeDirectory = "finance-broker";
        RuntimeDirectoryMode = "0750";

        ExecStartPre = [
          "${pkgs.coreutils}/bin/install -d -m 0500 -o finance-broker -g finance-broker ${cfg.secretsDir}"
        ] ++ lib.optionals (cfg.secretSource != null) [
          "${pkgs.coreutils}/bin/install -m 0400 -o finance-broker -g finance-broker ${toString cfg.secretSource} ${cfg.secretsDir}/simplefin_access_url"
        ];

        ExecStartPost = [
          "${pkgs.coreutils}/bin/chgrp finance ${cfg.socketPath}"
          "${pkgs.coreutils}/bin/chmod 0660 ${cfg.socketPath}"
        ];

        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        MemoryMax = "64M";

        Restart = "on-failure";
        RestartSec = "2s";
      };
    };
  };
}
