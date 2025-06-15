{
  disko.devices = {
    disk = {
      sda = {  # Use /dev/sda, not /dev/vda
        device = "/dev/sda";
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
            size = "100%";  # Use remaining space
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
