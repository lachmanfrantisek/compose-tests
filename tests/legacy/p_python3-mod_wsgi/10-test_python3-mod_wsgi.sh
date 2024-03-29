#!/bin/bash

t_Log "Running $0 - Apache httpd python3-mod_wsgi is functional"

if [[ $centos_ver -lt 8 ]]; then
    t_Log "python3-mod_wsgi doesn't exist before CentOS 8 -> SKIP"
    exit 0
fi

cat > /etc/httpd/conf.d/tfapp.conf << EOF
WSGIScriptAlias /tfapp /var/www/html/tfapp.wsgi
EOF

cat > /var/www/html/tfapp.wsgi << EOF
def application(environ, start_response):
    status = '200 OK'
    output = 't_functional_mod_wsgi_test'.encode()
    response_headers = [
        ('Content-type', 'text/plain'),
        ('Content-Length', str(len(output)))
    ]
    start_response(status, response_headers)
    return [output]
EOF
restorecon -r /var/www/html

systemctl restart httpd

curl -s --insecure https://localhost/tfapp | grep -q 't_functional_mod_wsgi_test'
t_CheckExitStatus $?

systemctl stop httpd

rm /etc/httpd/conf.d/tfapp.conf /var/www/html/tfapp.wsgi
