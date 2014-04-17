t5x configurator
================
configuration GUI for the Arduino based [t5x](https://github.com/ckonecny/t5x) RC transmitter.


![alt tag](https://raw.github.com/ckonecny/t5x_configurator/branch/resources/images/t5x_configurator.PNG)


t5x configurator is based on the [processing language] (https://www.processing.org/) and heavily uses the [controlp5 library](http://www.sojamo.de/libraries/controlP5/).
Processing has the big advantage since it is based and built with java it supports multiple platforms, such as Windows32, Windows64, MacOS and Linux.

Instructions: 
- download and install [processing] (https://www.processing.org/)
- download and install [controlp5 library](http://www.sojamo.de/libraries/controlP5/)
- place t5x_configurator.pde into your Processing Project folder, e.g. C:\Users\<your username>\Documents\Processing 
- update your t5x transmitter with the [latest firmware](https://github.com/ckonecny/t5x)
- ensure the transmitter is turned off and connect it to your computer
- start the application, select the COM-port and do your configuration.
- the apply button applies the settings to the RAM of the t5x. doing that way you can try your settings and play around with them.
- the save button stores the settings into the EEPROM flash of the t5x.
- note, that there are profile specific settings and t5x device specific settings.
  the device specific settings are global and hence shared by all profiles
  the profile specific settings are intended to be adapted to certain model-specific needs


have fun & great greetings from vienna, austria!
Christian Konecny (alias kornetto)


