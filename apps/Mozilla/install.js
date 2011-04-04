const APP_DESCRIPTION	= "PKG_MOZ_NAME";
const APP_AUTHOR		= "PKG_MOZ_AUTHOR_NAME <PKG_MOZ_AUTHOR_EMAIL>";
const APP_VERSION		= "PKG_MOZ_VERSION";

var err = initInstall(APP_DESCRIPTION, APP_AUTHOR, APP_VERSION);
if (err != SUCCESS)
    cancelInstall();

var fProgram = getFolder("Program");
err = addDirectory("", APP_AUTHOR, "dictionaries", fProgram, "dictionaries", true);

if (err != SUCCESS)
    cancelInstall();

performInstall();
