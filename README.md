prestashop-selenium
===================

Some basic PrestaShop Selenium tests - Work In Progress

Currently this script can install PrestaShop in all languages and report success / failure.

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
