Set-WebConfigurationProperty -filter /system.webServer/security/authentication/windowsAuthentication -name enabled -value false -PSPath IIS:\ -location "UTM Web site/RDTServices"

Set-WebConfigurationProperty -filter /system.webServer/security/authentication/anonymousAuthentication -name enabled -value true -PSPath IIS:\ -location "UTM Web site/RDTServices"