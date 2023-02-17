using System;

namespace TodoList
{


    public class TodoItem
    {

        public string Partitionkey { get; set; }


        public string Id { get; set;}

        public string Title { get; set;}

        public string Description { get; set; }


        public DateTime? CreateDate { get; set; }

        public DateTime? DueDate { get; set; }

        public string Status { get; set; }
        

    }


}