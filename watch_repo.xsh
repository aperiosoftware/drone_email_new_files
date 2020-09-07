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

#server = smtplib.SMTP($SMTP_SERVER_ADDRESS,${...}.get("SMTP_SERVER_PORT", 587))
#server.starttls()
#server.login($SMTP_SERVER_USERNAME, $SMTP_SERVER_PASSWORD'])

msg = MIMEMultipart()
msg['From'] = $EMAIL_FROM_ADDRESS
msg['To'] = $EMAIL_TO_ADDRESS
msg['Date'] = datetime.now().isoformat()
msg['Subject'] = $EMAIL_SUBJECT

BASE_URL = $GIT_FILE_HTTP_BASE_URL
MESSAGE_TEMPLATE = $EMAIL_MESSAGE_TEMPLATE

last_commit = $(git rev-parse $GIT_MAIN_REF).strip()

previous_commit = $(git rev-parse $GIT_LAST_EMAIL_REF).strip()

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

print(msg)
#server.send_message(msg)
#
#server.quit()
