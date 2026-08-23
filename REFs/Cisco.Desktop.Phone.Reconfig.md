# Cisco Desktop Phone | **C**isco **U**nified **C**ommunications **M**anager (**CUCM**)

**Reconfigure**; wipe out the old tenant settings 
and assign correct voicemail access ***directly from the backend***.

## Step 1: Wipe the Prior Tenant Settings

You do not need to physically touch the phones to reset them.

* Remote Factory Reset: Go to __CUCM Administration > Device > Phone__. 
  Find the target phones, click __Reset__, and select Reset (or __Restart_ to pull new configurations).
* Clear __Owner User ID__: In the phone's configuration page, find the __Owner User ID__ field. 
  Clear the old user or change it to the new tenant's ID.

## Step 2: Fix Voicemail Routing (Cisco Unity Connection)

The reason they cannot access voicemail is because the extension or line button is still linked to the old user's mailbox.

* Reassign the Directory Number (__DN__): Go to __Call Routing > Directory Number__ in __CUCM__. 
    Ensure the line is associated with the new user's __End User__ profile.
* Update the __Voice Mail Profile__: Ensure the correct __Voice Mail Profile__ 
  is assigned to the DN so pressing the messages button routes to the right system.
* Create New Mailboxes: In __Cisco Unity Connection__, 
  delete the old tenant mailboxes and create new ones matching the current tenants' extensions.

## Step 3: Link Users to Devices

* Go to __User Management__ > __End User__ in **CUCM**.
* Find the new tenant's profile.
* Under **Device Associations**, check the box for their physical desktop phone.
* Set the **Primary Extension** to their phone line.


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
