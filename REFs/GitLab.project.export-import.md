# [GitLab Migrate : Project Export/Import](https://docs.gitlab.com/user/project/settings/import_export/ "docs.gitlab.com")

Regarding __development across two air-gapped networks__, 
automate the transfer of projects between two air-gapped GitLab instances 
(one-way from `gitlab.a.lan` to `gitlab.b.lan`) 
while ensuring proper group and subgroup mapping and creation. 

- From: `gitlab.a.lan/group-a/x/project-1`
- To: `gitlab.b.lan/group-b/y/project-1` 
    - Path (`path_with_namespace`) may not yet exist. 

The process involves exporting projects from the source GitLab, 
transferring the exported files, then importing them into the destination GitLab, 
and potentially creating any necessary groups and subgroups in the destination GitLab before import.

Here's a step-by-step breakdown to automate this using scripting:

### 1. Export the Project from Source GitLab (`gitlab.a.lan`)

Use the GitLab API to export the project. 
This will create an export file that you can download once the export is complete.

```bash
origin=https://gitlab.a.lan

# Trigger export
curl -X POST -H "PRIVATE-TOKEN: $a_access_token" "$origin/api/v4/projects/$project_id/export"

# Check export status and download when ready
while :;do
    export_status=$(curl -H "PRIVATE-TOKEN: $a_access_token" "$origin/api/v4/projects/$project_id/export")
    if [[ $export_status == *"finished"* ]]; then
        curl -H "PRIVATE-TOKEN: $a_access_token" "$origin/api/v4/projects/$project_id/export/download" -o prj.$project_id.tar.gz
        break
    fi
    sleep 10
done
```

### 2. Transfer the Export File

Transfer the exported `.tar.gz` file to the destination network. 
This might involve physical media like a USB drive, depending on your air-gap protocols.

### 3. Check and Create Group/Subgroup on Destination GitLab (`gitlab.b.lan`)

Before you can import the project, ensure that the target group/subgroup structure exists. If not, create it using API calls.

```bash
origin=https://gitlab.b.lan

# Function to create group if it does not exist
create_group_if_not_exists() {
    local parent_id="$1"
    local group_path="$2"
    local group_name="$3"

    # Check if group exists
    existing_group=$(curl -sH "PRIVATE-TOKEN: $b_access_token" "$origin/api/v4/groups?search=$group_path")

    if [[ -z $existing_group ]];then
        # Create group
        create_group=$(curl -sX POST -H "PRIVATE-TOKEN: $b_access_token" "$origin/api/v4/groups" --form "name=$group_name" --form "path=$group_path" --form "parent_id=$parent_id")
        echo $(echo $create_group |jq -Mr '.id')
    else
        echo $(echo $existing_group |jq -Mr '.[0].id')
    fi
}

# Example usage for group and subgroup
parent_id=$(create_group_if_not_exists "" "group-b" "Group B")
subgroup_id=$(create_group_if_not_exists "$parent_id" "y" "Subgroup Y")
```

### 4. Import Project to Destination GitLab

Once the required groups are confirmed or created, 
import the project into the appropriate subgroup.

```bash
origin=https://gitlab.b.lan

# Import project
curl -sX POST -H "PRIVATE-TOKEN: $b_access_token" "$origin/api/v4/projects/import" --form "namespace_id=$subgroup_id" --form "path=project-1" --form "file=@/path/to/project_export.tar.gz"
```

### 5. Script and Schedule

Combine the above scripts into a single script or set of scripts. You'll need to handle parameters like project IDs and tokens securely. You can schedule these scripts to run at regular intervals using cron jobs on Unix/Linux systems or Task Scheduler on Windows, depending on your environment.

### Security Considerations

- Ensure that access tokens used in scripts are secured and have minimal permissions necessary to perform the operations.
- Consider using secure storage for scripts and credentials, such as vault solutions or encrypted storage.
- Validate all data transferred between networks to avoid security risks.

By following these steps, you can automate the one-way transfer of projects between two air-gapped GitLab instances, 
handling differences in group and subgroup paths dynamically.



### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

