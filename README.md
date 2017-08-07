I decided to solve the test by using a series of written steps and some pseudo
code to better illustrate my reasoning.

My first step was to logically split the dataset into the four groups below.
This four groups represents the four different types of products with
overlapping dates. By doing so I was able to reason more easily on how to
proceed and clarify some of my initial assumptions.

```
# Tesco - Gross Sales Price
Value |  From day   |  To day
1     |  01-01-2013 | 10-04-2013
1.5   |  01-03-2013 | 31-12-2013
2     |  01-04-2013 | 01-10-2015

# Tesco - Distribution Cost
Value |  From day   |  To day
5     |  01-01-2013 | 01-04-2013
6     |  01-03-2013 | 01-04-2014
7     |  31-12-2013 | 01-01-2015

# Asda - Gross Sales Price
Value |  From day   |  To day
100   |  00-00-0000 | 99-99-9999
200   |  31-12-2013 | 01-01-2015

# Asda - Distribution Cost
Value |  From day   |  To day
2     |  01-03-2013 | 31-12-2013
3     |  01-04-2014 | 01-01-2013
```

A tree structure like the one below could be also used to represent this
specific dataset.
This makes more evident the fact that this specific data could be interpreted as
a one-to-many relationships where each node has only one parent but possibly
multiple children.

```
                    Widgets

                //           \\

            Tesco             Asda

        //      ||           ||     \\
     Gross  Distribution   Gross   Distribution
     Sales     cost        Sales     cost
     Price                 Price

```

By directly looking at the data and it's structure it's easy to notice that
it's already sorted and grouped by at least 4 out the 6 attributes presents,
more specifically in this order of precedence.

```
Product => Customer => Measure => ?Value? => Valid From Day
```

The attribute "Value" is surrounded by question marks because it is
difficult to tell if it was used as one of the deciding factors while sorting
the data. This comes from the fact that there are no overlapping
"Valid from Date" values between a record and is direct successor. So there is
no certain way to prove that the records are also sorted by "Value", even
thought at first glance it might looks like they are.

A consequent assumption that could be made by looking at this particular set of
data is that this is the result of a very specific query, so any consequent call
to the same query will generate a resulting set of data sorted in same fashion.
See the [Extra Thoughts](#extra_thoughts) section at the end for a possible
solution when the data is not sorted.


So if we take into account this assumption we can leverage it to drastically
reduce the amount of operation needed to find duplicate records with overlapping
dates. This effectively reduce the whole process to a maximum of 4 comparisons
between each record n and the record n + 1.

By further analyzing this particular dataset we can also see that the records
can be grouped under the same "Product" value of "Widgets".
This can be used to help us reduce the maximum number of comparison needed down
from 4 to 3. Even though in this specific case all the records share the same
value of "Widgets", that could not be the case for a different set of data. So
for the purpose of this exercise I decided to ignore it while creating my
solution in order to keep it generic and applicable to any data supplied in this
format.

A solution that reflect the previous assumptions could be expressed in pseudo
code like this:

```
for record in records
  check if record.product == next record.product
    if true check if record.customer == next record.customer
      if true now check if record.measure == next record.measure
        if true now check if record.valid_to_day >= next record.valid_from_day
          if true
            update the record.valid_to_day like so:
            record.valid_to_day = next record.valid_from_day - 1 day
  else
    skip directly to the next record


the previous pseudo code could be refactored into a big one line
if statement with four AND clauses but I reckon that would just
make it harder to reason about

```

Like shown in the previous pseudo code, in order to fix the dates overlapping,
I decided to change the "Valid to Day" value of the record n, by updating it
with the "Valid from Day" value from the record n + 1, minus 1 day.

This decision come from the assumption that the "Value" attribute of each record
represent some sort of price for the product. And a new record is stored in the
system when a new price is set for the same product, together with a starting
date and an estimated end date.
So it would seem reasonable to think that whoever is using this system, in order
to maximize their profit, would want to sell the product at the new and higher
price as soon as the new "Valid from Date" for the new price is reached.
Hence why the new price would take precedence over the old one even if the
"Valid to Date" for the previous price has not been reached yet.

This left me dealing with the record that have 0000-00-00 / 9999-99-99 as dates.
My initial thought was that 9999-99-99 could have been used as some sort of
fallback date. But after doing some research I realized that those two
particular values probably represent a NULL or faulty entry, so I decided that
the way to go would be to treat the 9999-99-99 just like any other date and
update it according the previous rules.

To better illustrate what would be the result of the whole process here is a
table that shows it

![results](https://raw.githubusercontent.com/y0m0/exceedra_tech_test/master/results.png)

##### Extra thoughts
If the assumptions that the data is the result of a very specific query that
always return a sorted dataset was not fulfilled, then I will have to use a
different approach. A possible solution that initially I considered was to sort
the data in the same way it is sorted at the moment, and then proceed to update
the overlapping dates by using the same logic I explained above.
After some consideration I reckon that this approach will probably be best
suited for a larger dataset where the same process have to be run several times.
In that case the cost of the pre-sorting operation wouldn't have a big impact on
efficiency and could in fact greatly reduce the cost of the whole process.
In this specific case where we have only a very small dataset this
operation would probably be way more expensive than simply iterating over the
whole dataset while comparing each single entry against each other.