# Lynis on Centos

Pass as many Lynis test as possible on Centos 7.

This work is being done at the request of the Enterprise Container Working Group (ECWG) of the Office of Information and Technology (OIT - https://www.oit.va.gov/) at the Department of Veteran Affairs.

On 2020-Jun-24, a Lynis Hardening Index of 100 was acheived.

Please read the **Skip Tests** section in `playbook-harden-to-100.yml` to understand which tests were skipped and why.

## Skipped Tests

### ACCT-9622 (Check for available Linux accounting information)

FCOS does not have a /var/account directory. However, we do load the audit package which tracks user actions.

### ACCT-9630 (Check for auditd rules)

Checking for audit rules is beyond the scope of this project.

### FIRE-4508 (Check used policies of iptables chains)

IPTABLES are beyond the scope of this project. I believe include defense in depth. However,
* Firewall rules are very application-specific.
* 2. EC2 instances use security groups.

### FILE-6310 (Checking /tmp, /home and /var directory)

Changing how and where directories are mounted is beyond the scope of this project. Ideally /tmp, /home, and /var should be on separate drives.

### HRDN-7230 (Check for malware scanner)

Malware scans are too environment specific for a generic project like this to resolve.

### LOGG-2154 (Checking syslog configuration file)

Checking for external logging is beyond the scope of this project. There are simply too many ways to enable this feature.

### MALW-3280 (Check if anti-virus tool is installed)

Checking for anti-virus software is beyond the scope of this project.

### PKGS-7420 (Detect toolkit to automatically download and apply upgrades)

Skipped because servers will be terminated, not updated.


## Definitions

[**CentOS**](https://www.centos.org), CentOS is a Linux distribution that provides a free, community-supported computing platform functionally compatible with its upstream source, Red Hat Enterprise Linux.

[**Lynis**](https://cisofy.com/lynis) is a battle-tested security tool for systems running Linux, macOS, or Unix-based operating system. It performs an extensive health scan of your systems to support system hardening and compliance testing. The project is open source software with the GPL license and available since 2007.

## Configuration

### external_vars.yml

This file holds variables used by the Ansible playbooks. They are externalized so they don't repeat in every playbook.

**For simplicity's sake, the ssh_port is not being used yet.**

The banner (and /etc/issue) text can be put into a file referenced by `banner_text_file`.

```yaml
---
ansible_python_interpreter: /bin/python3
banner_text_file: file-banner-text.txt
password_max_days: 90
password_min_days: 1
sha_crypt_max_rounds: 10000
sha_crypt_min_rounds: 5000
ssh_user: centos
```

### Provision Server (and Infrastructure)

```bash
terraform init
terraform apply --auto-approve
```

## Terminate Server (and Infrastructure)

```
terraform destroy --auto-approve
```

## Harden the Server

```bash
./run-harden-to-100-playbook.sh
```

## SSH To Server

```bash
./ssh-to-server.sh
```

## Run Lynis

```bash
./run-lynis-audit-playbook.sh
```

# Backup Information

## Getting Amazon SSM Agent

I compiled the binaries from the GitHub project at https://github.com/aws/amazon-ssm-agent. If you want a pre-compiled binary, try https://github.com/medined/aws-ssm-agent-for-fedora-coreos. 

## Why Use /data/pem Instead of ~/.ssh?

* It is possible to have too many keys in the `~/.ssh` directory. 
* For each SSH access, each keys in `~/.ssh` will be tried.

## How To Create PKI Public Key From Private Key

Use the following command as a guide.

```bash
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub
```

## Links

* https://cisofy.com/lynis
* https://github.com/CISOfy/lynis-ansible
* https://www.centos.org
* https://www.lisenet.com/2017/centos-7-server-hardening-guide/