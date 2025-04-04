{
  disko.devices = {
    disk = {
      sda = {
        device = "/dev/sda"; # Replace with your disk device
        type = "gpt";        # Use GPT partition table
        partitions = {
          ESP = {
            size = "500M";
            type = "EF00";   # EFI system partition
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";   # Use remaining space
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
