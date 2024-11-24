# Use Windows Server Core as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set environment variable for non-interactive operations
ENV DEBIAN_FRONTEND=noninteractive

# Install QEMU (Windows version) for virtualization (Windows software virtualization)
RUN powershell -Command \
    Invoke-WebRequest -Uri https://qemu.weilnetz.de/w64/ -OutFile "qemu.zip"; \
    Expand-Archive -Path "qemu.zip" -DestinationPath "C:\qemu"; \
    Remove-Item -Path "qemu.zip"

# Install NoVNC and dependencies for remote desktop access
RUN powershell -Command \
    Invoke-WebRequest -Uri https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.zip -OutFile "novnc.zip"; \
    Expand-Archive -Path "novnc.zip" -DestinationPath "C:\novnc"; \
    Remove-Item -Path "novnc.zip"

# Install additional required utilities (like Xvfb, and other utilities for remote access)
RUN powershell -Command \
    Invoke-WebRequest -Uri https://chocolatey.org/install.ps1 -OutFile "install-choco.ps1"; \
    powershell -ExecutionPolicy Bypass -File "install-choco.ps1"; \
    Remove-Item -Path "install-choco.ps1" -Force; \
    choco install -y x11vnc

# Install wget (to download Windows ISO) and unzip
RUN powershell -Command \
    choco install -y wget unzip

# Set working directory for files
WORKDIR /app

# Download Windows ISO (replace with correct Windows ISO URL or mount your own)
RUN wget -q -O "C:\\app\\windows.iso" "https://example.com/windows.iso"

# Copy a custom script for starting the Windows VM
COPY start-win.sh /app/start-win.sh
RUN powershell -Command Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Expose ports for NoVNC (VNC and WebSocket)
EXPOSE 5900 6080

# Entry point to run the Windows VM with NoVNC
CMD ["powershell", "C:\\app\\start-win.sh"]
