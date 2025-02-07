# Sigstore

[Sigstore](https://sigstore.dev/) is an open source project for improving software supply chain security. The Sigstore framework and tooling empowers software developers and consumers to securely sign and verify software artifacts such as release files, container images, binaries, software bills of materials (SBOMs), and more. Signatures are generated with ephemeral signing keys so there’s no need to manage keys. Signing events are recorded in a tamper-resistant public log so software developers can audit signing events.

## Table of contents

<!-- TOC generated with VSCode Extension yzhang.markdown-all-in-one -->
- [Sigstore](#sigstore)
  - [Table of contents](#table-of-contents)
  - [The purpose of this project](#the-purpose-of-this-project)
  - [How Sigstore works](#how-sigstore-works)
    - [Security Model](#security-model)
  - [Sigstore Components](#sigstore-components)
    - [Cosign](#cosign)
    - [Fulcio](#fulcio)
    - [Rekor](#rekor)
    - [Gitsign](#gitsign)
    - [Policy Controller](#policy-controller)
  - [Further Links](#further-links)
  - [How to use this project](#how-to-use-this-project)

## The purpose of this project

This project will (hopefully) help you become familiar with Sigstore. It is intended to provide an environment for testing the signing of container images.

A container runtime such as [Podman](https://podman.io/) or [Docker](https://www.docker.com/) is required to work with this project.

## [How Sigstore works](https://docs.sigstore.dev/#how-sigstore-works)

A Sigstore client, such as Cosign, creates a public/private key pair and makes a certificate signing request to our code-signing certificate authority (Fulcio) with the public key. A verifiable OpenID Connect identity token, which contains a user’s email address or service account, is also provided in the request. The certificate authority verifies this token and issues a short-lived certificate bound to the provided identity and public key.

You don’t have to manage signing keys, and Sigstore services never obtain your private key. The public key that a Sigstore client creates gets bound to the issued certificate, and the private key is discarded after a single signing.

After the client signs the artifact, the artifact’s digest, signature and certificate are persisted in a transparency log: an immutable, append-only ledger known as Rekor. With this log, signing events can be publicly audited. Identity owners can monitor the log to verify that their identity is being properly used, and someone who downloads an artifact can confirm that the certificate was valid at the time of signing.

For verifying an artifact, a Sigstore client will verify the signature on the artifact using the public key from the certificate, verify the identity in the certificate matches an expected identity, verify the certificate’s signature using Sigstore’s root of trust, and verify proof of inclusion in Rekor. Together, verification of this information tells the user that the artifact comes from its expected source and has not been tampered with after its creation.

For more information on the modules that make up Sigstore, review [Tooling](https://docs.sigstore.dev/about/tooling/).

### Security Model

 - [https://docs.sigstore.dev/about/security/]

## Sigstore Components

### Cosign

**TODO** Code signing and transparency for containers and binaries 

- [https://github.com/sigstore/cosign]

### Fulcio

**TODO** Sigstore OIDC PKI

- [https://github.com/sigstore/fulcio]

### Rekor

**TODO** Software Supply Chain Transparency Log

- [https://github.com/sigstore/rekor]

Simple UI for searching Search the Rekor public transparency log

- [https://search.sigstore.dev/]

### Gitsign

**TODO** Keyless Git signing using Sigstore

- [https://github.com/sigstore/gitsign]

- Why use Gitsign instead of the usual commit signing workflow?
	- [https://docs.sigstore.dev/about/faq/#gitsign]
	- [https://docs.sigstore.dev/about/faq/#why-does-a-browser-window-open-for-each-commit-in-a-rebase]
		- [https://github.com/sigstore/gitsign/tree/main/cmd/gitsign-credential-cache]
- Inspecting Gitsign Commit Signatures
	- [https://docs.sigstore.dev/cosign/verifying/inspecting/]
- GitLab Support
	- [https://gitlab.com/gitlab-org/gitlab/-/issues/364428]

### Policy Controller

**TODO** Sigstore Policy Controller - an admission controller that can be used to enforce policy on a Kubernetes cluster based on verifiable supply-chain metadata from cosign

- [https://github.com/sigstore/policy-controller]

## Further Links

- Project: [https://sigstore.dev/]
	- Open Source Security Foundation Project (Linux Foundation Projects)
		- [https://openssf.org/community/sigstore/]
	- Source Code: [https://github.com/sigstore]
	- Videos: [https://www.youtube.com/@projectsigstore]
	- Blog: [https://blog.sigstore.dev/]
	- Protobuf Specs: [https://github.com/sigstore/protobuf-specs]
	- API: [https://www.sigstore.dev/swagger/]
	- Sigstore Clients: [https://docs.sigstore.dev/language_clients/language_client_overview/]
	- Kubernetes Policy Controller: [https://docs.sigstore.dev/policy-controller/overview/]
	- Signing Types: [https://docs.sigstore.dev/cosign/signing/other_types/]
- Publications about the project
	- [https://www.adaper.ch/2024/07/29/sigstore-code-signierung-fuer-jedermann/]
	- [https://rewanthtammana.com/sigstore-the-easy-way/index.html]
	- [https://blog.sigstore.dev/a-guide-to-running-sigstore-locally-f312dfac0682/]

## How to use this project

A local OCI registry can be created using the `make local` command. Now that you're ready to play with the OCI registry, let's get started...

```bash
# Create a local environment if you have not already done so
make local
# Open WebUI
open http://localhost:8080

# Build a OCI image for tests
make build

# Inspect the created OCI image
docker inspect \
  localhost:5000/malfter/sigstore/hello-sigstore:latest

# Push the created OCI image to the local OCI registry
make push

# Display OCI image repository digest
docker inspect \
  --format='{{index .RepoDigests 0}}' \
  localhost:5000/malfter/sigstore/hello-sigstore:latest

# Sign OCI image
IMAGE_DIGEST=$(docker inspect \
  --format='{{index .RepoDigests 0}}' \
  localhost:5000/malfter/sigstore/hello-sigstore:latest)
cosign sign "${IMAGE_DIGEST}"

# Verify OCI image signature
cosign verify \
  --certificate-identity github@alfter-web.de \
  --certificate-oidc-issuer https://github.com/login/oauth \
  "${IMAGE_DIGEST}" -o json | jq .

# Download signature
cosign download signature "${IMAGE_DIGEST}" | jq .

# Search in transparency log
rekor-cli search --email github@alfter-web.de
rekor-cli get --log-index <LOG_INDEX>
# Or use WebUI
open https://search.sigstore.dev/?email=github@alfter-web.de

# Inspect OCI image with skopeo
skopeo inspect docker://localhost:5000/malfter/sigstore/hello-sigstore:latest
skopeo inspect docker://localhost:5000/malfter/sigstore/hello-sigstore:sha256-<SIGN_SHA>.sig
```
