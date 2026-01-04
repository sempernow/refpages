# GitLab : Synch Projects Between Air-gap Networks

# Q:

What is the advised Group structure for GitLab self-hosted instance on air-gap network where development projects recurringly cherry pick from their asynchronous twin copied in on another air-gap network?

# A:

When setting up a GitLab self-hosted instance on an air-gapped network where development projects frequently cherry-pick from an asynchronous twin copied on another air-gapped network, the group structure should be designed to ensure efficient collaboration, security, and maintainability. Below is an advised group structure and workflow:

---

### **1. Group Structure**
The group structure should reflect the separation of concerns, security boundaries, and the need for synchronization between the two air-gapped networks.

#### **Top-Level Groups**
- **Network A Group**: Represents the primary air-gapped network where active development occurs.
- **Network B Group**: Represents the secondary air-gapped network where the asynchronous twin resides.

#### **Subgroups**
Under each top-level group, create subgroups based on:
- **Projects/Teams**: Organize by development teams or projects.
- **Environments**: Separate by environments (e.g., `dev`, `staging`, `prod`).
- **Functionality**: Group by functionality (e.g., `frontend`, `backend`, `infrastructure`).

Example:
```
Network A Group
├── Team 1
│   ├── Project A
│   └── Project B
├── Team 2
│   ├── Project C
│   └── Project D
└── Infrastructure
    ├── Terraform
    └── CI/CD

Network B Group
├── Team 1
│   ├── Project A
│   └── Project B
├── Team 2
│   ├── Project C
│   └── Project D
└── Infrastructure
    ├── Terraform
    └── CI/CD
```

---

### **2. Repository Setup**
- **Mirror Repositories**: Use GitLab's repository mirroring feature to keep the repositories in sync between the two networks. This ensures that changes in one network can be cherry-picked in the other.
- **Read-Only Mirror for Network B**: Configure the mirror in Network B as read-only to prevent accidental changes.
- **Branches**: Use consistent branch naming conventions across both networks to simplify cherry-picking.

---

### **3. Access Control**
- **Network Separation**: Ensure strict access control between the two networks. Only authorized personnel should have access to both networks.
- **Permissions**: Use GitLab's role-based access control (RBAC) to restrict access to sensitive repositories and environments.
- **Audit Logs**: Enable audit logs to track changes and access across both networks.

---

### **4. Cherry-Picking Workflow**
- **Cherry-Pick Process**: Developers in Network A can cherry-pick changes from Network B by:
  1. Pulling the latest changes from the mirrored repository in Network B.
  2. Using `git cherry-pick <commit-hash>` to apply specific changes.
  3. Pushing the changes to the appropriate branch in Network A.
- **Automation**: Consider automating the cherry-pick process using GitLab CI/CD pipelines to reduce manual effort and errors.

---

### **5. CI/CD Pipeline**
- **Network-Specific Pipelines**: Configure separate CI/CD pipelines for each network to account for differences in environments and security requirements.
- **Synchronization Jobs**: Include jobs in the pipeline to periodically sync repositories between the two networks.
- **Validation**: Add validation steps to ensure that cherry-picked changes do not break the build or introduce vulnerabilities.

---

### **6. Backup and Disaster Recovery**
- **Regular Backups**: Schedule regular backups of both GitLab instances to prevent data loss.
- **Disaster Recovery Plan**: Develop a disaster recovery plan to restore the GitLab instance in case of failure.

---

### **7. Documentation and Training**
- **Documentation**: Maintain detailed documentation of the group structure, workflows, and access controls.
- **Training**: Train developers and administrators on the cherry-pick process, security protocols, and CI/CD pipelines.

---

### **8. Security Considerations**
- **Air-Gap Compliance**: Ensure that the setup complies with the security policies of the air-gapped networks.
- **Vulnerability Scanning**: Regularly scan repositories for vulnerabilities.
- **Secrets Management**: Use GitLab's secrets management or an external tool to securely manage credentials.

---

By following this structure and workflow, you can maintain a secure, efficient, and scalable GitLab setup across two air-gapped networks while enabling seamless cherry-picking of changes.



# Q: 

Some argue to simply extract projects locally and merge into target domain project to avoid having twin projects.

# A:

The approach of extracting projects locally and merging them into the target domain project, rather than maintaining twin projects, can be a valid alternative depending on your specific requirements, constraints, and workflows. This approach simplifies the architecture by avoiding the need to maintain two separate GitLab instances or mirrored repositories. However, it comes with its own trade-offs. Below, I’ll outline the pros, cons, and considerations for this approach, as well as how it compares to maintaining twin projects.

---

### **Approach: Extract Projects Locally and Merge into Target Domain**
In this approach, instead of maintaining twin projects across two air-gapped networks, you:
1. Extract the necessary code or changes from the source project (e.g., Network B) onto a local machine or intermediary storage.
2. Transfer the extracted changes to the target network (e.g., Network A) using secure methods (e.g., USB drives, secure file transfer).
3. Merge the changes into the target project manually or via scripts.

---

### **Advantages of This Approach**
1. **Simplified Architecture**:
   - No need to maintain two separate GitLab instances or mirrored repositories.
   - Reduces complexity in managing synchronization and access controls between networks.

2. **Reduced Overhead**:
   - Avoids the overhead of maintaining twin projects, including repository mirroring, access control, and CI/CD pipeline synchronization.

3. **Security**:
   - Limits exposure between the two air-gapped networks, as there is no direct connection or synchronization.
   - Reduces the risk of accidental data leakage or unauthorized access.

4. **Flexibility**:
   - Allows selective merging of changes, which can be useful if only specific features or fixes need to be transferred.

---

### **Disadvantages of This Approach**
1. **Manual Effort**:
   - Requires manual extraction, transfer, and merging of changes, which can be time-consuming and error-prone.
   - Increases the risk of human error during the process.

2. **Lack of Traceability**:
   - Changes merged manually may not be tracked as effectively as those managed through GitLab’s native features (e.g., merge requests, commit history).
   - Makes it harder to audit changes and maintain a clear history.

3. **Inconsistencies**:
   - Without proper synchronization, the source and target projects may diverge over time, leading to inconsistencies.
   - Increases the risk of merge conflicts and integration issues.

4. **Limited Automation**:
   - Difficult to automate the process of extracting, transferring, and merging changes, which can slow down development workflows.

5. **Scalability Issues**:
   - This approach may not scale well for large teams or projects with frequent changes.

---

### **When to Use This Approach**
This approach is best suited for:
- Small teams or projects with infrequent changes.
- Environments where security requirements prohibit any form of synchronization between networks.
- Scenarios where only selective changes need to be transferred (e.g., hotfixes, specific features).

---

### **Comparison with Twin Projects**
| **Aspect**               | **Twin Projects**                          | **Extract and Merge**                     |
|--------------------------|--------------------------------------------|-------------------------------------------|
| **Complexity**           | Higher (requires synchronization)          | Lower (no synchronization needed)         |
| **Manual Effort**        | Lower (automated sync and cherry-picking)  | Higher (manual extraction and merging)    |
| **Traceability**         | Better (native GitLab features)            | Limited (manual tracking required)        |
| **Security**             | Requires careful access control            | Simpler (no direct connection)            |
| **Scalability**          | Better for large teams/projects            | Less scalable                             |
| **Consistency**          | Easier to maintain consistency             | Higher risk of inconsistencies            |

---

### **Hybrid Approach**
If neither approach fully meets your needs, consider a hybrid approach:
1. **Maintain Twin Projects for Core Repositories**:
   - Use repository mirroring for critical projects that require frequent synchronization.
2. **Extract and Merge for Less Critical Projects**:
   - Use the extract-and-merge approach for smaller or less frequently updated projects.

---

### **Recommendations**
- **Evaluate Your Workflow**: Assess how often changes need to be transferred and the complexity of your projects.
- **Prioritize Security**: Ensure that the chosen approach complies with your organization’s security policies.
- **Document Processes**: Clearly document the steps for extracting, transferring, and merging changes to reduce errors.
- **Consider Automation**: Even in an extract-and-merge approach, explore ways to automate parts of the process (e.g., scripts for merging changes).

---

Ultimately, the choice between maintaining twin projects and extracting/merging locally depends on your specific requirements, team size, and security constraints. If simplicity and security are your top priorities, the extract-and-merge approach may be a better fit. However, if you need scalability, traceability, and automation, maintaining twin projects with proper synchronization is likely the better choice.

### &nbsp;
