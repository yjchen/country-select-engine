require 'yaml'

# This script take the output of `ruby-cldr export --merge`, 
# and convert into Rails locales for countries, languages and currencies.
#
# https://github.com/svenfuchs/rails-i18n
# http://people.w3.org/rishida/utils/subtags/index.php
=begin
locales = {
  ar, az, bg, bn-IN, bs, ca, cs, csb, cy, da, de, de-AT, de-CH, dsb, el, en-AU, en-GB, en-IN, en-US, eo, es, es-AR, es-CL, es-CO, es-MX, es-PE, et, eu, fa, fi, fr, fr-CA, fr-CH, fur, gl-ES, gsw-CH, he, hi, hi-IN, hr, hsb, hu, id, is, it, ja, kn, ko, lo, lt, lv, mk, mn, nb, nl, nn, pl, pt-BR, pt-PT, rm, ro, ru, sk, sl, sr, sr-Latn, sv-SE, sw, th, tl, tr, uk, vi, wo, zh-CN, zh-TW
}
=end
locales = {
  'en' => { :locale => 'en',
            :language => 'en'
          },
  'zh-TW' => { :locale => 'zh-Hant-TW',
               :language => 'zh-Hant'
             }
}

data_path = './ruby-cldr/data/'
output_path = '../config/locales/' # must be created
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
    list[x] = y['one']
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
