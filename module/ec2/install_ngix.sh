#!/bin/bash
sudo dnf install nginx -y
sudo systemctl enable nginx && sudo systemctl start nginx