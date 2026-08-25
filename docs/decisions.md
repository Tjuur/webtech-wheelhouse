# Decisions

## Can a Repair Include Work That Is Not on the Standard Service List?

The description explains that the shop has a standard list of services and prices, but it does not specify whether every repair must use only those predefined services. I assumed that all charged work must correspond to a service on the standard list.

If mechanics are allowed to add custom work that is not on the service list, the model would need to change so that a repair can store a custom service description and price without requiring an existing Service record.

## Can Multiple Mechanics Work on a Repair?

There where no specifications on how many mechanics may work on a singular repair, so I assumed that only there is only one per repair.

If more than one mechanic can work on any given repair, then the relationship between mechanics and repair would change to many-to-many. 

## Does the Ownership History Matter?

I assumed not, since it wasn't explicitly said in the description. 

If it where the case, a new table regarding ownership history would be needed that used the customer id, bike id and possibly dates to figure out who owned what when.