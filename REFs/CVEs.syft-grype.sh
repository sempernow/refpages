#!/usr/bin/env bash
[[ $1 ]] || exit 1

img="$1"
sbom="${img//\//.}"
name_tag="${sbom//:/_}"
sbom="$name_tag.sbom.json"

# Install tools if needed
type -t syft ||
    curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh |
        sudo sh -s -- -b /usr/local/bin
type -t grype ||
    curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh |
        sudo sh -s -- -b /usr/local/bin

# Generate CycloneDX SBOM
syft $img --output cyclonedx-json="$sbom"

# Scan the SBOM 
grype $sbom --sort-by severity --output cyclonedx-json --file $name_tag.cdx.json
grype $sbom --sort-by severity --output table --file $name_tag.cdx.table

cat $name_tag.cdx.table

