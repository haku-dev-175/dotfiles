{ config, pkgs, ... }:

{
  # PostgreSQL 14
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
  };

  # Redis
  services.redis.servers."" = {
    enable = true;
    port = 6379;
    bind = "127.0.0.1";
  };

  # MySQL 8.0
  services.mysql = {
    enable = true;
    package = pkgs.mysql80;
  };

  # Nginx
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  # Memcached
  services.memcached.enable = true;

  # Docker (optional - can use Colima from home-manager instead)
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Note: Colima is installed via home-manager and works on all platforms.
  # You can choose to use Colima instead of the Docker service if preferred.

  # Tailscale VPN
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # SSH Server
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      # Authentication (set PasswordAuthentication = false after adding SSH keys)
      PubkeyAuthentication = true;
      PasswordAuthentication = true;
      PermitEmptyPasswords = false;
      KbdInteractiveAuthentication = false;

      # Security
      PermitRootLogin = "no";
      StrictModes = true;
      MaxAuthTries = 3;
      MaxSessions = 10;

      # X11 Forwarding
      X11Forwarding = true;
      X11DisplayOffset = 10;

      # Session
      PrintMotd = false;
      PrintLastLog = true;
      TCPKeepAlive = true;
      ClientAliveInterval = 120;
      ClientAliveCountMax = 720;

      # Logging
      SyslogFacility = "AUTH";
      LogLevel = "INFO";
    };
    extraConfig = ''
      AcceptEnv LANG LC_*
    '';
  };
}
