prestashop-selenium
===================

Some basic PrestaShop Selenium tests - Work In Progress

Currently this script can install PrestaShop in all languages and report success / failure.

#Warning

This will do dangerous things without asking for permission. Use with caution and on development machine :)

#Prerequisite

A decent OS (Linux comes to mind)

#Installation

```bash
bundle install
```

#Configuration

Some options under config/global.yaml:
- root: where to install the PrestaShop versions
- webRoot: URL to access the root folder

#Usage

```bash
app/test-installation.rb
```

#Tips

To hide the browser window run:
```bash
sudo Xvfb :10 -ac
export DISPLAY=:10
```

Before calling the scripts!

#Todo

Currently the scripts assume that the database is accessible by user "root" with no password. Ideally this should be configured in global.yaml. It would be nice to add the options for the installer tests in a yaml config file too.
