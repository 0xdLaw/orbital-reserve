# orbital-reserve

## Clarinet (local testing tool)

This project uses Clarinet for Clarity contract testing. Do not install Clarinet via `cargo install clarinet` — the project expects the official binary release.

Quick install (Linux x64):

```bash
sudo ./scripts/install-clarinet.sh
```

Or use the one-liner used in the devcontainer:

```bash
wget -nv https://github.com/stx-labs/clarinet/releases/latest/download/clarinet-linux-x64-glibc.tar.gz -O clarinet-linux-x64.tar.gz && \
tar -xf clarinet-linux-x64.tar.gz && chmod +x ./clarinet && sudo mv ./clarinet /usr/local/bin && rm clarinet-linux-x64.tar.gz
```

After installing, verify with:

```bash
clarinet --version
```
