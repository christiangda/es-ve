const APP_DESCRIPTION	= "Diccionario español Venezuela";
const APP_AUTHOR		= "christiangda@gmail.com";
const APP_VERSION		= "PKG_MOZ_VERSION";

var err = initInstall(APP_DESCRIPTION, APP_AUTHOR, APP_VERSION);
if (err != SUCCESS)
    cancelInstall();

var fProgram = getFolder("Program");
err = addDirectory("", APP_AUTHOR, "dictionaries", fProgram, "dictionaries", true);

if (err != SUCCESS)
    cancelInstall();

performInstall();
