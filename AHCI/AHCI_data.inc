N_AHCI dq 0
selected_AHCI dq 0

AHCI dq 0
AHCI_PCIe dq 0

AHCI_n_disks dq 0
AHCI_diskn dq 0
AHCI_disk_selected dq 0


PxFB_stash dd 0
PxFBU_stash dd 0
PxCLB_stash dd 0
PxCLBU_stash dd 0

align 2
DISK_ID_BUF times 512 db 0
