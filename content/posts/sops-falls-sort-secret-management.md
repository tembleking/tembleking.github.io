---
title: "DevOps Beware: The Sad Truth About SOPS and Secret Management"
date: 2023-07-14
tags: [ Secret Management, Security, SOPS ]
keywords: [ secret management, security, SOPS, encryption, access control, insider attacks, secret rotation, decrypted secrets, vulnerabilities, risk, bad actors, collaboration, granularity, auditing, compliance, trade-offs, alternative solutions, fine-grained access control ]
---

I've read everywhere the miracles of using SOPS within a project to maintain the secrets in a secure way within the
source
code of the project, or even for GitOps and CI/CD pipelines. But, is it really that secure?
Let's buckle up for a wild ride through the chaotic world of secret management. Strap in tightly because we're about to
explore why [SOPS](https://github.com/getsops/sops) falls short in being a secret management superhero we've been told.

## The Encryption Mirage: Safety Today, Breach Tomorrow

Oh, encryption, you sly little devil. We put our trust in you, thinking you'll protect our secrets from prying eyes. But
guess what?

Let's picture the following scenario: You are a company that has a lot of secrets, for different services, and
different environments. You use SOPS to encrypt all of them within a YAML file or multiple YAML files, so you can
then decrypt them at deployment time. You store them in Git, of course, because you want to keep track of the changes
made to the secrets and you want to audit who changed what and when. You also want to be able to rollback to a previous
version of the secrets if something goes wrong.
All the secrets are encrypted, so you feel safe. But, are you really?

> While encryption is crucial in protecting secrets at rest, the moment they are decrypted for use, they become exposed
> to potential breaches.

Imagine now a scenario where an authorized individual, a developer, wants to add a new secret or modify one of them
because they want to rotate, let's say, the database password for their secret. They have to decrypt the whole file just
to add or modify one secret. This means that the whole file is now decrypted, and the developer can see all the secrets
in plain text.

If you don't see why this is a security risk, I don't know what to tell you.

In such cases, the encrypted secrets become no more secure than plain text, posing a significant risk to the
organization.

## Insider Attacks: Trust No One, Especially the Trusted

One of the most concerning aspects of secret management is the threat posed
by [insider attacks](https://www.ibm.com/topics/insider-threats). Even if encryption
mechanisms are in place, a person with the ability to decrypt a file **holds access to all secrets**.

Should this person leave the company or have malicious intent, they can take advantage of this situation by stealing and
potentially selling the sensitive information to bad actors. This represents a severe security loophole, putting the
organization's reputation, assets, and customer data at significant risk.

![](/images/meme-zero-trust.png)

Following the previous example, that developer has news that their company is going to perform layoffs (like we've seen
in 2022), and there's been problems with salary agreements, or maybe they just want to make some extra money.
They can now sell all the secrets to a bad actor, and the bad actor can use them to access the company's infrastructure
and steal customer data, or even worse, modify the infrastructure to steal customer data without anyone noticing.

Now, you might say, _"Well, that's not a problem, we can just rotate the master key just after the layoffs and the
developer won't be able to decrypt the file anymore."_

That's true, but what if the developer has already decrypted the file and has the secrets in plain text?

Let's picture that the developer has saved them in a file on their computer in plain text.
You might think that, following the best practices, you just have to rotate periodically the secrets, so any developer
that might have had access to the secrets will have useless information. But...

## Challenges with Secret Rotation

... it's not that easy. If you store all the secrets within a single file, you have to rotate every single secret in
the file.
Depending on the number of secrets you store in the file, this will be a very time-consuming process, and not practical
at all. You also need to ensure that every secret is valid, and you did not break anything.

> Secret rotation is a crucial aspect of maintaining a secure environment. Regularly changing secrets helps mitigate the
> potential impact of a breach. However, the process becomes much more complex when secrets are stored in encrypted
> files,
> especially when these files contain a large number of secrets.

In a team environment, multiple developers might need access to different secrets within a file. With SOPS,
granting access to a specific secret actually requires giving access to all the secrets in the file -- so now, multiple
developers have access to all the secrets.

This is not granular access control, and it undermines
the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege). Also you
cannot [audit](https://en.wikipedia.org/wiki/Information_security_audit#Logical_security_audit)
who accessed what secret, because you can only audit who accessed the whole file, so you have to assume that everyone
that accessed the file accessed all the secrets within it, and potentially has a copy of them in plain text.

## The master key is still a key

Let's not forget that the master key used for encryption in secret management systems must also be regularly rotated to
adhere to best practices and enhance security. However, when it comes to tools like SOPS, rotating the master key can
pose compatibility challenges. SOPS relies on a specific encryption algorithm and key management approach, which may not
seamlessly support master key rotation without potential disruptions or data integrity issues.

![](/images/meme-master-key.png)

SOPS has [identified incompatibilities with automatic master key rotation](https://github.com/getsops/sops/issues/1135)
that can complicate the process of transitioning to a new key and require careful coordination to prevent
any [unintended
consequences](https://github.com/getsops/sops/issues/855) during the rotation phase.

## Let's face it: Git was never meant to be a secret storage solution

Our beloved Git, the hero of version control.

Don't mind me, it's fantastic for managing source code and collaborating on projects. But secrets? Yeah, not so much.
Storing secrets in Git repositories is like leaving your front door wide open with a neon sign saying, "Come on in and
help yourself!"
It's like broadcasting your secrets on live television. You might as well hire a skywriter to spell them out in the
clouds. It's a disaster waiting to happen.

## But do developers actually need access even to a single secret?

Well, no, they don't. No one, **not even administrators**, should have access to the secrets.

![](/images/meme-admin-opens-email-trojan.jpg)

They should only be able to access the secrets when they need them, for as little time as possible, and only the secrets
they need. After that,
the secret should be rotated and made invalid, so when anyone needs it again, they have to request it again.

This is the main benefit of using a secret management system like KMS or Vault. You can grant access to a specific
secret to a specific user or application, and you can audit who accessed what secret and when. You can also rotate
secrets automatically, and you can update encryption configurations with ease.

In the previous example, the developer would not have access to the secrets, but they would have access to the
application that needs the secrets. The application would request the secrets from the secret management system, and
the developer would not be able to see the secrets, only the application would. In case the developer leaves the
company, you can just revoke their access to the application, and they won't be able to access the secrets anymore.

In the need of debugging the application, the developer would have to request access to the secrets, and the secret
management system would grant them access for a limited time, and only to the secrets they need. After the debugging
session, the developer would not have access to the secrets anymore because the SMS would have rotated them
automatically.

## To sum up

I am not saying that SOPS is a bad tool, it definitely has its use cases, but in my opinion,
it should not be used for secret management within an organization for access to critical information.

Encryption alone is not enough, as decrypted secrets become vulnerable. Insider attacks and the challenges of secret
rotation pose significant risks. Git is not a suitable solution for secret storage. Instead, adopting a comprehensive
secret management system like AWS KMS, GCP KMS, Azure Key Vault or Hashicorp Vault, with granular access control and
automatic rotation, is crucial for effective security.

Stay safe, but also, keep your secrets safe!
