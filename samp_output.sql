
/**************************************************************************************
    This script creates a script to generate and SSIS Environment and its variables.
    Replace the necessary entries to create a new envrionment
    ***NOTE: variables marked as sensitive have their values masked with '<REPLACE_ME>'.
        These values will need to be replace with the actual values
**************************************************************************************/

DECLARE @ReturnCode INT=0, @folder_id bigint

/*****************************************************
    Variable declarations, make any changes here
*****************************************************/
DECLARE @folder sysname = 'TestFOLDER' /* this is the name of the new folder you want to create */
        , @env sysname = 'test' /* this is the name of the new environment you want to create */
        , @env_var nvarchar= N'test'
        , @env_var_2 nvarchar= N'test2'
;
/* Starting the transaction */
BEGIN TRANSACTION
    IF NOT EXISTS (SELECT 1 FROM [SSISDB].[internal].[folders] WHERE name = @folder)
    BEGIN
        RAISERROR('Creating folder: %s ...', 10, 1, @folder) WITH NOWAIT;
        EXEC @ReturnCode = [SSISDB].[catalog].[create_folder] @folder_name=@folder, @folder_id=@folder_id OUTPUT
        IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;
    END

    RAISERROR('Creating Environtment: %s', 10, 1, @env) WITH NOWAIT;
    IF NOT EXISTS (SELECT 1 FROM [SSISDB].[internal].[environments] env INNER JOIN [SSISDB].[internal].[folders] fol ON env.folder_id=fol.folder_id WHERE environment_name = @env and name=@folder)
    BEGIN
        EXEC @ReturnCode = [SSISDB].[catalog].[create_environment] @folder_name=@folder, @environment_name=@env
        IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

    END

    /******************************************************
        Variable creation
    ******************************************************/
    RAISERROR('Creating variable: env_var ...', 10, 1) WITH NOWAIT;
    IF NOT EXISTS (SELECT 1 FROM [SSISDB].[internal].[environment_variables] env_var INNER JOIN [SSISDB].[internal].[environments] env ON  env_var.environment_id=env.environment_id INNER JOIN [SSISDB].[internal].[folders] fol ON env.folder_id=fol.folder_id where env.environment_name=N'test' and fol.name = N'TestFOLDER' and env_var.name = N'env_var')    BEGIN
        EXEC @ReturnCode = [SSISDB].[catalog].[create_environment_variable]
            @variable_name=N'env_var'
            , @sensitive=0
            , @description=N''
            , @environment_name=@env
            , @folder_name=@folder
            , @value=@env_var
            , @data_type=N'String'
        IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;
    END


    RAISERROR('Creating variable: env_var_2 ...', 10, 1) WITH NOWAIT;
    IF NOT EXISTS (SELECT 1 FROM [SSISDB].[internal].[environment_variables] env_var INNER JOIN [SSISDB].[internal].[environments] env ON  env_var.environment_id=env.environment_id INNER JOIN [SSISDB].[internal].[folders] fol ON env.folder_id=fol.folder_id where env.environment_name=N'test' and fol.name = N'TestFOLDER' and env_var.name = N'env_var_2')    BEGIN
        EXEC @ReturnCode = [SSISDB].[catalog].[create_environment_variable]
            @variable_name=N'env_var_2'
            , @sensitive=0
            , @description=N''
            , @environment_name=@env
            , @folder_name=@folder
            , @value=@env_var_2
            , @data_type=N'String'
        IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;
    END


COMMIT TRANSACTION
RAISERROR(N'Complete!', 10, 1) WITH NOWAIT;
GOTO EndSave

QuitWithRollback:
IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
RAISERROR(N'Variable creation failed', 16,1) WITH NOWAIT;

EndSave:
GO

/**************************************************************************************
    This script creates a script to generate and SSIS Environment references.
    Replace the necessary entries to create a new envrionment reference
        These values will need to be replace with the actual values
**************************************************************************************/

DECLARE @ReturnCode INT=0, @folder_id bigint

/*****************************************************
    Variable declarations, make any changes here
*****************************************************/
DECLARE @folder sysname = 'TestFOLDER' /* this is the name of the new folder you want to create */
DECLARE @reference_id bigint

;
/* Starting the transaction */
BEGIN TRANSACTION
    /******************************************************        Environment references creation
    ******************************************************/
 
COMMIT TRANSACTION
RAISERROR(N'Complete!', 10, 1) WITH NOWAIT;
GOTO EndSave

QuitWithRollback:
IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
RAISERROR(N'Variable creation failed', 16,1) WITH NOWAIT;

EndSave:
GO

/**************************************************************************************
    This script creates a script to generate and SSIS Environment references mappings.
    Replace the necessary entries to create a new envrionment reference mappings
        These values will need to be replace with the actual values
**************************************************************************************/

DECLARE @ReturnCode INT=0, @folder_id bigint

/*****************************************************
    Variable declarations, make any changes here
*****************************************************/
DECLARE @folder sysname = 'TestFOLDER' /* this is the name of the new folder you want to create */
DECLARE @reference_id bigint

;
/* Starting the transaction */
BEGIN TRANSACTION
    /******************************************************        Environment references mappings creation
    ******************************************************/
    IF NOT EXISTS (SELECT 1 FROM [SSISDB].[internal].[object_parameters] WHERE parameter_name = 'p_test' and project_id = '1' and object_name = 'test_lift_and_shift')
    BEGIN
    EXEC @ReturnCode = [SSISDB].[catalog].[set_object_parameter_value]
        @object_type=20
        , @parameter_name=N'p_test'
        , @object_name=N'test_lift_and_shift'
        , @folder_name=N'TestFOLDER'
        , @project_name=N'test_lift_and_shift'
        , @value_type = N'R'
        , @parameter_value=N'env_var'
    END

    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

    IF NOT EXISTS (SELECT 1 FROM [SSISDB].[internal].[object_parameters] WHERE parameter_name = 'p_test2' and project_id = '1' and object_name = 'test_lift_and_shift')
    BEGIN
    EXEC @ReturnCode = [SSISDB].[catalog].[set_object_parameter_value]
        @object_type=20
        , @parameter_name=N'p_test2'
        , @object_name=N'test_lift_and_shift'
        , @folder_name=N'TestFOLDER'
        , @project_name=N'test_lift_and_shift'
        , @value_type = N'R'
        , @parameter_value=N'env_var_2'
    END

    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

    IF NOT EXISTS (SELECT 1 FROM [SSISDB].[internal].[object_parameters] WHERE parameter_name = 'test' and project_id = '1' and object_name = 'Package1.dtsx')
    BEGIN
    EXEC @ReturnCode = [SSISDB].[catalog].[set_object_parameter_value]
        @object_type=30
        , @parameter_name=N'test'
        , @object_name=N'Package1.dtsx'
        , @folder_name=N'TestFOLDER'
        , @project_name=N'test_lift_and_shift'
        , @value_type = N'R'
        , @parameter_value=N'env_var'
    END

    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

    IF NOT EXISTS (SELECT 1 FROM [SSISDB].[internal].[object_parameters] WHERE parameter_name = 'test2' and project_id = '1' and object_name = 'Package1.dtsx')
    BEGIN
    EXEC @ReturnCode = [SSISDB].[catalog].[set_object_parameter_value]
        @object_type=30
        , @parameter_name=N'test2'
        , @object_name=N'Package1.dtsx'
        , @folder_name=N'TestFOLDER'
        , @project_name=N'test_lift_and_shift'
        , @value_type = N'R'
        , @parameter_value=N'env_var_2'
    END

    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

COMMIT TRANSACTION
RAISERROR(N'Complete!', 10, 1) WITH NOWAIT;
GOTO EndSave

QuitWithRollback:
IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
RAISERROR(N'Variable creation failed', 16,1) WITH NOWAIT;

EndSave:
GO

