#FROM adoptopenjdk/openjdk11:debian-slim
FROM eclipse-temurin:11

# Configuration variables.
ENV SOFT		jira
ENV SOFTSUB		software
ENV OPENJDKV		11
ENV JIRA_VERSION	9.5.0
ENV JIRA_HOME		/var/atlassian/${SOFT}
ENV JIRA_INSTALL	/opt/atlassian/${SOFT}
ENV SOFT_HOME		${JIRA_HOME}
ENV SOFT_INSTALL	${JIRA_INSTALL}
ENV SOFT_VERSION	${JIRA_VERSION}

# set visible code
ENV VISIBLECODE		true

# download option
RUN apt-get update && apt-get install curl bash && \
	curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO/option.sh -o /option.sh && \
	chmod 755 /option.sh

# copyright and timezone
RUN curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO/copyright.sh | bash

# install
RUN curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Atlassian/${SOFT}_install.sh | bash

# prepare visible code
RUN mkdir -p /etc-start && mv ${SOFT_INSTALL} /etc-start/${SOFT}

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
#USER daemon:daemon

# Expose default HTTP connector port.
EXPOSE 8080 8443

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["${SOFT_HOME}", "${SOFT_INSTALL}"]

# Set the default working directory as the installation directory.
WORKDIR ${SOFT_HOME}

ENTRYPOINT ["/docker-entrypoint.sh"]

# Run Atlassian as a foreground process by default.
#CMD ["/opt/atlassian/jira/bin/start-jira.sh", "-fg"]
