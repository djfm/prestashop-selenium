#!/usr/bin/ruby
require 'yaml'
require 'yaml/store'
require 'selenium-webdriver'

require_relative '../lib/installer.rb'

global_config = YAML::load_file('config/global.yaml')

configs = {
	'de' => ['de', 'fr'],
	'en' => ['us', 'fr'],
	'es' => ['es', 'fr'],
	'fr' => ['fr', 'de'],
	'id' => ['id', 'es'],
	'it' => ['it', 'fr'],
	'nl' => ['nl', 'fr'],
	'pl' => ['pl', 'fr'],
	'br' => ['br', 'fr'],
	'ru' => ['ru', 'fr'],
	'bn' => ['bd', 'fr'],
	'tw' => ['tw', 'fr'],
	'zh' => ['cn', 'fr'],
	'mk' => ['mk', 'fr'],
}

configs.each_pair do |installLanguage, cs|
	cs.each do |installCountry|
		options = {:installLanguage => installLanguage, :installCountry => installCountry}
		puts "Installing with #{options}..."
		installer = Installer.new(global_config, options)
		ok = installer.install
		if ok
			puts "Success!!"
		else
			puts "INSTALLATION FAILED: #{options}"
			abort
		end
	end
end