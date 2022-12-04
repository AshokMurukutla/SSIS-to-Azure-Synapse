update_sp_loop_folders stored procedure will loop ScriptEnvironment_updated, ScriptEnvironmentReference_updated, and ScriptEnvironmentReferenceMappings_updated stored procedure. And will generate scripts for each folder.
ScriptEnvironment_updated stored procedure will create folders and environments if not existed.
ScriptEnvironmentReference_updated stored procedure will create scripts for environment references if not existed.
ScriptEnvironmentReferenceMappings_updated stored procedure will create scripts for environment reference mappings if not existed.
Running update_sp_loop_folders stored procedure is enough as it wll call remaining three stored procedures inside this and looped for each folder.
