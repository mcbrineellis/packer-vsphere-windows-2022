# packer-vsphere-windows-2022
This Packer config builds an updated Windows 2022 Standard GUI template.

## Environment

Config files for each separate virtual environment are stored in a separate repository or sub-folder.
This allows for separate CI/CD pipelines and customization for each environment.

### Environment variables

Define these environment variables on your system or in your CI/CD pipeline:

```
export PKR_VAR_vsphere_username="username"
export PKR_VAR_vsphere_password="secretpassword"
```

These environment variables are required by Packer to connect up to the vCenter server.