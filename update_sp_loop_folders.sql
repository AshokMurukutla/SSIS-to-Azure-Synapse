ALTER PROCEDURE [dbo].[sp_loop_folders]
as 
BEGIN

	-- Scripts to create environments and its variables in all folders

	IF EXISTS(select 1 from [SSISDB].[internal].environments)
	BEGIN
		CREATE TABLE #temp_folder_env(
			Id int identity(1,1),
			Folder nvarchar(max),
			Environment nvarchar(max)
			)


		INSERT INTO #temp_folder_env (Folder, Environment) SELECT fol.name, env.environment_name FROM [SSISDB].[internal].environments env JOIN [SSISDB].[internal].folders fol ON env.folder_id=fol.folder_id

		DECLARE @Init int= 1,
				@NumRows int,
				@folder_name sysname,
				@env_name sysname

		SELECT @NumRows=COUNT(*) FROM #temp_folder_env

		WHILE @Init<= @NumRows
		BEGIN
			SELECT @folder_name=Folder, @env_name=Environment FROM #temp_folder_env WHERE Id=@Init
			EXEC [dbo].[usp_SSIS_ScriptEnvironment] @folder=@folder_name, @env=@env_name
			SET @Init = @Init+1
		END

		DROP TABLE #temp_folder_env
	END




	-- Scripts to generate adding environment references

	IF EXISTS(select 1 from [SSISDB].[internal].environments)
	BEGIN
		CREATE TABLE #temp_folder_env2(
			Id int identity(1,1),
			Folder nvarchar(max)
			)


		INSERT INTO #temp_folder_env2 (Folder) SELECT fol.name FROM [SSISDB].[internal].folders fol

		SET @Init=1

		SELECT @NumRows=COUNT(*) FROM #temp_folder_env2

		WHILE @Init<= @NumRows
		BEGIN
			SELECT @folder_name=Folder FROM #temp_folder_env2 WHERE Id=@Init
			EXEC [dbo].[usp_SSIS_ScriptEnvironmentReference] @folder = @folder_name
			SET @Init = @Init+1
		END

		DROP TABLE #temp_folder_env2
	END



	-- Scripts to generate reference mapping variables
	
	IF EXISTS(select 1 from [SSISDB].[internal].environments)
	BEGIN
		CREATE TABLE #temp_folder_env3(
			Id int identity(1,1),
			Folder nvarchar(max)
			)


		INSERT INTO #temp_folder_env3 (Folder) SELECT fol.name FROM [SSISDB].[internal].folders fol

		SET @Init=1

		SELECT @NumRows=COUNT(*) FROM #temp_folder_env3

		WHILE @Init<= @NumRows
		BEGIN
			SELECT @folder_name=Folder FROM #temp_folder_env3 WHERE Id=@Init
			EXEC [dbo].[usp_SSIS_ScriptEnvironmentReferenceMappings] @folder = @folder_name
			SET @Init = @Init+1
		END

		DROP TABLE #temp_folder_env3
	END

	RETURN 0
END



  