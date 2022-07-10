FROM bitnami/minideb:latest

# Operating system updates and install
RUN install_packages git vim zsh ca-certificates ssh

# Create test user, home directory and set permissions
RUN useradd -m -s /bin/zsh tester &&\
	 mkdir -p /home/tester/.ssh && \
	 chown -R tester:tester /home/tester

RUN /usr/bin/ssh-keyscan -t rsa -H github.com >> /home/tester/.ssh/known_hosts

# Add dotfiles and chown
ADD --chown=tester:tester . /home/tester/configs

# Switch to test user and switch working dir
USER tester
ENV HOME /home/tester
WORKDIR /home/tester/configs

# Replace git links with https to make it work on GitHub Actions
RUN git config --global url.https://github.com/.insteadOf git://github.com/

# Run setup
RUN ./setup

CMD ["/usr/bin/zsh"]

