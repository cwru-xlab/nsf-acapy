# I cobbled together this Dockerfile for running the local ACA-Py project based on the other Dockerfiles originally in
# this repo. Should be pretty similar to some of the other Dockerfiles, slightly modified for the NSF project use case.

ARG python_version=3.9.16
FROM python:${python_version}-slim-bullseye

# Some env vars for debugging: (I haven't tried these as I've just been debugging without Docker)
#ENV ENABLE_PTVSD 0
#ENV ENABLE_PYDEVD_PYCHARM 0
#ENV PYDEVD_PYCHARM_HOST "host.docker.internal"

# Copy and install project dependencies:
ADD requirements*.txt ./
RUN pip3 install --no-cache-dir \
	-r requirements.txt \
	-r requirements.askar.txt \
	-r requirements.bbs.txt \
	-r requirements.dev.txt

# Copy the source code for installing locally:
ADD aries_cloudagent ./aries_cloudagent
# Copy the local module setup script:
ADD setup.py ./
# Copy README as it is used in setup.py:
ADD README.md ./
# Copy the executable:
ADD bin/aca-py ./bin/aca-py
# Copy the agent arg-files to the root: (so that we can easily reference the relevant arg-file via root dir)
ADD nsf-demo/agent-args /

# Install the local ACA-Py project:
RUN pip3 install --no-cache-dir -e .

# On run/start, execute aca-py: (also implicitly passes args)
# ENTRYPOINT ["aca-py", "start"]
CMD aca-py start --wallet-storage-config "$WALLET_STORAGE_CONFIG" --wallet-storage-creds '{"account":"testuser","password":"testpassword","admin_account":"testuser","admin_password":"testpassword"}' --inbound-transport http 0.0.0.0 8020 --outbound-transport http --endpoint "$ENDPOINT_URL" --webhook-url "$WEBHOOK_URL" --label user.agent --admin-insecure-mode --admin 0.0.0.0 8021 --no-ledger --auto-provision --wallet-type askar --wallet-name user-wallet --wallet-key wallet-password --wallet-storage-type postgres_storage

# CMD `aca-py start --inbound-transport http 0.0.0.0 8020\
#       --wallet-storage-config "$WALLET_STORAGE_CONFIG"\
#       --wallet-storage-creds '{"account":"testuser","password":"testpassword","admin_account":"testuser","admin_password":"testpassword"}'
#       --outbound-transport http\
#       --endpoint 'http://employer.sharetrace.us:8020'\
#       --webhook-url 'http://employer-controller.employer:8081/webhook'\
#       --label 'service-provider.agent'\
#       --admin-insecure-mode\
#       --admin 0.0.0.0 8021\
#       --no-ledger\
#       --auto-provision\
#       --wallet-type askar\
#       --wallet-name service-provider-wallet\
#       --wallet-key wallet-password\
#       --wallet-storage-type postgres_storage\`
