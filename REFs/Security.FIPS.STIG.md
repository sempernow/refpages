# Federal Compliance : FIPS and STIG : Civilian vs. Military

**FIPS** and **STIGs** are two critical **cybersecurity compliance frameworks** used primarily by the U.S. government and its contractors, but they have become de facto standards in many high-security industries.

### **FIPS (Federal Information Processing Standards)**

**What it is:** FIPS are publicly announced standards developed by the U.S. federal government for use by all non-military government agencies and by government contractors. They are created and maintained by the National Institute of Standards and Technology (NIST).

**Primary Focus:** **Cryptography and data security.**
FIPS compliance is primarily about **validating and certifying cryptographic modules and algorithms**. The most important FIPS publications for compliance are:

*   **FIPS 140-3:** *Security Requirements for Cryptographic Modules.* This is the flagship standard. It specifies the security requirements for hardware and software cryptographic modules (e.g., encryption chips, SSL/TLS libraries, encrypted hard drives). Compliance is validated through independent laboratory testing, resulting in an official certificate.
    *   **Levels:** It has 4 security levels (Level 1 to Level 4), with Level 1 being the least stringent (e.g., software encryption) and Level 4 providing the highest protection (e.g., tamper-proof hardware in a hostile physical environment).
*   **FIPS 199 & 200:** Standards for categorizing information systems and setting minimum security requirements.
*   **FIPS 201:** Standard for Personal Identity Verification (PIV) cards for federal employees and contractors.

**In simple terms:** **FIPS answers, "Is your encryption strong and implemented correctly according to the government's approved methods?"** If a product is "FIPS 140-3 Validated," it means its crypto has been rigorously tested and certified.

---

### **STIG (Security Technical Implementation Guide)**
**What it is:** STIGs are detailed, step-by-step configuration guides for securing information systems and software. They are created and maintained by the **Defense Information Systems Agency (DISA)** for the **U.S. Department of Defense (DoD)**. Conformance is required of both __civilian and military__ systems.

**Primary Focus:** **System hardening and secure configuration.**
STIGs provide "checklists" for locking down everything from operating systems (Windows, Linux, Unix) and databases (Oracle, SQL Server) to network devices (routers, switches) and specific applications (like web servers and VMware). The goal is to **reduce the attack surface** by disabling unnecessary services, enforcing strict password policies, configuring audit logging, and applying hundreds of other security settings.

*   **How they work:** Each STIG contains numerous individual security rules (called "Vulnerability IDs" or "VulIDs"), each with a severity rating (CAT I, CAT II, CAT III).
*   **Automation:** Tools like **SCAP (Security Content Automation Protocol)** compliant scanners (e.g., Tenable Nessus, OpenSCAP) can automatically check a system against a STIG and produce a report showing "findings" (non-compliant settings).
*   **Compliance:** To be "STIG compliant," a system must have all CAT I findings remediated and have a plan of action for CAT II/III findings, often documented in a **POA&M (Plan of Action and Milestones)**.

**In simple terms:** **STIGs answer, "Is every single setting on this server, network device, or application configured in the most secure way possible according to DoD standards?"**

---

### Key Differences and Relationship

| Feature | **FIPS** | **STIG** |
| :--- | :--- | :--- |
| **Issuing Body** | NIST (Commerce Department) | DISA (Department of Defense) |
| **Primary Scope** | **Cryptographic modules & algorithms** | **System hardening & configuration** |
| **What it Certifies** | A **specific product's** crypto implementation. | The **configuration state** of an entire system. |
| **Compliance Method** | Independent lab testing and formal validation. | Scanning, manual checks, and documentation. |
| **Typical Requirement** | "Use FIPS 140-3 validated cryptography." | "Harden this Windows Server using the latest Windows STIG." |

**How They Work Together:**
In a DoD environment, compliance often requires **BOTH**.
1.  **FIPS:** Ensures that underlying encryption (e.g., for disk encryption, VPNs, web traffic) is using a certified module.
2.  **STIG:** Ensures that the operating system and applications hosting that FIPS-validated crypto are themselves locked down and securely configured.

For example, a DoD web server must:
*   Use a **FIPS-validated cryptographic module** for its TLS certificates (FIPS 140-3).
*   Have its operating system (e.g., RHEL) hardened according to the **RHEL STIG**.
*   Have its web server (e.g., Apache) hardened according to the **Apache STIG**.

---

### Who Needs to Comply?
*   **Mandatory for:** All U.S. federal agencies (FIPS) and the Department of Defense, its contractors, and the Defense Industrial Base (STIGs). This is enforced via contracts and regulations like **DFARS**.
*   **Common in:** Other high-security industries like aerospace, finance, healthcare, and energy, where these standards are seen as best practices.
*   **Related Framework:** The **Risk Management Framework (RMF)** is the overall DoD process for authorizing systems to operate. **STIG implementation is a core requirement within the RMF process.**

### Summary
*   **FIPS** is about **certified cryptography**.
*   **STIGs** are about **secure configuration checklists** for every part of an IT system.
Together, they form a foundational pillar of U.S. government cybersecurity, ensuring both that strong crypto is used *and* that the systems using it are locked down to prevent compromise.

---

## Military

For U.S. military systems, **STIGs are actually the primary framework**. 
They are **specifically designed for and mandated by DoD**. 
However, the DoD's compliance ecosystem is broader and more rigorous than just STIGs. 
It's a multi-layered, overlapping set of directives, controls, and processes.

Here’s a breakdown of the key frameworks and requirements specific to U.S. military systems, 
building on the FIPS/STIG foundation:

### 1. The Overarching Directive: **DoDI 8500.01** and **DoDI 8510.01**
Everything starts here. These directives establish the **DoD Cybersecurity Program** and mandate the **Risk Management Framework (RMF)** as the official process for managing cybersecurity risk. STIG implementation is a critical activity *within* the RMF process.

### 2. The Core Process: **Risk Management Framework (RMF)**
RMF (defined by **NIST SP 800-37**) is the **six-step lifecycle process** that all DoD information systems must follow:
1.  **Categorize** the system (using FIPS 199/NIST SP 800-60).
2.  **Select** security controls (using the **NIST SP 800-53 control catalog**, tailored by the **Overlay**).
3.  **Implement** the controls (this is where applying STIGs happens).
4.  **Assess** the controls (using STIG checklists with SCAP tools).
5.  **Authorize** the system (the Authorizing Official signs an ATO - Authority to Operate).
6.  **Monitor** continuously.

**Key Point:** STIGs are the primary tool for *implementing* and *assessing* the technical controls selected in RMF Step 2.

### 3. The Control Baseline: **NIST SP 800-53 with DoD Overlays**
*   **NIST SP 800-53:** Provides a massive catalog of security and privacy controls. It's the foundation.
*   **DoD Overlays:** This is the critical military-specific layer. An "overlay" tailors the NIST 800-53 controls for a specific community (like the DoD). The **DoD Overlay** adds **mandatory, stricter requirements** not found in the base NIST guide.
    *   **Example:** NIST 800-53 might say "use encryption where appropriate." The DoD Overlay will specify "use **FIPS 140-3 validated** encryption" and "comply with the **CNSSI 1253** baseline" (see below).

### 4. The Classification & Impact Guide: **CNSSI 1253**
The **Committee on National Security Systems Instruction No. 1253** is the bible for classifying systems that handle **Classified National Security Information (CNSI)**. It defines the **security control baselines** for systems at different classification levels (e.g., Confidential, Secret, Top Secret).
*   It's far more stringent than FIPS 199.
*   It dictates the minimum controls (from **NIST 800-53**) that **must** be implemented for a given system impact level. The DoD Overlay is built upon CNSSI 1253.

### 5. The Program Management Standard: **CMMC (Cybersecurity Maturity Model Certification)**
While STIGs/RMF apply to **information systems**, **CMMC applies to defense contractors (the Defense Industrial Base or DIB)** as an organization.
*   **Goal:** Protect **Controlled Unclassified Information (CUI)** and **Federal Contract Information (FCI)** in contractor networks.
*   **It's a tiered model** (Levels 1-3), with Level 3 requiring the implementation of all 110 security practices from **NIST SP 800-171**, which itself is derived from NIST 800-53.
*   **Connection to STIGs:** A contractor using STIGs to harden their servers that store CUI would be demonstrating compliance with the technical requirements of CMMC Level 3/NIST 800-171.

### 6. Operational & Tactical Directives: **USCYBERCOM Orders**
For warfighting systems and networks, U.S. Cyber Command issues specific orders and directives (e.g., the **Command Cyber Readiness Inspection (CCRI)** program). These are real-world, operational assessments that check if systems deployed in-theater are actually configured according to STIGs and can withstand adversarial attacks.

### The Hierarchy in Practice:
For a new military weapons system or IT network, the compliance flow looks like this:

1.  **Governance:** DoDI 8510.01 says "Use RMF."
2.  **Categorization:** CNSSI 1253 defines how to categorize a system holding Secret data.
3.  **Control Selection:** The DoD Overlay, based on CNSSI 1253, selects the required controls from NIST 800-53.
4.  **Implementation & Assessment:** **STIGs** provide the actionable, step-by-step instructions to meet those technical controls. Tools like ACAS (Nessus) and SCAP check for STIG compliance.
5.  **Authorization:** The system owner documents everything in eMASS (Enterprise Mission Assurance Support Service) and requests an ATO.
6.  **Contractor Support:** If a contractor is building/maintaining the system, they must also meet **CMMC** requirements at the organizational level.

### Summary: The Military-Specific Stack

| Layer | Framework/Directive | Purpose |
| :--- | :--- | :--- |
| **Process** | **Risk Management Framework (RMF)** | The mandatory 6-step lifecycle process for all systems. |
| **Technical Guidance** | **Security Technical Implementation Guides (STIGs)** | The "how-to" checklists for locking down specific technologies. |
| **Control Catalog** | **NIST SP 800-53** + **DoD Overlay** | The "what" - the list of security requirements, tailored for DoD. |
| **Classification Baseline**| **CNSSI 1253** | Defines control baselines for **classified systems**. |
| **Cryptographic Standard**| **FIPS 140-3 / FIPS 201** | Mandates validated crypto and PIV cards. |
| **Contractor Security** | **CMMC / NIST SP 800-171** | Protects sensitive data in the defense supply chain. |
| **Operational Assessment**| **USCYBERCOM Directives (CCRI)** | "Live fire" operational testing and inspections. |

**In essence, STIGs are a *component* of the much larger, more complex military compliance universe.** 
A military system isn't just "STIG compliant" &mdash;it is **RMF-compliant**, implemented using STIGs, authorized under DoD directives, and often managed by CMMC-certified contractors.


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
