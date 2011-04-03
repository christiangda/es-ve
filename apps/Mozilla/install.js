const APP_DESCRIPTION	= "Diccionario en Español para Venezuela";
const APP_AUTHOR		= "Christian González <christiangda@gmail.com>";
const APP_VERSION		= "PKG_MOZ_VERSION";

var err = initInstall(APP_DESCRIPTION, APP_AUTHOR, APP_VERSION);
if (err != SUCCESS)
    cancelInstall();

var fProgram = getFolder("Program");
err = addDirectory("", APP_AUTHOR, "dictionaries", fProgram, "dictionaries", true);

if (err != SUCCESS)
    cancelInstall();

performInstall();
