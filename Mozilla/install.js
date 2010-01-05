const APP_DESCRIPTION	= "Corrector Ortográfico en Español para Venezuela";
const APP_AUTHOR		= "${PKG_MOZ_EMAIL}";
const APP_VERSION		= "${PKG_MOZ_VERSION}";

var err = initInstall(APP_DESCRIPTION, APP_AUTHOR, APP_VERSION);
if (err != SUCCESS)
    cancelInstall();

var fProgram = getFolder("Program");
err = addDirectory("", APP_AUTHOR, "dictionaries", fProgram, "dictionaries", true);

if (err != SUCCESS)
    cancelInstall();

performInstall();
