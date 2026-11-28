# StudyVault Google sign-in setup

The site uses Supabase Auth and Google sign-in. No Gmail inbox access is requested. These steps require access to the existing Supabase and Google Cloud projects; the site changes alone do not activate sign-in or protect the database.

1. Back up the database and review the current policies on `public.problems`. In the Supabase SQL editor run `supabase-ownership.sql`. It **replaces all existing policies** on that table and enables row-level security, so check whether other apps depend on those policies first. Until it runs, client-side filtering does not protect data from direct database API requests.
2. In Google Cloud, configure the OAuth consent screen and create a Web application OAuth client. Add the callback URL shown on the Supabase Google provider page as an authorized redirect URI. Configure test users if the consent screen is in testing mode.
3. Enable the Google provider in Supabase Authentication and enter the Google client ID and secret. Keep the secret out of this repository.
4. In Supabase Authentication URL Configuration, set the site URL and add each exact site URL to the redirect allow list, including its path (for example, the deployed `index.html` URL and your local server URL). Serve the page over HTTP(S), not `file://`.
5. Deploy the updated site, sign in, and check saving, viewing and deleting questions. Test with a second Google account to confirm that neither account can access the other's records.

## Existing questions

Questions created before sign-in have no owner and will be hidden after the migration. They are not deleted. An administrator can assign them after the intended owner has signed in. Only do this if all unowned questions really belong to that person; otherwise identify and assign the rows individually. In the Supabase SQL editor, inspect the user ID and rows first:

```sql
select id, email from auth.users;
select * from public.problems where user_id is null;
```

Then use a verified user UUID in an administrator-run statement, for example:

```sql
update public.problems
set user_id = '00000000-0000-0000-0000-000000000000'::uuid
where user_id is null;
```

Replace the example UUID with the verified ID before running. This cannot be safely automated because the existing rows do not record their owners.