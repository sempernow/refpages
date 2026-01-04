# [Node.js](https://nodejs.org/en/ "nodejs.org")

## Muster all dependencies for air-gap builds

To capture **all dependencies** (including transitive ones recursively) of a Node.js application and archive them into individual *.tar.gz* (or *.tgz*) files for fully offline/air-gapped builds, use one of these reliable approaches. These methods ensure you have every exact package version needed, as npm resolves and fetches the full tree during installation.

### Recommended Approach: Populate npm Cache and Extract Tarballs (Pure npm, No Extra Tools)
This is the most straightforward and official way using npm's built-in cache. It produces one *.tgz* per package (exactly what npm publishes).

1. On a machine **with internet access**:
   - Navigate to your project directory.
   - Run `npm install` (or `npm ci` if you have a `package-lock.json` for exact versions). This downloads and resolves **all dependencies recursively** into `node_modules` and populates the npm cache (usually at `~/.npm/_cacache`).
   - The cache now contains every *.tgz* file for all packages in the dependency tree.

2. Locate and copy the tarballs:
   - The tarballs are in your npm cache directory (run `npm config get cache` to confirm the path, e.g., `~/.npm`).
   - Inside it, go to `_cacache/content-v2/sha512/` (or similar; the structure uses content-addressable storage based on SHA512 hashes).
   - To extract them cleanly, run:
     ```
     npm pack $(npm ls --all --parseable | tail -n +2) --dry-run
     ```
     This lists all tarballs that would be packed without downloading anything new.
     - Then, copy them to your working directory:
       ```
       npm pack $(npm ls --all --parseable | tail -n +2)
       ```
       This places one `<package-name>-<version>.tgz` file per dependency (including transitive ones) in the current directory.
   - Alternatively, manually copy all files from the cache subfolders—each is a raw *.tgz*.

3. Transfer the resulting set of *.tgz* files to the air-gapped machine.

4. On the **air-gapped machine**:
   - Add all tarballs to the npm cache:
     ```
     npm cache add /path/to/*.tgz
     ```
     (Do this for each, or use a loop: `for f in *.tgz; do npm cache add "$f"; done`)
   - Now run `npm install` (or `npm ci`) in your project directory. npm will use only the cached tarballs—no network access needed.

This ensures **everything** is included (including native modules that don't require compilation, or pre-built binaries). For packages with native code requiring build tools, ensure the air-gapped environment has compatible compilers (e.g., gcc, Python).

### Alternative: Use a Dedicated Tool for Automated Tarball Bundling
If the manual cache extraction feels cumbersome, install and use the `package-bundle` tool (available on npm):

1. On the internet-connected machine:
   ```
   npm install -g package-bundle
   package-bundle
   ```
   - This reads your `package.json` (or specify packages manually) and downloads **all recursive dependencies** as original *.tgz* files.
   - Options:
     - `--no-dev`: Skip devDependencies.
     - `--flat`: Save in a flat structure (default is npm-like hierarchy).
   - It outputs a folder full of `<package-name>-<version>.tgz` files.

2. Transfer the *.tgz* files to the air-gapped machine.

3. On the air-gapped machine: Same as above—`npm cache add` each tarball, then `npm install`.

This tool is specifically designed for offline/air-gapped scenarios and handles recursion automatically.

### Other Options (If You Prefer a Different Format)
- **Single bundle with bundledDependencies** (one big *.tgz* for the whole app):
  - Temporarily edit your `package.json` to add `"bundledDependencies": [...]` listing **all** direct dependencies (get the list via `npm ls --depth=0`).
  - Run `npm pack`. This creates one `<your-app>-<version>.tgz` containing your code + all deps bundled inside `package/node_modules`.
  - On air-gapped: `npm install /path/to/your-app.tgz`.
  - Drawback: Less granular (not individual module tarballs), and manual list maintenance.

- **Archive the entire node_modules** (simplest, but not tarballs per module):
  - After `npm install`, zip/tar the `node_modules` folder + your source code + `package.json`/`package-lock.json`.
  - On air-gapped: Unzip and run the app directly (no `npm install` needed).
  - This works perfectly for runtime, but if you need to "build" (e.g., run scripts), it includes everything.

The cache/tarball methods are best for true air-gapped reproducibility, as they mirror exactly how npm fetches packages from the registry. Always test the offline process on a isolated machine first.

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
