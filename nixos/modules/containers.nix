{ config, ... }: {
  virtualisation = {
    incus.socketActivation = true;
    podman.dockerSocket.enable = true;
  };
}
