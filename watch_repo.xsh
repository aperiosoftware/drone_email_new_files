#!/bin/env xonsh

import os
import sys
import urllib.parse
import tempfile
import subprocess
from textwrap import indent

import smtplib
from datetime import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

server = smtplib.SMTP($PLUGIN_SMTP_SERVER_ADDRESS,${...}.get("PLUGIN_SMTP_SERVER_PORT", 587))
server.starttls()
server.login($PLUGIN_SMTP_SERVER_USERNAME, $PLUGIN_SMTP_SERVER_PASSWORD'])

msg = MIMEMultipart()
msg['From'] = $PLUGIN_EMAIL_FROM_ADDRESS
msg['To'] = $PLUGIN_EMAIL_TO_ADDRESS
msg['Date'] = datetime.now().isoformat()
msg['Subject'] = $PLUGIN_EMAIL_SUBJECT

BASE_URL = $PLUGIN_GIT_FILE_HTTP_BASE_URL
MESSAGE_TEMPLATE = $PLUGIN_EMAIL_MESSAGE_TEMPLATE

last_commit = $(git rev-parse $PLUGIN_GIT_MAIN_REF).strip()

previous_commit = $(git rev-parse $PLUGIN_GIT_LAST_EMAIL_REF).strip()

if last_commit == previous_commit:
    print(f'No changes since last check - latest commit is {last_commit}')
    sys.exit(0)

files = $(git log --diff-filter=A --name-only --pretty=oneline --abbrev-commit f"{previous_commit}...{last_commit}").splitlines()

urls = [BASE_URL + urllib.parse.quote(filename) for filename in files if os.path.exists(filename)]

if len(urls) == 0:
    print(f'No new files since last check')
    sys.exit(0)

urls = indent(os.linesep.join(urls), '  ')

message = MESSAGE_TEMPLATE.format(urls=urls)

msg.attach(MIMEText(message, 'plain'))

print("Sending the following email:")
print(msg)
server.send_message(msg)

server.quit()
