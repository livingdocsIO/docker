# Use a lightweight web server image
FROM nginx:alpine

# Copy the maintenance page files to the Nginx web root
COPY src /usr/share/nginx/html

# Expose port 80 for the web server
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
