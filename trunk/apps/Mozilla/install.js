const ES_VE_APP_DESCRIPTION	= "PKG_MOZ_NAME";
const ES_VE_APP_AUTHOR		= "PKG_MOZ_AUTHOR_NAME <PKG_MOZ_AUTHOR_EMAIL>";
const ES_VE_APP_VERSION		= "PKG_MOZ_VERSION";

var err = initInstall(ES_VE_APP_DESCRIPTION, ES_VE_APP_AUTHOR, ES_VE_APP_VERSION);
if (err != SUCCESS)
    cancelInstall();

var ES_VE_fProgram = getFolder("Program");
err = addDirectory("", ES_VE_APP_AUTHOR, "dictionaries", ES_VE_fProgram, "dictionaries", true);

if (err != SUCCESS)
    cancelInstall();

performInstall();
