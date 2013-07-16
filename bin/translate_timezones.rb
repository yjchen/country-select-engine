require 'yaml'

# copy 'google.yml' to google translate 
# and save the result into google.locale.yml

output_path = 'config/locales/' # must be created

locales = ['ru', 'zh-CN']

locales.each do |locale|
  template = YAML::load(File.open("script/google.yml"))
  translation = YAML::load(File.open("script/google.#{locale}.yml"))
  languages = Hash.new
  template['timezones'].each_with_index do |x, i|
    languages[x] = translation.first[1][i]
    puts "#{x} ==> #{languages[x]}"
  end
  output = {locale => {'timezones' => languages}}
  o = output_path+'timezones.'+locale+'.yml'
  puts "write #{o}"
  s = YAML.dump(output)
  s = s.lines.to_a[1..-1].join
  f = File.open(o, 'w')
  f.write(s)
  f.close
end
