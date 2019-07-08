# xt_geoip-block_countries
Block IP traffic by country with a simple configuration using continuously updated geolite2 data.

The intent is to make it easy to maintain iptables rules that will DROP all traffic from countries from which no meaningful traffic will originate, other than abuse. After installation, no countries are blocked by default (see [Configuration](#Configuration)). This is a brutally brain-dead means to manage IP traffic, but it can be a quick and viable solution in many use case. The countries that are blocked will be HIGHLY dependent on local system needs.

## Usage
 * check the [Requirements](#Requirements) section, and follow the in steps the [Installation](#Installation) section
 * edit `/etc/xt_geoip-block_countries` *(see the [Configuration](#Configuration) section for full details)*
   * to block a country, add a line specifying the ISO country code
 * restart `xt_geoip-block_countries` systemd service to immediately apply configuration changes
   ```sh
   $ systemctl restart xt_geoip-block_countries
   ```
 * the geolite2 database is automatically updated every 7 days by the `xt_geoip-block_countries` systemd service

## Requirements
 * iptables
 * xtables-addons
 * curl
 * unzip
 * systemd (to keep geolilte2 database up-to-date)
 * Perl
 * Perl module [NetAddr::IP](https://metacpan.org/pod/NetAddr::IP)
 * [GeoLite2xtables](https://github.com/mschmitt/GeoLite2xtables)

## Installation
 * ensure system requirements are met (see: [Requirements](#Requirements))
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
 * To configure `/etc/xt_geoip-block_countries`, see: [Configuration](#Configuration)
 * For ongoing operation, see: [Usage](#Usage)

## Configuration
 * edit `/etc/xt_geoip-block_countries` to configure countries to block IP traffic from.
 * block a country with a [two-letter ISO country code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) on it's own line
 * content after a `#` character is ignored (comments)
 * to immediately apply changes, restart the `xt_geoip-block_countries` service (see: [Usage](#Usage))
 * example `/etc/xt_geoip-block_countries` *(blocks incoming traffic from the United States and Germany)*
    ```ini
    # this file is a country block list used by xt_geoip-block_countries 
    #   (https://github.com/katmore/xt_geoip-block_countries)
    # each line is a two-letter ISO code of a country to block (ingress IP traffic)
    #   (https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
    # to immediately apply changes, restart the xt_geoip-block_countries service
    #   `systemctl restart xt_geoip-block_countries`
    US 
    DE
    ```
    
## Scripts
After [installation](#Installation), the following scripts will be located in the `/usr/local/lib/xt_geoip-block_countries` directory.
 * [**xt_geoip-block_countries**](lib/xt_geoip-block_countries) : adds iptables rules to drop all IP traffic from countries in [block list (/etc/xt_geoip-block_countries)](#Configuration)
 * [**xt_geoip_dl-convert2legacy**](xt_geoip_dl-convert2legacy) : generates an updated GeoIPCountryWhois.csv file with latest GeoLite2 data if it does not exist or is older than 1 week old (see: [GeoLite2xtables](https://github.com/mschmitt/GeoLite2xtables))
  * [**xt_geoip-build**](xt_geoip-build) : uses the `xt_geoip_dl-convert2legacy` script to update the GeoLite2 data in `/usr/share/xt_geoip`, then re-builds the xtables-addons geoip database (with `/usr/lib/xtables-addons/xt_geoip_build`)
    
## Legal
"xt_geoip-block_countries" is distributed under the terms of the [MIT license](LICENSE) or the [GPLv3](GPLv3) license.

Copyright (c) 2019, Doug Bird.
All rights reserved.
