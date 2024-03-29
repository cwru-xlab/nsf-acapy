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
ENTRYPOINT ["aca-py"]
