# Run the following on first time setup:
#  Set-ExecutionPolicy Bypass

# Chocolatey setup

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install apps

choco install -y `
	nodejs `
	yarn `
	slack `
	googlechrome `
	dotnetcore-sdk `
	tree `
	visualstudiocode

choco install microsoft-windows-terminal --pre -y

echo "Manually add Git Bash to Windows Terminal: https://addshore.com/2020/05/adding-git-bash-to-windows-terminal/"
