using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace TodoList
{
    public static class GetTaskById
    {
        [FunctionName("GetTaskById")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req,
            [CosmosDB(databaseName: "todo-database", collectionName: "tasks", Id = "{Query.id}", PartitionKey = "1", ConnectionStringSetting = "CosmosDbConnectionString")] TodoItem task,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger-Get task by id");
            
            if (task is null)
            {
                return new NotFoundResult();
            }
 
            return new OkObjectResult(task);
        }

    }
}
