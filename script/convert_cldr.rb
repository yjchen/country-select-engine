require 'yaml'

# This script take the output of `ruby-cldr export --merge`, 
# and convert into Rails locales for countries, languages and currencies.
#
# https://github.com/svenfuchs/rails-i18n
# http://people.w3.org/rishida/utils/subtags/index.php
available_currencies = ["AED", "AFN", "ALL", "AMD", "ANG", "AOA", "ARS",
 "AUD", "AWG", "AZN", "BAM", "BBD", "BDT", "BGN",
 "BHD", "BIF", "BMD", "BND", "BOB", "BRL", "BSD",
 "BTN", "BWP", "BYR", "BZD", "CAD", "CDF", "CHF",
 "CLP", "CNY", "COP", "CRC", "CUC", "CUP", "CVE",
 "CZK", "DJF", "DKK", "DOP", "DZD", "EGP", "ERN",
 "ETB", "EUR", "FJD", "FKP", "GBP", "GEL", "GHS",
 "GIP", "GMD", "GNF", "GTQ", "GYD", "HKD", "HNL",
 "HRK", "HTG", "HUF", "IDR", "ILS", "INR", "IQD",
 "IRR", "ISK", "JMD", "JOD", "JPY", "KES", "KGS",
 "KHR", "KMF", "KPW", "KRW", "KWD", "KYD", "KZT",
 "LAK", "LBP", "LKR", "LRD", "LSL", "LTL", "LVL",
 "LYD", "MAD", "MDL", "MGA", "MKD", "MMK", "MNT",
 "MOP", "MRO", "MUR", "MVR", "MWK", "MXN", "MYR",
 "MZN", "NAD", "NGN", "NIO", "NOK", "NPR", "NZD",
 "OMR", "PAB", "PEN", "PGK", "PHP", "PKR", "PLN",
 "PYG", "QAR", "RON", "RSD", "RUB", "RWF", "SAR",
 "SBD", "SCR", "SDG", "SEK", "SGD", "SHP", "SKK",
 "SLL", "SOS", "SRD", "STD", "SVC", "SYP", "SZL",
 "THB", "TJS", "TMM", "TND", "TOP", "TRY", "TTD",
 "TWD", "TZS", "UAH", "UGX", "USD", "UYU", "UZS",
 "VEF", "VND", "VUV", "WST", "XAF", "XCD", "XOF",
 "XPF", "YER", "ZAR", "ZMK", "ZWD", "EEK", "YEN", "GHC"]

=begin
locales = {
  ar, az, bg, bn-IN, bs, ca, cs, csb, cy, da, de-AT, de-CH, dsb, el, en-AU, en-GB, en-IN, eo, es-AR, es-CL, es-CO, es-MX, es-PE, et, eu, fa, fi, fr-CA, fr-CH, fur, gl-ES, gsw-CH, he, hi, hi-IN, hr, hsb, hu, id, is, kn, ko, lo, lt, lv, mk, mn, nb, nl, nn, pl, pt-BR, pt-PT, rm, ro, sk, sl, sr, sr-Latn, sv-SE, sw, th, tl, tr, uk, vi, wo
}
=end
locales = {
  'de' => {    :locale => 'de',         :language => 'de' },
  'en' => {    :locale => 'en',         :language => 'en' },
  'en-US' => { :locale => 'en-US',      :language => 'en-US' },
  'es' => {    :locale => 'es',         :language => 'es' },
  'fr' => {    :locale => 'fr',         :language => 'fr' },
  'it' => {    :locale => 'it',         :language => 'it' },
  'ja' => {    :locale => 'ja',         :language => 'ja' },
  'ru' => {    :locale => 'ru',         :language => 'ru' },
  'zh-CN' => { :locale => 'zh-Hans-CN', :language => 'zh-Hans' },
  'zh-TW' => { :locale => 'zh-Hant-TW', :language => 'zh-Hant' }
}

data_path = '../ruby-cldr/data/'
output_path = 'config/locales/' # must be created
currency_yaml = 'currencies.yml'
language_yaml = 'languages.yml'
country_yaml = 'territories.yml'

# currencies
locales.each do |k, v|
  p = data_path+v[:locale]+'/'+currency_yaml
  puts "read #{p}"
  data = YAML.load_file(p)
  list = {}
  data[v[:locale]]['currencies'].each do |x, y|
    list[x] = y['one'] if available_currencies.include?(x.upcase)
  end
  output = {k => {'currencies' => list}}
  o = output_path+'currencies.'+k+'.yml'
  puts "write #{o}"
  s = YAML.dump(output)
  s = s.lines.to_a[1..-1].join
  f = File.open(o, 'w')
  f.write(s)
  f.close
end

# languages
locales.each do |k, v|
  p = data_path+v[:locale]+'/'+language_yaml
  puts "read #{p}"
  data = YAML.load_file(p)
  list = {}
  reverse_lookup = {}
  locales.each do |x, y|
    reverse_lookup[y[:language]] = x
  end
  puts reverse_lookup
  data[v[:locale]]['languages'].each do |x, y|
    list[reverse_lookup[x]] = y if reverse_lookup.keys.include?(x)
  end
  output = {k => {'languages' => list}}
  o = output_path+'languages.'+k+'.yml'
  puts "write #{o}"
  s = YAML.dump(output)
  s = s.lines.to_a[1..-1].join
  f = File.open(o, 'w')
  f.write(s)
  f.close
end

# countries
locales.each do |k, v|
  p = data_path+v[:locale]+'/'+country_yaml
  puts "read #{p}"
  data = YAML.load_file(p)
  list = {}
  data[v[:locale]]['territories'].each do |x, y|
    list[x] = y if (x.is_a?(String) && x.length == 2)
  end
  output = {k => {'countries' => list}}
  o = output_path+'countries.'+k+'.yml'
  puts "write #{o}"
  s = YAML.dump(output)
  s = s.lines.to_a[1..-1].join
  f = File.open(o, 'w')
  f.write(s)
  f.close
end
