# Decisions

## Can a Repair Include Work That Is Not on the Standard Service List?

The description explains that the shop has a standard list of services and prices, but it does not specify whether every repair must use only those predefined services. I assumed that all charged work must correspond to a service on the standard list.

If mechanics are allowed to add custom work that is not on the service list, the model would need to change so that a repair can store a custom service description and price without requiring an existing Service record.

## Can Multiple Mechanics Work on a Repair?

There were no specifications on how many mechanics may work on a single repair, so I assumed that only one mechanic can be assigned to each repair.

If more than one mechanic can work on a repair, the relationship between mechanics and repairs would need to change to many-to-many.

## Does the Ownership History Matter?

I assumed not, since it wasn't explicitly stated in the description.

If ownership history were required, a new table would be needed to record customer IDs, bike IDs, and ownership dates.

# Lab 11 — Authentication and Security

## Why Use Rails Native Authentication?

I decided to use Rails 8's built-in authentication generator instead of implementing authentication manually or using an external gem.

This provides password hashing, session management, and password-reset functionality while keeping the implementation consistent with Rails conventions.

## Why Separate Users from Staff?

A Staff record represents a person working at the repair shop, while a User represents an account that can authenticate.

I kept these models separate because not every user necessarily represents a staff member.

Each user can optionally belong to one staff member, but each staff member can have at most one user account.

The database enforces this restriction through a unique index on `users.staff_id`.

## Why Use a Default Role?

New accounts receive the `counter` role by default.

This follows the principle of least privilege by avoiding automatic assignment of the `owner` role.

Roles are defined through an enum in the User model, allowing the application to use consistent role values.

Registration does not permit users to assign their own roles or staff associations.

## Why Require Authentication for Most Pages?

Customer information, repairs, bikes, and staff records are internal workshop data.

For that reason, these pages require an authenticated browser session.

The service catalog remains public because customers should be able to view available services and prices without creating an account.

The sign-in, registration, and password recovery pages are also publicly accessible.

## Why Track the User Who Received a Repair?

The staff member assigned to perform a repair is not necessarily the person who received the bicycle.

I added a separate `received_by_user` association to distinguish these responsibilities.

The receiving user is automatically assigned using `Current.user` when a repair is created.

The field is not included in permitted form parameters, preventing users from submitting an arbitrary receiver ID.

The association is optional so repairs created before Lab 11 remain valid.

## Why Use Password-Reset Tokens?

Password recovery uses Rails' built-in password-reset tokens rather than storing temporary passwords.

The tokens expire after 15 minutes and become invalid when the account password changes.

The password-reset request displays the same confirmation message regardless of whether the email address exists, reducing account enumeration.

## Why Send Emails Asynchronously?

Welcome and password-reset emails use `deliver_later`.

This allows the application to queue email delivery without waiting for it to finish during the HTTP request.

In development, the asynchronous Active Job adapter processes these jobs locally.

## Why Store Development Emails Locally?

I chose Rails' file delivery method because the assignment does not require an external email provider.

Emails are written to `tmp/sent_emails/`, allowing their contents and reset links to be inspected without sending real messages.

Both welcome and password-reset emails include HTML and plaintext versions.

## Why Keep API Authentication Separate?

The JSON API already uses Bearer tokens stored in Rails encrypted credentials.

I preserved that authentication mechanism rather than requiring browser sessions for API requests.

This keeps the API usable by external clients while allowing the HTML application to use cookie-based sessions.
