# Use Ubuntu as base image
FROM ubuntu:20.04

# Set environment variable for non-interactive operations
ENV DEBIAN_FRONTEND=noninteractive

# Update packages and install required dependencies
RUN apt-get update && apt-get install -y \
    qemu \
    wget \
    unzip \
    x11vnc \
    novnc \
    supervisor \
    xorg \
    openbox \
    && rm -rf /var/lib/apt/lists/*

# Create directories for storing the Windows 11 ISO and VM data
RUN mkdir -p /opt/windows /opt/qemu /opt/novnc

# Download the Windows 11 ISO (You can replace with your own ISO if necessary)
RUN wget -q -O /opt/windows/windows11.iso "https://example.com/windows11.iso"

# Download NoVNC and required web server components
RUN wget -q -O /opt/novnc/novnc.zip https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.zip \
    && unzip /opt/novnc/novnc.zip -d /opt/novnc \
    && rm /opt/novnc/novnc.zip

# Copy custom entry point script for starting Windows 11 VM
COPY start-win11.sh /opt/start-win11.sh
RUN chmod +x /opt/start-win11.sh

# Expose VNC and WebSocket ports for NoVNC
EXPOSE 5900 6080

# Set supervisor to manage services
COPY supervisord.conf /etc/supervisor/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
