# PAC (**P**roxy **A**uto-**C**onfiguration) Files and Browser Profiles

Both Chrome and Edge support PAC files, 
but they handle the configuration a bit differently than Firefox.

## Chrome: Relies on System Settings

Chrome does not have its own built-in PAC file configuration interface. Instead, it inherits proxy settings from the operating system.

- How to set it up: You configure the PAC file URL in your OS network settings (Windows, macOS, etc.). Once set, Chrome will use that PAC file automatically.
- For Enterprise: Administrators can deploy PAC settings to managed browsers directly via the Google Admin console.

## Edge: Relies on System Settings (with Enterprise Overrides)

Edge behaves similarly to Chrome on desktop—it uses the system-level proxy settings by default.

- For IT Admins: Edge offers a dedicated policy called `ProxySettings`. This allows administrators to push a specific PAC URL (`ProxyPacUrl`) to managed devices, bypassing the need to configure the OS manually.
- For iOS: Interestingly, Edge on iOS has its own separate policy (`EdgeProxyPacUrl`) to configure a PAC file specifically for that platform.

## 💡 Key Takeaway

If you want to set this up on a personal computer, you generally just need to enter the PAC URL in your Windows or macOS proxy settings, and both Chrome and Edge will pick it up.

---

## 🔍 Firefox: True Per-User Override

Firefox's proxy settings, including the PAC URL, are stored in your user profile (`about:config` or the Connection Settings dialog). This means you can set a PAC file specifically for your user account, and it persists independently of other users on the same machine. You can even use a local file path like `file:///...` for the PAC file.

>Chrome & Edge: Per-Profile, but Not Freely Per-User

- Chrome and Edge do support per-profile proxy settings, but not in the way Firefox does:
Chrome: Proxy settings are global per Chrome instance (essentially per profile). You can't set a PAC URL for just one user profile through the normal UI; it reads from the system-level proxy settings. The `--proxy-pac-url` command-line flag works, but it applies to the entire browser instance launched with that flag, not to a specific user within it.
- Edge: Similar situation. The `ProxySettings` policy is marked as "Per Profile: Yes", meaning enterprise admins can apply different proxy policies to different Edge profiles. However, for a regular user on a personal machine, Edge also inherits from the system proxy settings by default.

### 💡 The Key Distinction

|Browser|How You Set a PAC URL|Per-User (Unmanaged)?|
|-------|---------------------|---------------------|
|Firefox|Built-in UI (`about:config` / Settings)|✅ Yes — stored in profile|
|Chrome|System settings or `--proxy-pac-url` flag|❌ No — system-wide or instance-wide|
|Edge|System settings or Enterprise Policy|⚠️ Only via policy (per-profile)|

So while Firefox gives you a native, per-user setting for a PAC URL, Chrome and Edge rely on the operating system's proxy configuration or administrator-deployed policies. You can't simply open a settings menu in Chrome or Edge and enter a PAC URL just for your user account.


---

## Browser Profiles

- Chrome creates a Default profile automatically on first launch. You just never had to name it or think about it. Everything—bookmarks, history, cookies, extensions, saved passwords—lives in that profile.
    - Default location (Windows): `%LOCALAPPDATA%\Google\Chrome\User Data\Default`
    - Default location (macOS): `~/Library/Application Support/Google/Chrome/Default`

### 🧩 Why Profiles Are Useful

The convention pays off when you want separation:

- Work vs. personal — different accounts, extensions, and proxy settings
- Different Google accounts — signed in simultaneously in separate windows
- Testing — a clean profile is a fast way to rule out extension or cache issues
- Different proxy/PAC setups — since proxy settings can be scoped per profile via policy

### 🔀 How to Add One

Click your profile icon (top-right) → Add → give it a name and optionally sign in. Chrome opens it in a separate window with its own icon.

### 🔗 The Catch (and Why Firefox Still Wins Here)

Chrome profiles can have per-profile proxy settings, but only through enterprise policy (`ProxySettings` with Per Profile enabled). For a normal user, there's no UI to set a PAC URL per profile—it still falls back to the system proxy. Firefox, by contrast, lets any user set a PAC URL per profile from the regular Settings UI.
So the profile convention is real and useful, but for per-user PAC overrides without admin tools, Firefox remains the outlier.


The profiles are all under one location by default, but you can declare a completely separate location for a specific profile if you want to.

### 📂 The Default: One Parent Directory, Multiple Subfolders

Chrome has a main "User Data Directory". Every profile you create lives as a subfolder inside that single directory.

- Parent Location (Windows): `%LOCALAPPDATA%\Google\Chrome\User Data`
- Subfolders: Your first profile is usually `Default`. Additional profiles get names like `Profile 1`, `Profile 2`, etc.

So under the hood, `Profile 1` isn't really an isolated entity—it's just a folder sitting next to `Default` inside that main `User Data` parent.

### 🛠️ Overriding for a Separate Location

If you need physical isolation (like for testing or high-security separation), you can override the parent directory for an entire Chrome instance using a command-line flag:

```powershell
chrome.exe --user-data-dir="C:\Chrome-Profiles\Dev"
```

This creates a whole new set of profile subfolders under your custom path, completely separate from your daily driver.

🔍 How to Check Yours

You can verify exactly where your profiles live:

1. Go to `chrome://version`
2. Look at the "Profile Path" field.
3. The "**User Data Dir**" is the parent of that path.


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
