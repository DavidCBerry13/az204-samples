# TaskManager Azure Functions App


## Install the Azure Functions Core Tools

These have a runtime that allows you to run functions locally and gives you the command line tools for functions.

[https://go.microsoft.com/fwlink/?linkid=2174087](https://go.microsoft.com/fwlink/?linkid=2174087)

## Install the Azure Cosmos DB Emulator

This example uses a Cosmos Database.  You can develop locally by installing the CosmosDB emulator.

[Instructions on installing the Cosmos DB Emulator for local development](https://learn.microsoft.com/en-us/azure/cosmos-db/local-emulator?tabs=ssl-netstd21)

After the emulator is installed, you can manage you local Cosmos databases at the URL [https://localhost:8081/_explorer/index.html](https://localhost:8081/_explorer/index.html).

Once the functions app is setup, you can specify the connection string for the Cosmos DB for local development in the `local.settings.json` file.

```json
{
    "IsEncrypted": false,
    "Values": {
        "AzureWebJobsStorage": "UseDevelopmentStorage=true",
        "FUNCTIONS_WORKER_RUNTIME": "dotnet",
        "CosmosDbConnectionString": "<cosmos-db-connection-string>"
    }
}
```

## Create a New Functions project

The `func init` command in the Azure Functions Tools is used to create a new Functions project.  Use `func init --help` to see all the options.

```bash
func init <project-name> --dotnet
```

The functions project will be created in a directory with the name name of <project-name>.

For this application, the following command was used.

```bash
func init TaskListManager --dotnet
```

## Add functions in the Functions project

First, change into the Functions project directory.  Then use the `func new` command to create a new function.

Each time the `func new` command is run, it will create a new function file, \<function-name>.cs.  There is one function per file.

```shell
func new --name HttpExample --template "HTTP trigger" --authlevel "anonymous"
```

To list the available templates, use the `func templates list` command.


This app uses three different functions, so the `func new` command is run three times.

```shell
func new --name GetTasks --template "HTTP trigger" --authlevel "anonymous"
func new --name GetTaskById --template "HTTP trigger" --authlevel "anonymous"
func new --name CreateTask --template "HTTP trigger" --authlevel "anonymous"
```

## Adding NuGet Packages

If you need to add a NuGet package, use the `dotnet add` command from the .NET CLI.

```shell
dotnet add Microsoft.Azure.WebJobs.Extensions.CosmosDB
```

## Run the Functions app

```bash
func start
```
