# Minio Configuration

If you installed Minio from either Fedora or ArchLinux or Manjaro's official
repositories, you should see that it has nicely installed a systemd service for
you, so that you're able to start it up alongside the rest of your system
services.

Read [this](https://github.com/minio/minio-service/tree/master/linux-systemd)
for instructions on configuring minio with systemd.

## /etc/default/minio

The main configuration happens by creating (as root) a `/etc/default/minio` file
and populating it with the following:

```
# Volume to be used for MinIO server.
MINIO_VOLUMES="/minio/"
# Use if you want to run MinIO on a custom port.
MINIO_OPTS="--address :9000 --console-address :9001"
# Root user for the server.
MINIO_ROOT_USER=minio_root_user_login
# Root secret for the server.
MINIO_ROOT_PASSWORD=ChangeToSomethingSecretYouDummy
```

## Setup Minio User

Run `cat /etc/systemd/system/minio.service` to check what the username of the
default minio user is. It should most likely be `minio-user`.

Sometimes, this user might not yet be created. Fix that!

```bash
sudo useradd minio-user
```

Now you'd want to create `/minio/` and let this user own it. If you have high
performance requirements for this, mount it in a fast SSD. If you know someone
who has a laptop that came with a 32GB Intel Optane SSD, buy it off them!
They're perfect for these sort of things.

```bash
sudo mkdir /minio
sudo chown minio-user:minio-user /minio
```

## Minio Admin Panel

Visit http://localhost:9001 to go to the Minio Admin Panel. Enter the username
and password you created in the previous step.

### Buckets tab

Add buckets for your projects that depend on Minio in the buckets tab.

### Settings tab

#### Region

In the region setting, set the region to what you'd want to identify your Minio
region as. For example, `fra1`.

### API

Here you can add Cors Allow Origin entries to receive incoming requests to Minio
from a browser.

## IAM Policies

You might want to create an IAM Policy that allows you to do ANYTHING on a
particular bucket, so that this can be assigned to a project's group's API keys.

Eg: you'd create a policy named `my-project-userbucket_all` that looks like
this:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::my-project-userbucket"
            ]
        }
    ]
}
```



