#!/bin/env xonsh

import os
import sys
import urllib.parse
import tempfile
import subprocess
from textwrap import indent
from pathlib import Path
from textwrap import dedent, indent

import smtplib
from datetime import datetime, timezone
from email.message import EmailMessage

BASE_URL = ${...}.get("PLUGIN_GIT_FILE_HTTP_BASE_URL", "")
MESSAGE_TEMPLATE = ${...}.get("PLUGIN_EMAIL_MESSAGE_TEMPLATE", "{urls}")
MESSAGE_TEMPLATE_HTML = ${...}.get("PLUGIN_EMAIL_MESSAGE_HTML_TEMPLATE", None)

last_commit = $(git rev-parse f"$PLUGIN_GIT_MAIN_REF").strip()

previous_commit = $(git rev-parse f"$PLUGIN_GIT_LAST_EMAIL_REF").strip()

print(f"Looking for new files between {last_commit} and {previous_commit}")

if last_commit == previous_commit:
    print(f'No changes since last check - latest commit is {last_commit}')
    sys.exit(0)

files = list(map(Path, $(git log --diff-filter=A --name-only --pretty=oneline --abbrev-commit f"{last_commit}...{previous_commit}").splitlines()))
files = [filename for filename in files if filename.exists()]
MATCH_PATTERN = ${...}.get("PLUGIN_PATH_MATCH_PATTERN", None)

if MATCH_PATTERN is not None:
    files = [filename for filename in files if filename.match(MATCH_PATTERN)]

# urls = {filename: BASE_URL + urllib.parse.quote(str(filename)) for filename in files}
urls = {filename: BASE_URL + str(filename) for filename in files}

if len(urls) == 0:
    print(f'No new files since last check')
    sys.exit(0)

url_list = indent(os.linesep.join(urls.values()), '  ')

msg = EmailMessage()
msg['From'] = $PLUGIN_EMAIL_FROM_ADDRESS
msg['To'] = $PLUGIN_EMAIL_TO_ADDRESS
cc_address = ${...}.get("PLUGIN_EMAIL_CC_ADDRESS", None)
if cc_address:
  msg['Cc'] = cc_address
msg['Date'] = datetime.now(timezone.utc)
msg['Subject'] = $PLUGIN_EMAIL_SUBJECT

message = MESSAGE_TEMPLATE.format(urls=url_list)
msg.set_content(message)

if MESSAGE_TEMPLATE_HTML is not None:
    links = [f'<a href="{url}">{path}</a>' for path, url in urls.items()]
    html_message = MESSAGE_TEMPLATE_HTML.format(links='<br/>'.join(links))
    html_message = dedent(f"""\
    <html>
    <head></head>
    <body>
    {indent(html_message, '    ')}
    </body>
    </html>
    """)
    msg.add_alternative(html_message, subtype='html')

print("Sending the following email:")
print(msg)

server = smtplib.SMTP($PLUGIN_SMTP_SERVER_ADDRESS,${...}.get("PLUGIN_SMTP_SERVER_PORT", 587))
server.starttls()
server.login($PLUGIN_SMTP_SERVER_USERNAME, $PLUGIN_SMTP_SERVER_PASSWORD)

server.send_message(msg)
server.quit()
