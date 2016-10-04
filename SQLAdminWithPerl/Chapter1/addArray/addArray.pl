# Initialize the array with a list of strings
@db = ('pubs', 'tempdb', 'master', 'ab-House', '[ad]');

# Add an element to the tail of the array with the push() function.
# 'master' becomes the last element.
push @db, 'master';
print "@db\n";

# Add an element to the head of the array with the unshift() function.
# 'model' becomes the first element of the array
unshift @db, 'model';
print "@db\n";

# [1..$#db] slices the array @db to return the second through the last elements.
# In other words, only the first element is removed.
# Then, 'model' is added to the slice and the rsulting list is assigned to 
# the array @db. This basically replaces the first element of the original array
# @db with 'model'.
@db = ('model', @db[1..$#db]);
print "@db\n";
exit;

grep { print "$_\n"; } @db;
exit;

@db = map { ($_, $_) } grep { /\W/; 1; } @db;
print "@db\n";
exit;

