Dockerized phpMyAdmin
=====================
This is a codebase for building your own phpMyAdmin docker image, so you can easily install the 
latest patched versions of PHP etc. This also supports the use of SSL/TLS.

### Supported Environment Variables
I have tried to support as many of the environment variables as they are found in [the official 
phpmyadmin/phpmyadmin Docker image](https://hub.docker.com/_/phpmyadmin), so that using this will 
almost be a drop-in replacement

* `PMA_HOST` - define address/host name of the MySQL server
* `PMA_USER` and `PMA_PASSWORD` - define username and password to use only with the config authentication method
* `PMA_PORT` - define port of the MySQL server
* `PMA_ARBITRARY` - when set to 1 connection to the arbitrary server will be allowed
* `UPLOAD_LIMIT` - if set, this option will override the default value for apache and php-fpm (format 
   as [0-9+](K,M,G) default value is 2048K, this will change upload_max_filesize and post_max_size 
   values)
* `SSL_ENABLED` - if provided, then the server will listen for HTTPS connections, and will 
  expect the SSL/TLS certificates to be provided using a bind-mounted volume to the container 
  path of `/ssl` with the following file names:
    - cert.pem - the site certificate (not including the CA/chain).
    - privkey.pem - the private key.
    - chain.pem - the chain file (not the combined fullchain file).