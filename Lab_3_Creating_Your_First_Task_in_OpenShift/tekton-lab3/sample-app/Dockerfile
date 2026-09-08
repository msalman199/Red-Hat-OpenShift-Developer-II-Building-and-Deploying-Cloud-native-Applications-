FROM registry.access.redhat.com/ubi8/ubi:latest

# Install basic tools
RUN yum update -y && \
    yum install -y httpd && \
    yum clean all

# Create a simple HTML page
RUN echo '<html><body><h1>Hello from Tekton Task!</h1><p>This image was built using a Tekton Task in OpenShift.</p></body></html>' > /var/www/html/index.html

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
