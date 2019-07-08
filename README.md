# xt_geoip-block_countries
simple configuration for blocking IP traffic by country of origin using continuously updated geolite2 data

## Usage
 * follow the [installation instructions](#Installation)
 * edit `/etc/xt_geoip-block_countries`
   * to block a country, add a line specifying it's [two-letter ISO country code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes)
   * lines starting with `#` (the pound symbol) are ignored
 * restart `xt_geoip-block_countries` systemd service
   ```sh
   $ systemctl restart xt_geoip-block_countries
   ```
 * the geolite2 database is updated every 7 days by the `xt_geoip-block_countries` systemd service
 
## Installation
 * ensure system requirements are met (see: [Requirements](#Requirements) section)
 * [download](https://github.com/katmore/xt_geoip-block_countries/archive/master.zip) and extract: https://github.com/katmore/xt_geoip-block_countries/archive/master.zip
 * run the [`install.sh`](https://github.com/katmore/xt_geoip-block_countries/blob/master/install.sh) script
 * *example: curl/unzip to download/extract, then execute `install.sh`*
    ```sh
    $ cd ~
    $ curl https://github.com/katmore/xt_geoip-block_countries/archive/master.zip -OJL
    $ unzip xt_geoip-block_countries-master.zip
    $ xt_geoip-block_countries-master/install.sh
    ```
 * try `install.sh --help` to see more install script options
   ```sh
   $ ./install.sh
   ```
 * For configuration and ongoing operation, see: [Usage](#Usage) section) 
  
## Requirements
 * iptables
 * xtables-addons
 * curl
 * unzip
 * systemd (to keep geolilte2 database up-to-date)
 * Perl
 * Perl module [NetAddr::IP](https://metacpan.org/pod/NetAddr::IP)
 * [GeoLite2xtables](https://github.com/mschmitt/GeoLite2xtables)
