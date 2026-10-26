set curr_pwd $PWD
set curr_home $HOME
set curr_fifc_query $fifc_query
set curr_fifc_token $fifc_token
set _fifc_complist_path (mktemp)

# A purely-numeric filename is a file, not a PID: completing its numeric
# prefix with a file command must not enter the processes group.
set test_dir (mktemp -d)
touch "$test_dir/123"
cd "$test_dir"
set _commandline "mv 12"
complete -C --escape -- "$_commandline" >$_fifc_complist_path
set fifc_commandline "$_commandline"
set fifc_token 12
set actual (_fifc_completion_group)
@test "group test numeric file is not processes" "$actual" != processes

# An unmatched numeric token leaves fish's completion list empty: the PID
# branch never fires, so no picker is offered.
set _commandline "mv 99"
complete -C --escape -- "$_commandline" >$_fifc_complist_path
set fifc_commandline "$_commandline"
set fifc_token 99
set actual (_fifc_completion_group)
@test "group test unmatched numeric token is empty" "$actual" = ""

# PID completions are unaffected: no file collides in a clean directory.
set test_dir2 (mktemp -d)
cd "$test_dir2"
set _commandline "kill 2"
complete -C --escape -- "$_commandline" >$_fifc_complist_path
set fifc_commandline "$_commandline"
set fifc_token 2
set actual (_fifc_completion_group)
@test "group test pid completion stays processes" "$actual" = processes

# Command-aware classification: PID-argument commands win even when a
# numeric file with the same number exists in the cwd.
set test_dir3 (mktemp -d)
touch "$test_dir3/1" "$test_dir3/123"
cd "$test_dir3"

set _commandline "kill 1"
complete -C --escape -- "$_commandline" >$_fifc_complist_path
set fifc_commandline "$_commandline"
set fifc_token 1
set actual (_fifc_completion_group)
@test "group test kill wins over numeric file" "$actual" = processes

set _commandline "sudo kill 1"
complete -C --escape -- "$_commandline" >$_fifc_complist_path
set fifc_commandline "$_commandline"
set fifc_token 1
set actual (_fifc_completion_group)
@test "group test sudo kill wins over numeric file" "$actual" = processes

# ... while a file command still completes the numeric file.
set _commandline "mv 1"
complete -C --escape -- "$_commandline" >$_fifc_complist_path
set fifc_commandline "$_commandline"
set fifc_token 1
set actual (_fifc_completion_group)
@test "group test mv with numeric file stays file" "$actual" != processes

cd "$curr_pwd"
set fifc_query $curr_fifc_query
set fifc_token $curr_fifc_token
command rm -rf "$test_dir" "$test_dir2" "$test_dir3"
command rm $_fifc_complist_path
