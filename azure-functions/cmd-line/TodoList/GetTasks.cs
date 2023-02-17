using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Collections.Generic;

namespace TodoList
{
    public static class GetTasks
    {
        [FunctionName("GetTasks")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req,
            [CosmosDB(databaseName: "todo-database", collectionName: "tasks", SqlQuery = "SELECT * FROM tasks order by tasks._ts desc", ConnectionStringSetting = "CosmosDbConnectionString")] IEnumerable<TodoItem> tasks,
            //[CosmosDB(databaseName: "todo-database", collectionName: "tasks", ConnectionStringSetting = "CosmosDbConnectionString")]IAsyncCollector<dynamic> tasksCollectionIn,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger-Get all tasks");


            if (tasks is null)
            {
                return new OkObjectResult(new List<TodoItem>());
            }
 
            return new OkObjectResult(tasks);
        }


    }





}
