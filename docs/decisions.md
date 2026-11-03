Authorization Design Decisions

1. Authorization Library

Decision: Use Pundit for application authorization.

Pundit provides model-specific policies that separate authorization logic from controllers and views.

This approach centralizes permission rules and makes them independently testable.

Each protected resource has a corresponding policy:

* CustomerPolicy
* BikePolicy
* RepairPolicy
* ServicePolicy
* StaffPolicy

Policies deny access by default unless a specific action is explicitly permitted.

2. Role-Based Authorization

Decision: Use the existing user roles to determine general permissions.

Wheelhouse defines three roles:

* owner
* counter
* mechanic

The owner role has full administrative permissions.

The counter role supports customer management, bicycle management, and repair intake.

The mechanic role supports repair work without granting access to unrelated customer or administrative information.

Role checks are implemented through Pundit policies rather than being duplicated across controllers.

3. Repair Assignment Restrictions

Decision: Restrict mechanic access to repairs assigned to their staff record.

Mechanics can access a repair only when its staff_id corresponds to the staff record associated with their user account.

This restriction applies to both collection queries and individual record actions.

A missing staff association does not grant access to unassigned repairs.

This prevents mechanics from accessing unrelated work orders.

4. Completed Repair Restrictions

Decision: Prevent counter users and mechanics from editing repairs with the picked_up status.

Picked-up repairs represent completed work orders.

Restricting further changes helps preserve their operational history.

Owners retain administrative access to these records.

The restriction is enforced by authorization policies rather than relying exclusively on disabled form controls.

5. Policy-Based Strong Parameters

Decision: Determine permitted repair attributes according to the current user’s authorization policy.

Mechanics can modify only:

%i[status diagnosis intake_photos]

Owners and counter users may modify the attributes permitted by their respective policies.

This prevents unauthorized changes through manually constructed HTTP requests.

Strong parameter restrictions complement policy authorization; they do not replace it.

6. Policy Scopes

Decision: Use Pundit policy scopes for collection queries.

Policy scopes ensure that users receive only records they are authorized to view.

For repairs:

* Owners can view all repairs.
* Counter users can view all repairs.
* Mechanics can view only assigned repairs.

The same authorization principles apply to individual record access.

Collection queries use eager loading where appropriate to avoid unnecessary database queries.

7. Public Service Catalog

Decision: Allow unauthenticated access to the service catalog’s index and show actions.

Visitors can browse available services without creating an account.

Creating, editing, and deleting services remain restricted to owners.

Other protected resources require authentication.

This separates public catalog functionality from administrative operations.

8. Unauthorized Requests

Decision: Return HTTP 403 Forbidden for authenticated users who lack permission.

Pundit’s NotAuthorizedError is handled centrally.

The response uses the application layout and communicates that the requested action is forbidden.

Unauthenticated users attempting to access protected resources are redirected to login.

This distinguishes authentication failures from authorization failures.

9. Interface Permissions

Decision: Use policy checks to control navigation and action visibility.

Users should not see controls for operations they cannot perform.

Examples include:

* Hiding customer management from mechanics.
* Hiding delete actions from counter users.
* Hiding administrative actions from non-owners.
* Restricting repair editing controls according to assignment and status.

Controller authorization remains authoritative.

Hiding a link or button does not constitute a security boundary.

10. Seed Data

Decision: Use idempotent seeds that preserve existing application records.

The seed implementation uses stable identifiers to locate existing demo records.

Repairs are identified by the seed_key attribute.

The implementation also supports associating legacy demo repairs with their seed keys when an unambiguous match is available.

Seed execution does not delete existing records or reset existing account passwords.

The demo dataset includes:

* Owner, counter, and mechanic accounts.
* Customers and bicycles.
* Assigned and unassigned repairs.
* Repairs in different lifecycle states.
* Completed and unfinished repairs.
* Repair services, diagnoses, and intake photos.

Running the seed task repeatedly should not create additional copies of the demo dataset.

11. Authorization Testing

Decision: Verify authorization at both the policy and HTTP request levels.

Policy tests validate individual authorization rules and scopes.

Integration tests verify that the application enforces those rules through its controllers.

The tests include cases involving:

* Different user roles.
* Assigned and unassigned repairs.
* Completed repairs.
* Unauthorized modifications.
* Public service endpoints.
* HTTP 403 responses.

The verified suite contains 56 tests and 213 assertions, with zero failures, errors, or skips.

12. Security and Maintainability

Decision: Keep authorization rules centralized and explicit.

The implementation prioritizes:

* Deny-by-default policies.
* Consistent authorization checks.
* Restricted strong parameters.
* Record-level access control.
* Policy-scoped collection queries.
* Clear HTTP error handling.
* Automated authorization testing.

These decisions reduce duplicated logic and make future permission changes easier to review and maintain.