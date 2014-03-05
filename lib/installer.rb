require 'logger'
require 'open3'
require 'fileutils'

class Installer
	def initialize config, options={}
		@repo = "https://github.com/PrestaShop/PrestaShop"
		@branch = "release"
		@root = config['root']
		@webRoot = config['webRoot']
		@store = YAML::Store.new "#{File.dirname(__FILE__)}/installed.store"
		@cache = true

		@installLanguage = options[:installLanguage] || 'en'
		@installCountry = options[:installCountry] || 'us'
	end

	def getFilesTo folderPath
		cmd = "git clone #{@repo} -b #{@branch} #{folderPath}"
		clone_status = Open3.popen3 cmd do |i, o, e, t|
			
			i.close
			o.each do |line|
				puts line
			end

			t.value.exitstatus
		end
		clone_status == 0
	end

	def retrieveFilesTo folderPath
		if @cache
			key = 'cache_' + Digest::MD5.hexdigest("@repo:@branch")
			cachePath = File.join(File.dirname(folderPath), key)
			if !File.directory? cachePath
				unless getFilesTo cachePath
					abort "Could not get files!"
				end
			end
			FileUtils.cp_r cachePath, folderPath
			true
		else
			getFilesTo folderPath
		end
	end
	def install
		begin
			unless File.directory? @root
				raise "Could not create directory #{@root}." unless Dir.mkdir @root, 0777 
			end

			install_id = nil
			@store.transaction do 
				install_id = @store['install_id'] = (@store['install_id'] || 0) + 1
			end

			@folderName = "si#{install_id}"
			@folderPath = File.join(@root, @folderName)

			res = if retrieveFilesTo @folderPath
				FileUtils.chmod_R 0777, @folderPath
				@dbName = "selenium_#{@folderName}"
				perform_install :folderName => @folderName,
								:dbName => @dbName,
								:webRoot => "#{@webRoot}/#{@folderName}",
								:installerRoot => "#{@webRoot}/#{@folderName}/install-dev",
								:installLanguage => @installLanguage,
								:installCountry => @installCountry
			else
				false
			end
			cleanup
			res
		rescue Exception => e
			puts e
			cleanup
			return false
		end
	end

	def cleanup
		cmd = "mysql -uroot -e 'drop database if exists #{@dbName}'"
		`#{cmd}` if @dbName
		FileUtils.rm_rf @folderPath
		@driver.quit if @driver
	end

	def perform_install options
		@driver = driver = Selenium::WebDriver.for :firefox
		driver.navigate.to options[:installerRoot]

		langs = driver.find_element(:id => 'langList')
		langs.find_elements(:tag_name => 'option').find do |option|
			option.attribute('value') == options[:installLanguage]
		end.click

		driver.find_element(:id => 'btNext').click
		driver.find_element(:id => 'set_license').click
		driver.find_element(:id => 'btNext').click
		
		driver.find_element(:id => 'infosShop').send_keys options[:folderName]
		driver.find_element(:id => 'infosFirstname').send_keys "John"
		driver.find_element(:id => 'infosName').send_keys "Doe"
		driver.find_element(:id => 'infosEmail').send_keys "pub@prestashop.com"
		driver.find_element(:id => 'infosPassword').send_keys "123456789"
		driver.find_element(:id => 'infosPasswordRepeat').send_keys "123456789"
		
		country_codes = []
		driver.find_element(:id => 'infosCountry').find_elements(:tag_name => 'option').each do |option|
			country_codes << option.attribute('value')
		end
		country_codes = Hash[country_codes.each_with_index.map do |code, n| [code, n] end]

		countries = driver.find_element(:id => 'infosCountry_chosen')
		countries.click
		countries.find_elements(:class => 'active-result').find do |e|
			e.attribute('data-option-array-index').to_i == country_codes[options[:installCountry]].to_i
		end.click
		
		driver.find_element(:id => 'btNext').click
		
		dbNameElement = driver.find_element(:id => 'dbName')
		dbNameElement.clear
		dbNameElement.send_keys(options[:dbName])

		sleep 5
		driver.find_element(:id => 'btNext').click
		sleep 5
		
		puts "Waiting for create DB button..."
		wait0 = Selenium::WebDriver::Wait.new(:timeout => 60)
  		wait0.until { driver.find_element(:id => 'btCreateDB') }
  		driver.find_element(:id => 'btCreateDB').click

  		puts "DB should be created, proceeding..."
		driver.find_element(:id => 'btNext').click

		wait1 = Selenium::WebDriver::Wait.new(:timeout => 60)
  		wait1.until { driver.find_element(:xpath => '//a[@class="FO"]').displayed? }
		true
	end
end