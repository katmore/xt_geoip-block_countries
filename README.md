# xt_geoip-block_countries
simple configuration of regional IP traffic blocking using continuously updated geolite2 data

## Requirements
 * https://github.com/mschmitt/GeoLite2xtables
 * iptables
 * xtables-addons
 * curl
 * unzip
 * Perl
 * Perl module [NetAddr::IP](https://metacpan.org/pod/NetAddr::IP)
 * systemd (for geolilte2 updates)
