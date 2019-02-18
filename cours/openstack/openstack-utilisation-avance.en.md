## Using OpenStack - advanced

### A big cloud

Make use of:

- Regions
- Availability zones (AZ)

### Affinity / anti-affinity in Nova

- Ask Nova to start 2 or more instances:
  - As close as possible (affinity)
  - As remote as possible (anti-affinity)
- Need of performance or need of spread

### Flavors

- A disk with size 0 means taking the size of the base image

### Metadata

- API
- Disk drive
- Vendor data

### Use cloud images

A cloud image is:

- Disk image containing an already installed OS
- Image that can be instantiated as n servers without error
- An OS that talks to the cloud metadata API (cloud-init)
- Details: <https://docs.openstack.org/image-guide/openstack-images.html>
- Most of the distributions provide cloud images

### Cirros

- Cirros is a typical cloud image
- Minimalist OS
- Contains cloud-init

<https://launchpad.net/cirros>

### Cloud-init

- Cloud-init is a way of taking advantage of the metadata API, especially user data
- The tool is included by default in most cloud images
- From user data, cloud-init performs instance personalization operations
- cloud-config is a possible format for user data

### cloud-config example

```bash
#cloud-config
mounts:
- [ xvdc, /var/www ]
packages:
- apache2
- htop
```

