Authorization and Permissions

Wheelhouse uses Pundit to implement role-based authorization. Permissions are enforced through model-specific policies, with additional record-level restrictions for mechanics.

User Roles

The application defines three authorization roles:

* Owner: Full administrative access to application resources.
* Counter: Manages customer information, bicycles, and repair intake.
* Mechanic: Works on assigned repairs and can view service and staff information.

Authentication is required for protected application resources.

The service catalog is publicly accessible through its index and show actions.

Permissions Matrix

Resource	Action	Owner	Counter	Mechanic
Customer	Index	Yes	    Yes	    No
Customer	Show	Yes	    Yes	    No
Customer	Create	Yes	    Yes	    No
Customer	Update	Yes	    Yes	    No
Customer	Destroy	Yes	    No	    No
Bike	    Index	Yes	    Yes	    No
Bike	    Show	Yes	    Yes	    No
Bike	    Create	Yes	    Yes	    No
Bike	    Update	Yes	    Yes	    No
Bike	    Destroy	Yes	    No	    No
Repair	    Index	Yes	    Yes	    Assigned only
Repair	    Show	Yes	    Yes	    Assigned only
Repair	    Create	Yes	    Yes	    No
Repair	    Update	Yes	Except picked-up |repairs	 |Assigned, unfinished repairs

Repair	    Destroy	Yes	    No	    No
Service	    Index	Public	Public	Public
Service	    Show	Public	Public	Public
Service	    Create	Yes	    No	    No
Service	    Update	Yes	    No	    No
Service	    Destroy	Yes	    No	    No
Staff	    Index	Yes	    Yes	    Yes
Staff	    Show	Yes	    Yes	    Yes
Staff	    Create	Yes	    No	    No
Staff	    Update	Yes	    No	    No
Staff	    Destroy	Yes 	No	    No

The owner role has full administrative access, including modification of completed repairs.

Record-Level Authorization

Customer and Bike

Owners and counter users can view, create, and update customer and bicycle records.

Only owners can delete these records.

Mechanics cannot access customer or bicycle management resources.

Repair

Repair authorization depends on the user’s role, the assigned staff member, and the repair’s current status.

Owner

Owners can view, create, update, and delete all repairs.

Counter

Counter users can:

* View all repairs.
* Create new repairs.
* Update repairs that have not reached the picked_up status.

Counter users cannot delete repairs.

Mechanic

Mechanics can:

* View repairs assigned to their associated staff record.
* Update assigned repairs that have not reached the picked_up status.

Mechanics cannot:

* View repairs assigned to another mechanic.
* Access unassigned repairs.
* Create repairs.
* Delete repairs.
* Update completed repairs.
* Modify fields outside their permitted attributes.

Mechanics may update only:

* status
* diagnosis
* intake_photos

A mechanic account without an associated staff record cannot access any repair through mechanic-specific authorization.

Service

The service catalog is publicly readable.

Only owners can create, update, or delete services.

Staff

Authenticated users can view staff records.

Only owners can create, update, or delete staff records.

Policy Scopes

Pundit policy scopes determine which records are visible in collection actions.

Resource	Owner	Counter	Mechanic
Customer	All	All	None
Bike	All	All	None
Repair	All	All	Assigned repairs
Service	All	All	All
Staff	All	All	All

For unauthenticated visitors, the public service catalog remains accessible.

Policy scopes are applied to index actions to prevent unauthorized records from appearing in collections.

Individual record authorization is also enforced for show, update, and destroy actions.

Strong Parameters

Permitted attributes depend on the authorization policy.

Owners and counter users receive the attributes appropriate to their permitted operations.

Mechanics have a restricted repair attribute list:

%i[status diagnosis intake_photos]

The restriction prevents mechanics from modifying fields such as repair assignments, customer information, quoted prices, or approval details through submitted parameters.

Authorization checks remain necessary even when form controls are hidden.

HTTP Responses

Situation	Expected behavior
Unauthenticated request to protected resource	Redirect to login
Authenticated request without permission	HTTP 403 Forbidden
Authorized request	Normal controller response
Public service catalog request	Accessible without authentication

Unauthorized requests are handled centrally through Pundit’s NotAuthorizedError.

The application renders an HTTP 403 response using the application layout.

Interface Authorization

Navigation links and action controls are displayed according to the current user’s permissions.

This includes:

* Resource navigation links.
* New-record actions.
* Edit actions.
* Delete actions.
* Form fields restricted by role.

Interface restrictions improve usability but do not replace controller-level authorization.

Testing

Authorization is verified through policy tests and HTTP integration tests.

The test suite covers:

* Role-specific permissions.
* Record ownership and assignment.
* Completed repair restrictions.
* Mechanic attribute restrictions.
* Unauthorized requests.
* Public service access.
* Policy scopes.

The verified test suite contains 56 tests and 213 assertions, with no failures, errors, or skipped tests.