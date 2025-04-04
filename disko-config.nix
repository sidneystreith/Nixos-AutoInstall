{
  disko.devices = {
    disk = {
      vda = {  # Use /dev/vda, not /dev/sda
        device = "/dev/vda";
        type = "gpt";  # GPT partition table
        partitions = {
          ESP = {
            size = "500M";  # EFI partition size
            type = "EF00";  # EFI system partition type
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";  # Use remaining space (19.5G)
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
