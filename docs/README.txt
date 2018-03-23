README
======

This directory should be used to place project specfic documentation including
but not limited to project notes, generated API/phpdoc documentation, or
manual files generated or hand written.  Ideally, this directory would remain
in your development environment only and should not be deployed with your
application to it's final production location.


Setting Up Your VHOST
=====================

The following is a sample VHOST you might want to consider for your project.

<VirtualHost *:80>
   DocumentRoot "D:/Projekte/ocs-api/public"
   ServerName .local

   # This should be omitted in the production environment
   SetEnv APPLICATION_ENV development

   <Directory "D:/Projekte/ocs-api/public">
       Options Indexes MultiViews FollowSymLinks
       AllowOverride All
       Order allow,deny
       Allow from all
   </Directory>

</VirtualHost>


Added functionality for OCS v1 spec
======================================

  OCS specification:
  http://www.freedesktop.org/wiki/Specifications/open-collaboration-services/

  ----

  Allow delimiter ',' of value of parameter 'categories'

  Example:
  /content/data?categories=1,2,3
  /content/data?categories=1x2x3

  ----

  Additional URL queries to '/content/data'

  xdg_types
  package_types

  Example:
  /content/data?xdg_types=icons,themes,wallpapers
  /content/data?package_types=1,2,3

  package_types:
  1 = AppImage
  2 = Android (apk)
  3 = OS X compatible
  4 = Windows executable
  5 = Debian
  6 = Snappy
  7 = Flatpak
  8 = Electron-Webapp
  9 = Arch
  10 = open/Suse
  11 = Redhat
  12 = Source Code

  ----

  Additional data field of '/content/categories'

  display_name
  parent_id
  xdg_type

  ----

  Additional data field of '/content/data'

  xdg_type
  download_package_type{n}
  download_package_arch{n}

  ----

  Additional data field of '/content/download'

  download_package_type
  download_package_arch

  ----

  Additional API method for preview picture

  /content/previewpic/{contentid}

  Example:
  /content/previewpic/123456789
  /content/previewpic/123456789?size=medium
