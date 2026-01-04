#!/usr/bin/env bash

#**********************
#  DEPRICATED 
#**********************

# Create a custom postgresql.conf and overwrite that at PATH_ABS_CTNR_PGDATA, as a string.
# (No mounts required. No source-file upload the target's docker host.)
cat ~/data/postgresql.conf |sed '/^[#]/d' \
	|sed '/^\s*$/d' |sed '/#/d' > ~/new.postgresql.conf
cp ~/new.postgresql.conf ~/data/postgresql.conf


# Overwrite : postgresql.conf
$1 bash -c "
	echo \"$src\" > "$tgt"
	echo '=== @ postgresql.conf'
	cat         $tgt
"
# Append : postgresql.auto.conf
$1 bash -c "
	psql -c \"ALTER SYSTEM SET listen_addresses TO '${PGHA_HOST1},${PGHA_HOST2}';\"
	psql -c \"ALTER SYSTEM SET archive_command TO 'cp %p ${PATH_ABS_CTNR_PGARCHIVE}/%f';\"
	psql -c \"ALTER SYSTEM SET archive_cleanup_command TO 'pg_archivecleanup ${PATH_ABS_CTNR_PGARCHIVE} %r';\"
	psql -c \"ALTER SYSTEM SET restore_command TO 'cp ${PATH_ABS_CTNR_PGARCHIVE}/%f %p';\"
	echo '=== @ postgresql.auto.conf'
	cat '${PATH_ABS_CTNR_PGDATA}/postgresql.auto.conf'
"