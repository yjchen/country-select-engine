require "country-select-engine/engine"

# = CountrySelectEngine
#
# View helper for displaying select list with countries:
#
#     localized_country_select(:user, :country)
#
# Works just like the default Rails' +country_select+ plugin, 
# but stores countries as
# country *codes*, not *names*, in the database.
#
# You can easily translate country codes in your application like this:
#     <%= I18n.t @user.country, :scope => 'countries' %>
#
# Uses the Rails internationalization framework (I18n) 
# for translating the names of countries.
#
# Use Rake task <tt>rake import:country_select 'de'</tt> 
# for importing country names
# from Unicode.org's CLDR repository 
# (http://www.unicode.org/cldr/data/charts/summary/root.html)
#
# Code adapted from Rails' default +country_select+ plugin (previously in core)
# See http://github.com/rails/country_select/tree/master/lib/country_select.rb
#
module CountrySelectEngine
  categories = ['currencies', 'countries', 'languages', 'timezones']
  categories.each do |category|

  # Returns array with codes and localized country names 
  # (according to <tt>I18n.locale</tt>)
  # for <tt><option></tt> tags
  class_eval %Q{
    def self.localized_#{category}_array options = {}
      options.reverse_merge!(:sort => true)
      res = []
      list = I18n.translate(:#{category}).each do |key, value|
        res << [self.value_with_symbol(key, value, options), key.to_s] if include_key?(key.to_s, options)
      end
      if options[:sort]
        res.sort_by { |country| country.first.parameterize }
      else
        res
      end
    end
  }

  def self.value_with_symbol(key, value, options = {})
    if options[:timezone]
      timezone = ActiveSupport::TimeZone[key.to_s] 
      if timezone
        offset = "GMT#{ActiveSupport::TimeZone[key.to_s].formatted_offset}"
        if options[:timezone] == :prepend 
          return "(#{offset}) #{value}"
        elsif options[:timezone] == :append 
          return "#{value} (#{offset})"
        end
      else
        return value
      end
    elsif options[:symbol] == :prepend
      return "#{key.to_s}, #{value}"
    elsif options[:symbol] == :append
      return "#{value} (#{key.to_s})"
    else
      return value
    end
  end

  def self.include_key?(key, options)
    if options[:only]
      return options[:only].include?(key)
    end
    if options[:except]
      return !options[:except].include?(key)
    end
    true
  end

  # Return array with codes and localized country names 
  # for array of country codes passed as argument
  # == Example
  #   priority_countries_array([:TW, :CN])
  #   # => [ ['Taiwan', 'TW'], ['China', 'CN'] ]
  class_eval %Q{
    def self.priority_#{category}_array(country_codes=[])
      countries = I18n.translate(:#{category})
      country_codes.map { |code| [countries[code.to_s.to_sym]+' ('+code.to_s+')', code.to_s] }
    end
  }
  end
end

module ActionView
  module Helpers

    module FormOptionsHelper
      categories = ['currencies', 'countries', 'languages', 'timezones']

      # Return select and option tags for the given object and method, using +localized_country_options_for_select+
      # to generate the list of option tags. Uses <b>country code</b>, not name as option +value+.
      # Country codes listed as an array of symbols in +priority_countries+ argument will be listed first
      # TODO : Implement pseudo-named args with a hash, not the "somebody said PHP?" multiple args sillines
      categories.each do |category|
      class_eval %Q{
      def localized_#{category.singularize}_select(object, method, priority_countries = nil, options = {}, html_options = {})
        choices = CountrySelectEngine.localized_#{category}_array
        if priority_countries
          priority = CountrySelectEngine::priority_#{category}_array(priority_countries)
          priority << ['--------', nil]
          choices = priority + choices
        end

        Tags::Select.new(object, method, self, choices, options, html_options).render
      end
      }
      end
      alias_method :country_select, :localized_country_select

      # Return "named" select and option tags according to given arguments.
      # Use +selected_value+ for setting initial value
      # It behaves likes older object-binded brother +localized_country_select+ otherwise
      # TODO : Implement pseudo-named args with a hash, not the "somebody said PHP?" multiple args sillines
      categories.each do |category|
      class_eval %Q{
      def localized_#{category.singularize}_select_tag(name, selected_value = nil, priority_countries = nil, options = {}, html_options = {})
        select_tag name.to_sym, localized_#{category.singularize}_options_for_select(selected_value, priority_countries, options).html_safe, html_options.stringify_keys
      end
      }
      end
      alias_method :country_select_tag, :localized_country_select_tag

      # Returns a string of option tags for countries according to locale. Supply the country code in upper-case ('US', 'DE')
      # as +selected+ to have it marked as the selected option tag.
      # Country codes listed as an array of symbols in +priority_countries+ argument will be listed first
      categories.each do |category|
      class_eval %Q{
      def localized_#{category.singularize}_options_for_select(selected = nil, priority_countries = nil, options = {})
        country_options = ""
        if priority_countries
          country_options += options_for_select(CountrySelectEngine::priority_#{category}_array(priority_countries), selected)
          country_options += "<option value='' disabled='disabled'>-------------</option>\n"
          return country_options + options_for_select(CountrySelectEngine::localized_#{category}_array(options) - CountrySelectEngine::priority_#{category}_array(priority_countries), selected)
        else
          return country_options + options_for_select(CountrySelectEngine::localized_#{category}_array(options), selected)
        end
      end
      }
      end
      alias_method :country_options_for_select, :localized_country_options_for_select

    end

    class FormBuilder
      categories = ['currencies', 'countries', 'languages', 'timezones']
      categories.each do |category|
      class_eval %Q{
      def localized_#{category.singularize}_select(method, priority_countries = nil, options = {}, html_options = {})
        @template.localized_#{category.singularize}_select(@object_name, method, priority_countries, objectify_options(options), @default_options.merge(html_options))
      end
      }
      end
      alias_method :country_select, :localized_country_select
    end

  end
end
