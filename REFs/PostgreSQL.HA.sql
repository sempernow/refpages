
-- SR : Status @ Sender (Primary)
SELECT redo_lsn,
    slot_name,
    restart_lsn,
    round((redo_lsn-restart_lsn) / 1024 / 1024 / 1024, 2) AS GB_behind
FROM pg_control_checkpoint(),
    pg_replication_slots;

-- Prune WAL files @ Standby server
archive_cleanup_command = pg_archivecleanup /var/lib/postgresql/archive %r 
--| Sets the shell command that will be executed at every restart point.
-- Standalone @ either server 
pg_archivecleanup -d ~/archive 000000010000000000000009.00000028.backup