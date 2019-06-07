FROM bitnami/minideb:jessie

# Create test user, home directory and set permissions
RUN useradd -m -s /bin/zsh tester &&\
	 mkdir -p /home/tester && \
	 chown -R tester:tester /home/tester

# Operating system updates and install
RUN install_packages python git vim zsh

# Add dotfiles and chown
ADD --chown=tester:tester . /home/tester/configs

# Switch to test user and switch working dir
USER tester
ENV HOME /home/tester
WORKDIR /home/tester/configs

# Run setup
RUN ./setup

CMD ["/usr/bin/zsh"]

