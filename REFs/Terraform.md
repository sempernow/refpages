# [Terraform](https://learn.hashicorp.com/terraform) | [Providers](https://www.terraform.io/docs/providers/index.html) | [Modules](https://registry.terraform.io/browse/modules) | [Download](https://www.terraform.io/downloads.html)

## TL;DR

- Transform IaC code into a provider's API requests.
- Modules per provider (cloud vendor)
    - Work must be repeated for each provider.

Workflow:

```bash
terraform init
terraform plan [-out 'terraform.plan.out']
terraform apply ['terraform.plan.out'] [--auto-approve]

# List resources under terraform management
terraform state list
# Release a declared resource (from state management)
terraform state rm $resource.$name
# Import state (of a declared resource)
terraform import $resource.$name $id

# List outputs
terraform show 
```
- [Config](https://www.terraform.io/docs/cli/config/config-file.html) @ 
    - `%APPDATA%\terraform.rc` (Win)
    - `~/.terraformrc` (Linux/MINGW64/WSL)


## Usage notes

- Module var(s) declared at project root (`main.tf`) bind to module per associated declaration(s) at the module, e.g., at `./modules/sg/variables.tf`
    - @ `./main.tf` (@ project root)
    ```conf
      module "sg" {
          source          = "./modules/sg"
          vpc_id          = module.vpc.vpc_id
          vpc_cidr        = module.vpc.vpc_cidr_block 
          ssh_client_ip   = "73.172.25.116/32"
          wan_ip_whitelist  = var.wan_ip_whitelist
      }
    ```
    - Modules are ignored lest declared at project root
        - Unless already exist in state (`terraform.tfstate`).
- Import state
    ```bash
    # Import state : aws_route53_record
    module_name='route53'
    zone_id='Z2H0UGL4BNA5BN'
    domain='sempernow.com'
    type='NS'
    # If a module
    terraform import module.${module_name}.aws_route53_record.${domain}-${type} ${zone_id}_${domain}_${type}
    # If NOT a module
    terraform import aws_route53_record.${domain}-${type} ${zone_id}_${domain}_${type}
    ```
    - Once state is imported, removing the module declaration at `main.tf` of main folder does NOT ignore; terraform will DESTROY resource if not declared thereafter.

## Configuration Organization

```plaintext
☩ tree               
├── main.tf                                 
├── modules                                 
│   ├── dns                                 
│   │   └── main.tf                         
│   ├── route53                             
│   │   ├── main.tf                         
│   │   ├── outputs.tf                      
│   │   ├── r53r.tf                         
│   │   ├── r53z.tf                         
│   │   └── variables.tf                    
│   ├── sg                                  
│   │   ├── main.tf                         
│   │   ├── outputs.tf                      
│   │   └── variables.tf                    
│   └── swarm                               
│       ├── main.tf                         
│       ├── outputs.tf                      
│       └── variables.tf                    
├── outputs.tf                              
├── terraform.tfstate                       
├── terraform.tfstate.backup                
└── variables.tf                            
                                            
5 directories, 21 files                     
```

## Install 

#### @ Windows / MINGW64 / Cygwin

```shell
choco install terraform
```

#### @ Linux / WSL

[Terraform Releases](https://releases.hashicorp.com/terraform/)

```bash
# Declare
export VER='1.0.1'
ARCH='amd64'
export PKG="terraform_${VER}_linux_${ARCH}.zip"
# Fetch
wget https://releases.hashicorp.com/terraform/${VER}/${PKG}
# Extract
unzip $PKG
# Install
sudo mv terraform /usr/bin/
sudo chmod 775 /usr/bin/terraform
# Validate
terraform -version
```

#### Dockerize

- @ `./terraform-dockerized`
    - [`Makefile`](terraform-dockerized/Makefile)
    - `Dockerfile` ([`Alpine`](terraform-dockerized/tf.alpine.Dockerfile)|[`Ubuntu`](terraform-dockerized/tf.ubuntu.Dockerfile))

This allows for ad-hoc commands from host shell, or persistent bash session in the container; both are configured to the host, and bind-mount both `$HOME` (for terraform cache directory) and the __delcared workspace__ (`TF_WORKSPACE`). Both Ubuntu (`224MB`) and Alpine (`87MB`) versions are tested and operational.

Do not use `hashicorp/terrform` image from Docker Hub:

```bash
docker run --rm -v $PWD:/workspace -w /workspace hashicorp/terraform init
```
- Whatever the image is using for `$HOME` etal is a well kept secret (ZERO documentation), so subsequent commands (`plan`, `apply`) fail due to lack of credentials.
- [Can muck with it](https://www.mrjamiebowman.com/software-development/docker/running-terraform-in-docker-locally/)

##### Plugin Cache Directory

Set a centralized directory for the (`N00 MB`) plugin(s) cache (per _Provider_, per OS) at &hellip;

```shell
mkdir %APPDATA%\terraform.d\plugin-cache
mkdir C:\HOME\.terraform.d\plugin-cache
```

```bash
mkdir -p ~/.terraform.d/plugin-cache
```

##### [Config](https://www.terraform.io/docs/cli/config/config-file.html) 

To reference the `plugin-cache` directory

- `%APPDATA%\terraform.rc` (Win)
- `~/.terraformrc` (Linux/MINGW64/WSL)

```conf
plugin_cache_dir   = "$HOME/.terraform.d/plugin-cache"
disable_checkpoint = true
```

~~UPDATE 2021-06-30 @ `v0.13+`:~~

Symlinks are unreadable by terraform at WSL. ([NTFS Reparse Point](https://en.wikipedia.org/wiki/NTFS_reparse_point))

```shell
mkdir %APPDATA%\terraform.d\plugin-cache
symlink.bat d C:\HOME\.terraform.d %APPDATA%\terraform.d
symlink.bat h %APPDATA%\terraform.rc C:\HOME\.terraformrc
```


## [Providers](https://registry.terraform.io/browse/providers) | [Modules](https://registry.terraform.io/browse/modules) 

## Resources :: [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## [CLI :: `terraform {init,plan,apply}`](https://www.terraform.io/docs/cli/index.html)

```bash
# @ Project dir
terraform init  # Downloads provider(s) plugin(s), per project file (.tf)
terraform 0.13upgrade . #.... if install FAILs, then repeat above (init)
terraform fmt   # format the .tf file (2-space indent)
# Create/Modify 
terraform plan  # Analysis; -out=terraform.plan.out
terraform apply # Build it; "terraform.plan.out" -auto-approve
# ... make edits to .tf file ...
# Modify 
terraform taint aws_ec2_instance.foo # Mark resource for destruction/replacement on next apply
terraform plan  # Analysis; -out=terraform.plan.out
terraform plan -no-color -target=aws_instance.{aa1,aa2,aa3}
terraform apply # Build it; --auto-approve

# Variables
TF_VAR_foo='The apply command auto-injects any environment variables (e.g., foo) so prefixed'

terraform apply \
    -var 'region=us-west-1' \
    -var-file="secret.tfvars" \
    -var-file="prod.tfvars"
#... if var(s) unset, will query user 

# Query (Get) a variable 
terraform output $name_of_output_var
#... returns its value 

# Inspect state 
terraform show

terraform state list
terraform state show $NAME_OF_ITEM_FROM_LIST

terraform refresh

# Delete (EVERYTHING; all resources in the file)
terraform destroy
```

#### `/.terraform` dir

Everything therein is cache. Build per declarations in the `*.tf` file(s) upon `init` command; deletable. 


## [Configuration Language](https://www.terraform.io/docs/configuration/index.html) :: [Blocks](https://www.terraform.io/docs/configuration/resources.html) | [Syntax](https://www.terraform.io/docs/configuration/syntax.html)

- Data Sources
    - An existing resource
    ```tf
    data "aws_s3_bucket" "abucket" {
        bucket = "existing-bucket-x"
    }
    ```
- Interpolation Syntax &mdash; expression to reference the existing resource.
    - `"data.<resource_type>.<resoruce_name>.<exported_attribute>`
        - E.g., `"data.aws_s3_bucket.abucket.arn"`
    - DEPRICATED
        - `"${data.<resource_type>.<resoruce_name>.<exported_attribute>}"`
        - E.g., `"${data.aws_s3_bucket.abucket.arn}"`
        ```bash
        Template interpolation syntax is still used to construct strings from
        expressions when the template includes multiple interpolation sequences or a
        mixture of literal strings and interpolations. This deprecation applies only
        to templates that consist entirely of a single interpolation sequence.
        ```
- Conditional Expressions
    ```
    resource "aws_instance" "ubuntu" {
      count                       = (var.high_availability == true ? 3 : 1)
      ami                         = data.aws_ami.ubuntu.id
      instance_type               = "t2.micro"
      associate_public_ip_address = (count.index == 1 ? true : false)
      subnet_id                   = aws_subnet.my_subnet.id
      tags                        = merge(local.common_tags)
    }
    ```
- [Functions](https://www.terraform.io/docs/configuration/functions.html) :: [`templatefile(tmpl_file_path, {vars_csv})`](https://www.terraform.io/docs/configuration/functions/templatefile.html)
    - `main.tf`
        ```bash
        resource "aws_instance" "web" {
            ami            = data.aws_ami.ubuntu.id
            instance_type  = "t2.micro"
            user_data      = templatefile("user_data.tmpl", { dept = var.user_dept, name = var.user_name })
            #...
        }
        ```
    - `user_data.tmpl`
        ```bash
        #!/bin/bash
        echo "Imported variable :: name: ${name}"
        echo "Imported variable :: dept: ${dept}"
        ```

## CLI :: `terraform import <RSRC_TYPE>.<RSRC_NAME> <ID>`

Terraform can import per resource _address_ (`TYPE.NAME`); ___state___, but not configuration. Thus the need for `terraforming` and such utilities to "export" from infra providers into Terraform config files (`.tf`). Terraform (`plan`/`apply`) functions relative to its knowledge of infra state (`terraform.tfstate`; a JSON file). So, if state (`.tfstate`) of a resource is unknown, then  `plan`/`apply` commands, for example, (try to) add it per resource declarations (`.tf`) even though it already exists (as infrastructure at the provider).

1. Create `main.tf`
    ```bash
    #... provider etal ...

    # This is the resource (type and name) we want to import 
    resource "aws_security_group" "vpc-3d0-WebDMZ" {
        # Needn't include any resource arguments, 
        # but must include the parent declaration.
    }
    ```
1. Get the resource ID 
    ```bash
    aws ec2 describe-security-groups \
        --query 'SecurityGroups[].[GroupName,GroupId]'  
    ```
1. Run ... 
    ```bash
    terraform init
    terraform import aws_security_group.WebDMZ sg-02503f3bd74bdb2b4
    ```
    - Generates `terraform.tfstate`, which is a JSON file describing the current state of all resource(s) targeted per the resource-declarations file (`.tf`).

## `terraforming` :: [GitHub](https://github.com/dtan4/terraforming "dtan4 @ GitHub") | [Article 2019](https://blog.ndk.name/import-existing-aws-infrastructure-into-terraform/ "blog.ndk.name")

A reverse terraform tool (ruby) to import existing infrastructure and state, per provider, as `.tf` and `.tfstate` file(s).

#### Use @ Docker container 

```bash
################################################################
# Docker : terraforming
################################################################
docker pull $image

aws_access_key='GET_FROM_~/.aws/credentials'
aws_access_secret='GET_FROM_~/.aws/credentials'
aws_region='us-east-1'
image='quay.io/dtan4/terraforming'
image='gd9h/terraforming' #... re-tagged & pushed
rsrc='s3'

docker run --rm --name tfing \
    -e AWS_ACCESS_KEY_ID=$aws_access_key \
    -e AWS_SECRET_ACCESS_KEY=$aws_access_secret \
    -e AWS_REGION=$aws_region \
    $image terraforming $rsrc > $rsrc.tf
```

#### Install

```bash
sudo apt update
sudo apt install ruby-full
sudo gem install terraforming
```
- @ Windows CMD: `gem install terraforming`

#### Usage 

##### Step 1. 

Initialize per provider (infra vendor), e.g., AWS. Create and push to working directory, and get list of `terraforming`'s import options &hellip;

```bash
# Working dir
mkdir aws-resources
pushd aws-reources
# Initialize
cat <<EOF > init.tf
provider "aws" {  
    profile = "devops"
    region = "us-east-1"
}
EOF
terraform init 

# List the resource-import options
terraforming --help 
```

##### Step 2.

Export existing [resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl "registry.terriform.io/providers/.../aws/.../resources/...") definitions to HCL (`.tf` files)

```bash
terraforming ec2 --profile=devops > ec2.tf
#... or, per provider's DEFAULT profile (@ ~/.aws/), ...

terraforming ec2  > ec2.tf   # EC2                      aws_instance
terraforming iamu > iamu.tf  # IAM User                 aws_iam_user
terraforming iamg > iamg.tf  # IAM Group                aws_iam_group
terraforming iamp > iamp.tf  # IAM Policy               aws_iam_policy
terraforming iamr > iamr.tf  # IAM Role                 aws_iam_role
terraforming nacl > nacl.tf  # NACL                     aws_network_acl
terraforming r53r > r53r.tf  # Route53 record           aws_route53_record
terraforming r53z > r53z.tf  # Route53 Hosted Zone      aws_route53_zone
terraforming rt   > rt.tf    # Route table              aws_route_table
terraforming rta  > rta.tf   # Route table association  aws_route_table_association
terraforming s3   > s3.tf    # S3 Bucket                aws_s3_bucket
terraforming sg   > sg.tf    # Security Group           aws_security_group
terraforming sn   > sn.tf    # Subnet                   aws_subnet
terraforming vpc  > vpc.tf   # VPC                      aws_vpc
```

##### Step 3.

Export existing state 

```bash
terraforming <resource> --tfstate  [--profile PROFILE] > terraform.tfstate
```
- `<resource>` is `iamg`, `iamu`, `ec2`, &hellip;
- Fails on "`--merge`" option if merging into an empty state file.

So, to export all resources (for future restore/change/synch) &hellip;

```bash
tfstate=terraform.tfstate
#touch $tfstate
rsrc=ec2 
terraforming $rsrc --tfstate > $tfstate 
#... because the `--merge` option results in failure if merging with an empty state file.
for rsrc in {iamg,iamp,iamr,iamu,nacl,r53r,r53z,rt,rta,s3,sg,sn}; do 
    terraforming $rsrc --tfstate --merge=$tfstate --overwrite 
done 
```
##### Fix/Upgrade `terraform.state` 

Replace json keys:
```json
{
  "version": 1,
  "serial": 25,
```

&hellip; with &hellip;

```json
{
  "terraform_version": "0.15.3",
  "serial": 220,
  "lineage": "230f12a2-1012-f40e-a21e-fbaacb18942e",
```


# For future change/synch &hellip;

Add to the folder a `main.tf` to include provider and aws creds, then &hellip;

```bash
terraform plan 
terraform apply
```

State can also be imported using `terraform import`. I.e., map ___each EC2 instance___ definition to its id.

```bash
# Get IDs 
aws ec2 describe-instances --query 'Reservations[*].Instances[*].{IP:PublicIpAddress,ID:InstanceId,State:State.Name,Name:KeyName,AZ:Placement.AvailabilityZone,Arch:Architecture,AMI:ImageId,Type:InstanceType,VPC:VpcId,SubNet:SubnetId,SG:NetworkInterfaces[0].Groups[*],Storage:RootDeviceType}' | jq .

# Import instance IDs, per definition, into Terraform state
terraform import aws_instance.aa1 i-091fe07e70f5b0e4b
terraform import aws_instance.aa2 i-04f90a2d6f4cfd721
terraform import aws_instance.aa3 i-0d10be74a61c2e5e9
```

##### Step 4.

Validate per `plan`

```bash
terraform plan
```
```plaintext 
...
No changes. Infrastructure is up-to-date.
...
```
- Also, per `terraform validate`; a much less critical validation.

#### Option :: Merge with existing state (`terraform.tfstate`)

```bash
terraforming $resource --tfstate --merge=/path/to/tfstate
```

## [`terraformer`](https://github.com/GoogleCloudPlatform/terraformer#installation "GoogleCloudPlatform @ GitHub")

A reverse terraform tool (Golang) to import existing infrastructure, per provider, as `.tf` file(s). 

- Does not support EC2.
- Flakey; corrupts data
- Must perform the usual copy of provider plugins:
    - FROM: `./terraform/plugins/.../windows_amd64`
    - TO: `~/.terraform.d/plugins/windows_amd64`
        - Do the same for `/linux_amd64`
    - Then DELETE `./terraform` dir

```bash
cat <<EOF > init.tf
provider "aws" {  
    region = "us-east-1"
}
EOF

terraform init 

terraformer import aws --resources=vpc,subnet,iam
```

## Terraform : About

Terraform is an ambitious infrastructure-management a.k.a. configuration-management (CM) project of __Hashicorp__; a tool that works toward an explicitly defined end-state; _declarative_ and _idempotent_.

- Utilized as a kind of replacement for vendor tools. For example, it can do much of what the `aws` CLI may otherwise accomplish imperatively.
- Syntax and functionality change per Provider (vendor); unavoidable given the scope of the tool.
    - Tricky and varying syntax to create the required variables for those cross-referenced resources that are part of the build and so don't yet exist.
- Syntax changes per context (standard vs module) and version, and not all standard declarations are available to modules; documentation is sketchy.
- @ Windows, use only the Windows version (at `MINGW64` terminal); `terraform_0.13.5_windows_amd64`. 
    - Linux version fails at WSL (`terraform_1.13.5_linux_amd64`); fails to find its own default plugin, even immediately after installing it (`terraform init && terraform plan`). 

## Terraform : Issues

>Project initialization downloads the requisite "Provider plugins" (hundreds of megabytes; binary) to a local directory (`.terraform`), yet the subsequent commands requiring them are invariably unable to "find" them. That's right, each module gets its own copy of the identical hundreds of megabytes pile of plugins. Ironically, this most essential of all paths is not declarable, or if it is, such is one of the best kept of all their secrets. A workaround for some providers is to copy these massive plugin files from the useless local folder to the undocumented one (`~/.terraform.d/`) which may or may not be auto-created under the user's home directory, depending on installation method (for which documentation is but a link to a binary) but that works only per chance. UPDATE: Linux binary fails most often; Windows binary works a bit better (`v0.13.5`).

>Docker is a "provider" according to some of Terraform's own "documentation" sites, and yet is entirely unmentioned and nonexistent at others. Regardless, [their own Docker tutorial](https://learn.hashicorp.com/tutorials/terraform/state-import?in=terraform/state#create-a-docker-container) fails at initialization (`terraform init`), and then again (after applying the workaround) upon `plan`/`apply`. 

>I'm guessing the oligarchs pay these guys for such a honeypot of time-sucking "automation" code to hamper the competition. Perhaps this is why such crap is hawked by the otherwise-starving "tech" bloggers.

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

