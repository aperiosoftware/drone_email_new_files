# Send emails about new files in a repository

This repository is a plugin for drone which lists all new files in a repo
between two git refs, and then emails this list to a preconifgured address.

## Configuration

This script uses the following environment variables, when setting them from
the `.drone.yml` file remove the `PLUGIN_` and make them lower case, an example
config is:


  - name: notify
    image: cadair/drone_email_new_files
    settings:
      smtp_server_address: "smtp.example.com"
      smtp_server_username: "user@example.com"
      smtp_server_password: "CorrectHorseBatteryStaple"
      email_from_address: "user@example.com"
      email_to_address: "other@example.com"
      email_subject: "Following files have been added to the repo"
      email_message_template: |
        This is an automated message - there have been new files added to the repository:

        {urls}

      git_main_ref: "HEAD"
      git_last_email_ref: "last-notified"
      git_file_http_base_url: "https://github.com/example/example/blob/master/"

* `PLUGIN_SMTP_SERVER_ADDRESS`

    The SMTP server address.

* `PLUGIN_SMTP_SERVER_PORT` (defaults to 587)
   
   The SMTP server port (uses STARTTLS).

* `PLUGIN_SMTP_SERVER_USERNAME`

   The username for authenticating with the SMTP server.

* `PLUGIN_SMTP_SERVER_PASSWORD`

   The password for authenticating with the SMTP server.

* `PLUGIN_EMAIL_FROM_ADDRESS`

   The email address to send the notification email from.

* `PLUGIN_EMAIL_TO_ADDRESS`

   The email address to send the notification email to.

* `PLUGIN_EMAIL_SUBJECT`

   The subject for the sent email.

* `PLUGIN_EMAIL_MESSAGE_TEMPLATE`

   The template for the email body should contain `{urls}` for a list of URLs
   for the changed files.

* `PLUGIN_GIT_FILE_HTTP_BASE_URL`

   The http base URL for to link to files in the repo.

* `PLUGIN_GIT_MAIN_REF`

   The git ref (branch or tag) on which new files are added, i.e. `'master'`.

* `PLUGIN_GIT_LAST_EMAIL_REF`

   The git ref at which the email was last sent, the file list will be
   generated by finding new files in the repository which were added between
   this ref and `GIT_MAIN_REF`.
