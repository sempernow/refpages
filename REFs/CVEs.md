# CVEs : SBOM Generation and CVE Detection

## Container Images

See __`CVEs.Trivy`__ ([MD](file:///D:/1%20Data/IT/Container/security/Trivy/CVEs.Trivy.md)|[HTML](file:///D:/1%20Data/IT/Container/security/Trivy/CVEs.Trivy.html)) 

## Filesystem Binaries

For binary files, use [__`syft`__](https://github.com/anchore/syft "GitHub.com/Anchore/") for SBOM generation,
and [__`grype`__](https://github.com/anchore/grype "GitHub.com/Anchore/") for the final CVEs report, 
both in [CycloneDX](https://cyclonedx.org/ "CycloneDX.org") format.

Example : __Scan `kubectl` plugins__ of __`~/.krew/bin/`__
```bash
# Install the tools
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh |
    sudo sh -s -- -b /usr/local/bin
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh |
    sudo sh -s -- -b /usr/local/bin

# Generate TABLE of plugin CVEs from grype scan of syft SBOM
plugin=tree
syft scan file:~/.krew/bin/kubectl-$plugin -o cyclonedx-json |
    grype

# Same, but capture SBOM and CycloneDX files (JSON)
syft scan file:~/.krew/bin/kubectl-$plugin --output cyclonedx-json="kubectl-$plugin.sbom.json"
grype sbom:kubectl-$plugin.sbom.json --output cyclonedx-json --file kubectl-$plugin.cdx.json

# All plugins (pipe method fails at grype unless out to table and no options)
for plugin in ~/.krew/bin/*; do 
    bin=$(basename "$plugin")
    echo "=== @ $bin"
    syft scan file:"$plugin" --output cyclonedx-json="$bin.sbom.json"
    grype sbom:"$bin.sbom.json" -o cyclonedx-json --file "$bin.cdx.json"
    rm "$bin.sbom.json"
done |& tee krew-cves.log

```

Like other similar tools, `grype` has a flag to fail on any CVE finding 
that is equal to or greater than a declared severity, e.g., `HIGH`.

This allows for implementing a CVEs policy on any or all containers of a K8s cluster, 
and doing so with a purpose-built admission controller.


### OWASP [Dependency-Check](https://owasp.org/www-project-dependency-check/)

Dependency-Check is a Software Composition Analysis (SCA) tool that uses 
[National Vulnerability Database (__NVD__)](https://nvd.nist.gov/developers/start-here), 
which is best accessed using an API key ([Request API Key](https://nvd.nist.gov/developers/request-an-api-key)).

__We have not found a use case for this tool.__

Example filesystem scan for CVEs that returns nothing whatsoever:

```bash
bash dependency-check.sh ... --nvdApiKey YOUR_API_KEY 

bash dependency-check.sh -s ~/.krew/store/**/**/kubectl-*  --out krew-report.json --format JSON --project "Krew Plugins Audit"
```


---

<!-- 

… ⋮ ︙ • ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
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
