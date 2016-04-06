App for rating instructors :

App description
This iPhone app  accesses information about instructors and lets people rate them.
Uses a table view to present some identifying information about each instructor. When the
user selects an instructor they get a view of more detailed information about that instructor.
There also is a way to rate an instructor on a scale of 1 to 5 (integer values only) and provide
comments about an instructor. The information available about an instructor is:
First name
Last name
Office
Phone
Email
Rating
Comments

The information is available in JSON format using a REST-like interface via http using the following
urls.
GET urls
http://bismarck.sdsu.edu/rateme/list(server given by Professor)
Returns an json array. Each element of the array is a json object (dictionary). 
The keys of the object are:
id - value is a number
firstName - value is a string
lastName - value is a string
The id is the identifier to be used when referring to the given instructor. 
Here is an example of an object:
{"id":2,"firstName":"Dr. Xyz","lastName":"Abc"}

http://bismarck.sdsu.edu/rateme/comments/n
Returns the comments for the instructor with id "n". The result is a json array of objects.
Each object represents one comment. The object contains keys "text" and "date". The date
is the date the comment was submitted to the server. The text is the actual comment.
Below is a example.
'[{"text":"Good Instructor","date":"10/26/11"},{"text":"do
it","date":"10/25/11"},{"text":"cat","date":"10/24/11"},{"text":"He is
cold","date":"10/24/11"},{"text":"He is hot","date":"10/24/11"}]'

Post URLs
http://bismarck.sdsu.edu/rateme/rating/n/k
Adds the rating "k" to the instructor with id "n". "k" is one of the values 1, 2, 3, 4, or 5.
http://bismarck.sdsu.edu/rateme/comment/n
Adds a comment to the instructor with id "n". The comment is the body of the post.
