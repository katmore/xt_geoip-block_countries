# xt_geoip-block_countries
simple configuration for blocking IP traffic by country of origin using continuously updated geolite2 data

## Usage
 * follow the [installation instructions](#Installation)
 * edit `/etc/xt_geoip-block_countries`
   * to block a country, add a line specifying it's [two-letter ISO country code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes)
   * lines starting with `#` (the pound symbol) are ignored
 * restart 
 
## Installation
 * Ensure system requirements are met (see: [Requirements](#Requirements) section)
 * download and extract this project
 * run [`install.sh`](https://github.com/katmore/xt_geoip-block_countries/blob/master/install.sh) script
 * *example: curl/unzip to download/extract, then execute `install.sh`*
    ```
    $ cd ~
    $ curl https://github.com/katmore/xt_geoip-block_countries/archive/master.zip -OJL
    $ unzip xt_geoip-block_countries-master.zip
    $ cd xt_geoip-block_countries-master
    ```
 * 
   * example (if downloaded according to above)
     ```
     $ ./install.sh
     ```
 * configure as needed (see: [Usage](#Usage) section)
  
## Requirements
 * iptables
 * xtables-addons
 * curl
 * unzip
 * systemd (for geolilte2 updates)
 * Perl
 * Perl module [NetAddr::IP](https://metacpan.org/pod/NetAddr::IP)
 * [GeoLite2xtables](https://github.com/mschmitt/GeoLite2xtables)
