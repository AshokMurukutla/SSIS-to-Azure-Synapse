/****** Object:  StoredProcedure [dbo].[usp_SSIS_ScriptEnvironmentReference]    Script Date: 23-08-2022 12:34:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[usp_SSIS_ScriptEnvironmentReference]
          @folder sysname
AS
        SET NOCOUNT ON;
        DECLARE @sql varchar(max) = '',
                @name sysname,
                @cr char(1) = char(10),
                @tab char(4) = SPACE(4),
                @ver nvarchar(128) = CAST(serverproperty('ProductVersion') AS nvarchar);
        SET @ver = CAST(SUBSTRING(@ver, 1, CHARINDEX('.', @ver) - 1) as int);       
        IF (@ver < 11)
        BEGIN
                RAISERROR ('This procedure is not supported on versions prior SQL 2012', 16, 1) WITH NOWAIT;
                RETURN 1;
        END;
        IF NOT EXISTS(SELECT TOP 1 1 FROM sys.databases WHERE name = 'SSISDB')
        BEGIN
                RAISERROR('The SSISDB database does not exist on this server', 16, 1) WITH NOWAIT;
                RETURN 1;
        END;
        /* TO DO - get the folder, environment description-*/        SET @sql = '/**************************************************************************************' + @cr;
        SET @sql += @tab + 'This script creates a script to generate and SSIS Environment references.' + @cr;
        SET @sql += @tab + 'Replace the necessary entries to create a new envrionment reference' + @cr;
        SET @sql += @tab + @tab + 'These values will need to be replace with the actual values' + @cr;
        SET @sql += '**************************************************************************************/' + @cr +@cr;
        SET @sql += 'DECLARE @ReturnCode INT=0, @folder_id bigint' + @cr + @cr;       
        SET @sql += '/*****************************************************' + @cr;
        SET @sql += @tab + 'Variable declarations, make any changes here' + @cr;
        SET @sql += '*****************************************************/' + @cr;
        SET @sql += 'DECLARE @folder sysname = ''' + @folder + ''' /* this is the name of the new folder you want to create */'  + @cr;
		SET @sql += 'DECLARE @reference_id bigint'  + @cr;
       
        PRINT @sql;

        SET @sql = ';' + @cr + '/* Starting the transaction */' + @cr;
        SET @sql += 'BEGIN TRANSACTION' + @cr;                          
		SET @sql += @tab + '/******************************************************' ; 
        SET @sql += @tab + @tab + 'Environment references creation' + @cr;
        SET @sql += @tab + '******************************************************/' ;     
        PRINT @sql;
        /* Generate the Environment references creation */        SELECT [cmd] = @tab + 'IF NOT EXISTS (SELECT 1 FROM [SSISDB].[internal].[environment_references] WHERE environment_name = ''' + enr.environment_name + ''')' + @cr
										+ @tab + 'BEGIN' + @cr
										+ @tab + 'EXEC @ReturnCode = [SSISDB].[catalog].[create_environment_reference]' + @cr
                                        + @tab + @tab + '@folder_name=N''' + fol.name + '''' + @cr
                                        + @tab + @tab + ', @project_name=N''' + prj.name + '''' + @cr
                                        + @tab + @tab + ', @environment_name=N''' + enr.environment_name + '''' + @cr
                                        + @tab + @tab + ', @reference_type=N''' + enr.reference_type + '''' + @cr
                                        + @tab + @tab + ', @environment_folder_name=N''' + enr.environment_folder_name + '''' + @cr
										+ @tab + @tab + ', @reference_id = @reference_id output' + @cr
										+ @tab + 'END' + @cr + @cr
                                        + @tab + 'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback2;' + @cr
										
                                , [name] = enr.environment_name
        INTO #cmd
        from [SSISDB].[internal].[environment_references] enr 
		INNER JOIN [SSISDB].[internal].[projects] prj ON enr.project_id=prj.project_id
		INNER JOIN [SSISDB].[internal].[folders] fol ON prj.folder_id=fol.folder_id  
        WHERE (fol.name = @folder);
        /*Print out the Environment references creation procs */        WHILE EXISTS (SELECT TOP 1 1 FROM #cmd)
        BEGIN
                SELECT TOP 1 @sql = cmd, @name = name FROM #cmd ORDER BY name;
                PRINT @sql;
               
                DELETE FROM #cmd WHERE name = @name;
        END;
        /* finsih the transaction handling */        SET @sql = 'COMMIT TRANSACTION' + @cr;
        SET @sql += 'RAISERROR(N''Complete!'', 10, 1) WITH NOWAIT;' + @cr;
        SET @sql += 'GOTO EndSave' + @cr + @cr;
        SET @sql += 'QuitWithRollback2:' + @cr;
        SET @sql += 'IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION' + @cr;
        SET @sql += 'RAISERROR(N''Variable creation failed'', 16,1) WITH NOWAIT;' + @cr + @cr;
        SET @sql += 'EndSave:' + @cr;
        SET @sql += 'GO';
       
        PRINT @sql;
        RETURN 0;
GO


