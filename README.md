devca
=====

A simple wrapper around OpenSSL for issuing SSL certs in a dev environment.

#### Example: SSL on your mac in under 2 minutes

1. Download devca.sh
2. Create the CA


        $ ./devca.sh init
        Done. Install /Users/sgrenfro/.devca/devca.crt in your browser as a trusted root CA.

3. Create the server cert

        $ ./devca.sh cert '*.example.com'
        Done. Install /Users/sgrenfro/.devca/star.example.com.key and /Users/sgrenfro/.devca/star.example.com.crt in your webserver.

4. Install the CA cert in your browser. For Chrome and Safari, just open the cert, click Always Trust, and enter your password. You should then see the certificate marked trusted in your account. If you use Firefox, you'll have to install it in Firefox separately.

        $ open ~/.devca/devca.txt
        
  ![Always Trust CA Cert Dialog Screenshot](/images/devca-install-ca-cert.png "Click Always Trust")
  
  ![Certificate Marked Trusted in Keychain Acceess Screenshot](/images/devca-install-ca-cert-success.png "This certificate is marked trusted for this account")
  
5. Configure apache to use SSL.

        $ sudo cp /private/etc/apache2/httpd.conf /private/etc/apache2/httpd.conf.orig
        $ sudo vi /private/etc/apache2/httpd.conf # uncomment the httpd-ssl.conf line
        $ diff -U0 /private/etc/apache2/httpd.conf.orig /private/etc/apache2/httpd.conf
        --- /private/etc/apache2/httpd.conf.orig	2013-12-06 09:19:58.000000000 -0800
        +++ /private/etc/apache2/httpd.conf	2013-12-06 09:20:00.000000000 -0800
        @@ -490 +490 @@
        -#Include /private/etc/apache2/extra/httpd-ssl.conf
        +Include /private/etc/apache2/extra/httpd-ssl.conf
        
6. Install the server key and certificate in the standard location.

        $ ls /private/etc/apache2/server.{crt,key} # if these files exist, move them to a backup
        $ sudo cp -n ~/.devca/star.example.com.crt /private/etc/apache2/server.crt
        $ sudo cp -n ~/.devca/star.example.com.key /private/etc/apache2/server.key

6. Restart apache

        $ sudo apachectl configtest # make sure it says Syntax OK
        Syntax OK
        $ sudo apachectl restart
        
7. Edit /etc/hosts to add your desired webserver hostname(s) to the localhost line.

        $ sudo cp /etc/hosts /etc/hosts.orig
        $ sudo vi /etc/hosts
        $ diff -U0 /etc/hosts.orig /etc/hosts
        --- /etc/hosts.orig	2013-12-06 09:26:15.000000000 -0800
        +++ /etc/hosts	2013-12-06 09:26:31.000000000 -0800
        @@ -7 +7 @@
        -127.0.0.1	localhost
        +127.0.0.1	localhost m.example.com www.example.com
        
8. Profit. You can now open https://m.example.com/ or https://www.example.com/ in Chrome and it'll be served from your localhost apache with valid SSL certs.

  ![Success loading m.example.com in Chrome Screenshot](/images/devca-successfully-loaded-in-chrome.png "The identity of this website has been verified by Dev CA.")
