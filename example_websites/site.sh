#!/bin/bash
echo "Hello, World" > index.xhtml
nohup busybox httpd -f -p ${var.server_port} &