# This little script shows three different ways to access elements of an array

# Initialize the array @db
@db = ('master', 'pubs', 'tempdb');

# Print the 2nd and 3rd elements.
# This is a so-called slice of the array.
print "@db[1,2]\n";

# Get the first element with the shift() function, and print it
print shift @db, "\n";

# Initialize the array @db
@db = ('master', 'pubs', 'tempdb');

# Get the last element with the pop() function, and print it
print pop @db, "\n"
