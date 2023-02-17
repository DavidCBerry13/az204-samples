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
    public static class CreateTask
    {
        [FunctionName("CreateTask")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = null)] HttpRequest req,
            [CosmosDB(databaseName: "todo-database", collectionName: "tasks", ConnectionStringSetting = "CosmosDbConnectionString")]IAsyncCollector<dynamic> cosmosDb,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger-Create Task");
            
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            TodoItem todoItem = JsonConvert.DeserializeObject<TodoItem>(requestBody);

            todoItem.Partitionkey = "1";
            todoItem.Id = System.Guid.NewGuid().ToString();

            await cosmosDb.AddAsync(todoItem);

 
            return new CreatedResult("", todoItem);
        }


    }
}
