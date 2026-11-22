# AWS Gateways : Types

AWS uses several types of gateways to manage internet connectivity, hybrid networking, API management, and on-premises storage integrations. [1, 2, 3, 4]  

## Core VPC & Internet Networking Gateways 

- I**nternet Gateway** (__IGW__): Connects a VPC directly to the public internet. It enables bidirectional communication for resources with public IP addresses. 
- **Egress-Only Internet Gateway**: Provides outbound-only internet access. It is used specifically for IPv6 traffic to prevent unsolicited inbound connections. 
- **NAT Gateway** (**N**etwork **A**ddress **T**ranslation): Allows private subnet instances to securely access the internet outbound. It blocks the public internet from initiating inbound sessions. [1, 10]  

## Hybrid & Cross-VPC Connectivity Gateways 

- **Transit Gateway** (__TGW__): VPC-to-VPC connectivity 
  and VPC-to-other (Site-to-Site VPN, DXGW) connectivity via *Attachments*. 
  Functions as a cloud router to centralize your network. 
  It connects thousands of VPCs, AWS accounts, and on-premises networks together. 
- **Virtual Private Gateway** (__VGW__): VPC-to-on-prem connectivity.
  Encrypted connectivity between an on-premises network and VPC.
  Used by AWS Managed Services:
    - AWS Site-to-Site VPN
    - AWS Direct Connect (DX[GW])
- **Direct Connect Gateway** (__DXGW__): VPC to on-premises connectivity. 
  A 3rd-party facility that provides a physical, private fiber-optic circuit 
connecting your corporate data center or office directly to the AWS global network.
  It allows on-premises data centers to talk to VPCs across different AWS Regions. 
- **Local Gateway** (__LGW__): Routes traffic between a VPC and an on-premises local network. 
  It is used exclusively inside AWS Outposts deployments. [21, 22, 23, 24]  

## Application & API Gateways 

- Amazon **API Gateway**: A fully managed service to create, publish, and secure HTTP, REST, and WebSocket APIs at scale. 
- **VPC Resource Gateway**: A networking feature that lets you safely expose cross-account services. 
  It bypasses traditional load balancer overhead. [25, 26, 27]  

## Endpoint & Storage Gateways 

- **Gateway VPC Endpoint**: Provides private, secure routing to Amazon S3 and Amazon DynamoDB. It keeps data traffic entirely inside the AWS network without an internet gateway. 
- **AWS Storage Gateway**: Bridges on-premises applications with cloud storage infrastructure. It includes four sub-types: 
	- Amazon S3 File Gateway: Exposes S3 buckets via NFS or SMB filesystems. 
	- Amazon FSx File Gateway: Delivers low-latency local access to fully managed cloud file shares. 
	- Volume Gateway: Provides cloud-backed iSCSI block storage volumes to local servers. 
	- Tape Gateway: Replaces physical tape backup systems with a virtual tape library (VTL) backed by S3. [2, 20, 30, 31, 32]  


[1] https://artofinfra.com/internet-and-nat-gateways-in-aws/
[2] https://dheerajinampudi.medium.com/all-aws-gateways-in-one-place-with-oneliners-7c0d577d7ba0
[3] https://www.mechanicalrock.io/blog/a-devops-guide-to-aws-transit-gateway
[4] https://dataengineeracademy.com/blog/aws-api-gateway-pricing-factors-and-cost-structure/
[5] https://www.youtube.com/shorts/RpYd01VPaSY
[6] https://medium.com/awesome-cloud/aws-vpc-difference-between-internet-gateway-and-nat-gateway-c9177e710af6
[7] https://cyberpanel.net/blog/route-table-in-aws
[8] https://cloudviz.io/blog/aws-internet-gateway-vs-nat-gateway
[9] https://melchiorre-andrea.medium.com/my-journey-to-aws-solution-architect-exam-part-13-transit-gateway-ecmp-vpc-traffic-mirroring-67897c1aed87
[10] https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-scenarios.html
[11] https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html
[12] https://aws.amazon.com/transit-gateway/
[13] https://medium.com/awesome-cloud/aws-transit-gateway-overview-9990fd0aaebb
[14] https://dev.to/akhil_mittal/different-networking-components-in-aws-5f04
[15] https://help.forcepoint.com/flexedge/sd-wan/en-us/7.1.0/how-to-aws/GUID-C54D3458-0F5D-46F1-92C3-A6F75772DD48.html
[16] https://docs.aws.amazon.com/vpc/latest/userguide/gateway-route-tables.html
[17] https://docs.aws.amazon.com/vpc/latest/tgw/tgw-route-tables.html
[18] https://tutorialsdojo.com/amazon-vpc/
[19] https://medium.com/@servifyspheresolutions/aws-customer-gateway-da230f3f1929
[20] https://medium.com/@shaunak-deo/different-types-of-aws-gateways-and-when-to-use-each-c76c44b70d6e
[21] https://docs.aws.amazon.com/vpc/latest/userguide/route-table-options.html
[22] https://d1.awsstatic.com/product-marketing/Outposts/Hybrid%20Data%20Management%20Solution%20Brief.pdf
[23] https://www.cloudzero.com/blog/amazon-vpc-pricing/
[24] https://www.systemsarchitect.io/services/aws-outposts/settings/pt/aws-outposts-settings-local-gateway-lgw-configuration
[25] https://api7.ai/top-11-api-gateways-platforms-compared
[26] https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html
[27] https://aws.amazon.com/blogs/networking-and-content-delivery/vpc-resource-gateways-implementation-patterns-and-use-cases/
[28] https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html
[29] https://www.linkedin.com/pulse/exploring-various-gateways-aws-nikitha-mariam-koshy
[30] https://the-erin.hashnode.dev/gateways-in-aws
[31] https://aws.amazon.com/storagegateway/features/
[32] https://aws.amazon.com/storagegateway/




---

<!-- 

… ⋮ ︙ - ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
☢ ☣ ☠ ¦ ¶ § † ‡ ß µ Ø ƒ Δ ☡ ☈ ☧ ☩ ✚ ☨ ☦ ☓ ♰ ♱ ✖  ☘  웃 𝐀𝐏𝐏 🡸 🡺 ➔
ℹ️ ⚠️ ✅ ⌛ 🚀 🚧 🛠️ 🔧 🔍 🧪 👈 ⚡ ❌ 💡 🔒 📊 📈 🧩 📦 🥇 ✨️ 🔚

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# README HyperLink

README ([MD](__PATH__/README.md)|[HTML](__PATH__/README.html)) 

# Bookmark

- Target
<a name="foo"></a>

- Reference
[Foo](#foo)

-->
