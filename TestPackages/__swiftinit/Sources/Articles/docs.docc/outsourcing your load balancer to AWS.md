# Why you shouldn’t outsource your load balancer to AWS

For many public-facing server applications, the apex node is a critical point of failure. Problems at the apex node can cause the entire service to become unavailable. Therefore, many engineers are tempted to outsource load balancers to AWS. However, this is a bad idea. Here’s why.


## Outsourcing the apex node is equivalent to outsourcing security

Amazon is a great company. This article is not a rant against Amazon or their business practices. However, it is important to remember that **Amazon is a logistics company**. Amazon specializes in provisioning server resources at a low cost to consumers. Amazon is not a security company, and outsourcing security to another company limits your ability to secure your application.

The ability to monitor incoming traffic flows is an important part of securing a web application. Because AWS’s [network load balancers](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html) (NLBs) act as a proxy between the internet and your application, your application will lose the ability to distinguish the IP addresses of incoming requests, as they will all appear to come from the load balancer. This makes it difficult to monitor incoming traffic flows and identify potential threats.


## Wait, what about Client IP Preservation?

[Client IP Preservation](https://aws.amazon.com/blogs/networking-and-content-delivery/configuring-client-ip-address-preservation-with-a-network-load-balancer-in-aws-global-accelerator/) is a feature of AWS’s network load balancers that involves rewriting incoming requests to display the original client IP address. Unfortunately, this feature is IPv4-only. Therefore, IPv6 traffic will not have its client IP address preserved.

Keep in mind that lack of IPv6 support is not the main reason to avoid using Client IP Preservation. There are important reasons why Client IP Preservation itself is bad for security, which we will discuss next.


## Why is Client IP Preservation bad for security?

Client IP Preservation violates a basic assumption relied upon by many networking components, which is that the IP address of a packet represents the origin of the packet. In practice, this means that security features such as firewalls, intrusion detection systems, and rate limiters will not work as expected when Client IP Preservation is enabled. In many deployments, it is still necessary to access the node for maintenance purposes via routes that do not pass through the load balancer, which means that security systems cannot generally assume that Client IP Preservation has been applied to incoming traffic or not. Therefore, Client IP Preservation effectively blinds security systems to IP addresses in general.

Client IP Preservation is technically a network-level concept, but application-level load balancers ([ALBs](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)) also provide a similar feature, which has many analogous perils [detailed in this blog post](https://adam-p.ca/blog/2022/03/x-forwarded-for/).


## Why is distinguishing the IP addresses of incoming requests important?

IP addresses are one of the more-difficult components of a network request to spoof. This is less true for IPv6 address than it is for IPv4 address, and verifying IPs still requires some, non-trivial amount of engineering effort to derive a meaningful security benefit from it. Nevertheless, there are broad swaths of threats that can be mitigated by distinguishing IP addresses. IP verification remains one of the most effective layers of defense available to organizations operating under a comprehensive [multilayered security strategy](https://www.ibm.com/docs/en/i/7.3?topic=security-layered-defense-approach). Organizations that choose to forgo this defense are at a major disadvantage compared to those that do not.


## What if I decide to make my service IPv4-only?

This is a valid option for many organizations, and you should consider if it is right for you. However, for many public-facing applications, IPv6 support is an important business requirement. Therefore, it is important to consider the implications of making your service IPv4-only. Keep in mind though, that this still involves relying on Client IP Preservation, which is itself a security hazard.


## What if I just wait for AWS to support IPv6 preservation?

In terms of security, this is a similar choice to making your service IPv4-only. For some organizations willing to rely on Client IP Preservation, this may be a valid choice.


## Can I get around this by dual-stacking my load balancer?

Dual-stacking a load balancer refers to the practice of configuring a load balancer to accept both IPv4 and IPv6 traffic. In practice, this means involves mapping IPv4 traffic to IPv6 addresses, since it would much harder to map addresses the other way around. Therefore, dual-stacking a load balancer transitions your application to an IPv6-only world, and there is no Client IP Preservation for IPv6 traffic.


## If I choose to rely on Client IP Preservation, what are some things I can do to mitigate the risks?

We don’t recommend relying on Client IP Preservation, but if you do, you should ensure that **all** traffic to your application passes through the load balancer, including traffic through maintenance routes. Moreover, you should limit all such traffic to IPv4, since the basic idea is that if Client IP Preservation is occurring anywhere, then it should be occurring everywhere. For some organizations, this may not be practical.


## Think about why you are using a load balancer

Certain server applications operate at such a scale that a load balancer is unavoidable. But there are many classes of server applications for which the actual public-facing web server is not a relevant bottleneck. Choosing an appropriate architecture — for example, by load-balancing between database servers instead of web servers — can often be a more effective way to scale a service.

In general, most complex server topologies already contain internal layers that can be used to distribute service load. Rarely is it truly necessary to balance at the apex node. If you are considering using a load balancer, you should ask yourself if you are doing so for the right reasons.

Are you doing **too much work** on the apex node? Do the majority of incoming requests really need to be served **dynamically**? Keep in mind that putting solid security measures in place can dramatically reduce the amount of incoming traffic from fraudulent sources such as scrapers, academic research bots, SEO analyzers, and malicious probes. For many unprotected applications, fraudulent traffic accounts for an overwhelming share of incoming requests, and attempting to load-balance these requests is, in a way, solving the wrong problem.


## Are there still good reasons to use an AWS load balancer?

Yes! AWS load balancers are a great way to route maintenance traffic to your *internal* nodes. Load balancers can provide a handy abstraction for interacting with multi-node setups as if all servers were running on the same host. One of the biggest advantages of this is that it allows you to modify the topology without having to make changes to DNS configurations, as the DNS can be permanently pointed at the load balancer instead of individual cluster members. This can be a huge time-saver for organizations that are continuously upgrading their fleets.

Using AWS load balancers to mediate access to internal resources can also greatly enhance the security of your deployment, since the nodes behind the load balancer can be made completely inaccessible to the public internet.
