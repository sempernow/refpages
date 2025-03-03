# `rust`

## `rustup` TLS 

UPDATE:

`rustup`__  uses __`rustls`__ as the default TLS backend by default if `v1.28+`. 
For earlier verions, set the enivornment variable:

__`RUSTUP_USE_RUSTLS=1`__

### Q:

Does `rustup` on Windows rely on the OS trust store to verify TLS certificates?

### A:

No, __`rustup`__ on Windows __does not rely on the OS trust store__ to verify TLS certificates directly. Instead, it uses __`reqwest`__ for HTTP requests, which in turn uses __`rustls`__ as the default TLS backend. `Rustls` is a Rust-native TLS library that includes a bundled version of __Mozilla's root certificates__ at the time of its release, rather than relying on the operating system's trust store. This setup helps ensure that `rustup` maintains a consistent set of trust roots across different platforms and configurations.

### Q:

How to configure for TLS using `rustls` if CA is private (custom) yet already loaded into Windows trust store?

### A:

To configure `rustls` to use a private (custom) Certificate Authority (CA) that is already trusted in the Windows trust store when the default `rustls` setup doesn't directly use the OS trust store, you need to explicitly load the CA certificates into `rustls`. Here’s how you can approach this task in Rust, focusing on incorporating the custom CA:

1. **Extract the CA Certificate from Windows:** First, you need to export the CA certificate from the Windows trust store. This can be done using the Microsoft Management Console (MMC) or other Windows tools.

2. **Convert the Certificate:** Ensure the certificate is in PEM format. If it’s not, convert it using a tool like OpenSSL.

3. **Load the Certificate in Rust:** You will need to read the CA certificate file and add it to the `rustls` configuration in your Rust application. Here’s an example of how you can do this:

```rust
use rustls::{ClientConfig, RootCertStore};
use std::fs::File;
use std::io::{BufReader, Read};
use rustls_pemfile::certs;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Path to the exported CA certificate in PEM format
    let cert_file = File::open("path_to_your_ca_cert.pem")?;
    let mut reader = BufReader::new(cert_file);

    // Load the certificates from the file
    let certs = certs(&mut reader)?
        .iter()
        .map(|v| rustls::Certificate(v.clone()))
        .collect();

    // Prepare the TLS configuration
    let mut root_store = RootCertStore::empty();
    root_store.add_parsable_certificates(&certs);

    let config = ClientConfig::builder()
        .with_safe_defaults()
        .with_root_certificates(root_store)
        .with_no_client_auth();

    // Now you can use `config` to create TLS connections that trust your custom CA
    Ok(())
}
```
- This script is __UNTESTED__.
- Note its required parameter : __`path_to_your_ca_cert.pem`__


**Integration Note:** If your application or tool uses `rustup` or another system that internally uses `rustls` and you don't have control over the internal TLS configuration, you might need to modify the application itself to support custom CA loading as described, or proxy its network requests through a local service that can handle the custom CA verification.

### &nbsp;
