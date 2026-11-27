-- Destroza Dungeon Tracker - Sprachen / Localization
-- Oberflaechentexte (en, de, es, fr, pt, zh) und sprachabhaengige Daten fuer die
-- Erkennung der Dungeon-Einstiegsschritte in den uebersetzten RXP-Guides.

local _, ns = ...

---------------------------------------------------------------------------
-- Oberflaechentexte
---------------------------------------------------------------------------
local STRINGS = {}

STRINGS.en = {
    TITLE = "Dungeons",
    LV = "Lv",
    COL_DUNGEON = "Dungeon",
    COL_STEPS = "Steps",
    COL_LEVEL = "Level",
    BTN_SHARE = "Share",
    TT_SHARE_TITLE = "Share quests: %s",
    TT_SHARE_NONE = "No shareable quests for this dungeon in your quest log.",
    MSG_SHARE_NOGROUP = "You are not in a group.",
    MSG_SHARE_NONE = "No quests for %s in your quest log that can be shared.",
    MSG_SHARING = "Sharing %d quests for %s: %s",
    BTN_PULL = "Do now",
    BTN_ACTIVE = "Active",
    BTN_BACK = "Back: %s (step %s)",
    STEPS_NOW = "now",
    STEP_ONE = "1 step",
    STEPS_N = "%d steps",
    DUNGEON_GUIDE = "Dungeon guide",

    TT_SECTION = "Section:",
    TT_STEP = "Step:",
    TT_STEP_THERE = "Step there:",
    TT_WOULD_BE_BEFORE = "Would come before step:",
    TT_OF = "%d of %d",
    TT_REMAINING = "Remaining:",
    TT_NOT_IN_GUIDE = "Not part of your guide. Position taken from:",
    TT_ALSO_DISABLED = "It is disabled in your RXP settings there as well.",
    TT_HIDDEN = "This dungeon is disabled in your RXP settings. Its steps are in the guide but hidden.",
    TT_PULL_HINT = "\"%s\": do this dungeon now (you can jump back)",

    ST_NO_RXP = "RestedXP not loaded",
    ST_NO_GUIDE = "No RXP guide loaded",
    ST_SEARCHING = "Searching the guide for dungeons...",
    ST_SEARCHING_SHORT = "Searching...",
    ST_NONE = "No more dungeons in this guide",
    ST_HIDDEN = "* disabled in RXP settings",
    ST_PULLED = "Doing now: %s",

    POPUP = "Do %s now?\n\nRXP switches to:\n%s\n\nYou can return to \"%s\", step %s at any time with the button in the window or /rxpd %s.",
    TARGET_STEP = "%s, step %d",

    MSG_READ_ERROR = "Error while reading the guides: %s",
    MSG_MAIN_LOST = "The saved main guide was not found, jump-back mode ended.",
    MSG_COMBAT = "Not possible in combat.",
    MSG_NO_GUIDE = "No RXP guide loaded.",
    MSG_NO_TARGET = "No matching RXP guide found for %s.",
    MSG_LOAD_FAIL = "RXP could not load the guide: %s",
    MSG_PULLED = "Now doing %s. Go back with the button in the window or /rxpd %s.",
    MSG_NOTHING_PULLED = "No dungeon is being done ahead of time.",
    MSG_MAIN_NOT_FOUND = "Main guide not found: %s",
    MSG_MAIN_LOAD_FAIL = "RXP could not load the main guide: %s",
    MSG_BACK = "Back in %s, step %s.",
    MSG_RECALC = "Recalculated.",
    MSG_MM_NA = "Minimap button not available (LibDBIcon missing).",
    MSG_MM_HIDDEN = "Minimap button hidden. Show it again with /rxpd minimap.",
    MSG_MM_SHOWN = "Minimap button shown.",
    MSG_SHOW_ALL = "Showing all upcoming dungeons.",
    MSG_SHOW_N = "Showing %d dungeon(s).",
    MSG_COUNT_USAGE = "Please enter \"%s\" or a number from 1 to %d, e.g. /rxpd %s 5",
    MSG_LOCKED = "Window locked.",
    MSG_UNLOCKED = "Window unlocked.",
    MSG_POS_RESET = "Position reset.",
    MSG_NEED_RXP = "RestedXP Guides not found - this addon requires RXPGuides.",
    MSG_LANG_SET = "Language: %s",
    MSG_LANG_USAGE = "Usage: /rxpd %s auto | en | de | es | fr | pt | zh",
    MSG_LANG_NO_FONT = "Chinese can only be displayed on a Chinese game client.",

    MM_LEFT = "|cffffffffLeft-click:|r show/hide window",
    MM_RIGHT = "|cffffffffRight-click:|r recalculate",
    MM_DRAG = "|cffffffffDrag:|r move button",

    HELP_TITLE = "Commands:",
    HELP_TOGGLE = "/rxpd  - show/hide window",
    HELP_COUNT = "/rxpd %s %s | 1-%d  - how many dungeons to show",
    HELP_BUTTON = "Button \"%s\"  - do a dungeon now (with jump back)",
    HELP_BACK = "/rxpd %s  - back to the saved step in your main guide",
    HELP_MINIMAP = "/rxpd minimap  - show/hide minimap button",
    HELP_LOCK = "/rxpd lock  - lock/unlock window",
    HELP_RESET = "/rxpd reset  - reset window position",
    HELP_REFRESH = "/rxpd refresh  - recalculate (e.g. after changing RXP dungeon settings)",
    HELP_LANG = "/rxpd %s auto | en | de | ...  - window language",
    HELP_DEBUG = "/rxpd debug  - list the guide sections that were read",

    -- Befehlswoerter, die in der Hilfe angezeigt werden
    MENU_TT = "Settings",
    MENU_LANGUAGE = "Language",
    MENU_AUTO = "Automatic (%s)",
    MENU_COUNT = "Dungeons shown",
    MENU_ALL = "All",
    MENU_OPTIONS = "Options",
    MENU_LOCK = "Lock window",
    MENU_ALERT = "Alert when a dungeon is due",
    ALERT_ENTER = "Time for %s! Enter the dungeon now.",
    MENU_MINIMAP = "Minimap button",
    MENU_REFRESH = "Recalculate",

    EXTRA_GUIDE = "Quest guide",
    TT_EXTRA = "Not part of your route. \"%s\" loads the RestedXP quest guide for it:",



    MENU_SHOW_ALL = "Show all (incl. outleveled)",
    STEPS_PASSED = "passed",



    CMD_COUNT = "count",
    CMD_ALL = "all",
    CMD_BACK = "back",
    CMD_LANG = "lang",
}

STRINGS.de = {
    TITLE = "Dungeons",
    LV = "Lv",
    COL_DUNGEON = "Dungeon",
    COL_STEPS = "Schritte",
    COL_LEVEL = "Level",
    BTN_SHARE = "Teilen",
    TT_SHARE_TITLE = "Quests teilen: %s",
    TT_SHARE_NONE = "Keine teilbaren Quests dieses Dungeons im Questlog.",
    MSG_SHARE_NOGROUP = "Du bist in keiner Gruppe.",
    MSG_SHARE_NONE = "Keine teilbaren Quests für %s im Questlog.",
    MSG_SHARING = "Teile %d Quests für %s: %s",
    BTN_PULL = "Vorziehen",
    BTN_ACTIVE = "Aktiv",
    BTN_BACK = "Zurück: %s (Schritt %s)",
    STEPS_NOW = "jetzt",
    STEP_ONE = "1 Schritt",
    STEPS_N = "%d Schritte",
    DUNGEON_GUIDE = "Dungeon-Guide",

    TT_SECTION = "Abschnitt:",
    TT_STEP = "Schritt:",
    TT_STEP_THERE = "Schritt dort:",
    TT_WOULD_BE_BEFORE = "Käme vor Schritt:",
    TT_OF = "%d von %d",
    TT_REMAINING = "Noch:",
    TT_NOT_IN_GUIDE = "Kommt in deinem Guide nicht vor. Die Position stammt aus:",
    TT_ALSO_DISABLED = "Auch dort ist er in deinen RXP-Settings nicht aktiv.",
    TT_HIDDEN = "Dieser Dungeon ist in deinen RXP-Settings nicht aktiv. Die Schritte dafür stehen im Guide, werden aber ausgeblendet.",
    TT_PULL_HINT = "\"%s\": Dungeon jetzt machen (mit Rücksprung)",

    ST_NO_RXP = "RestedXP nicht geladen",
    ST_NO_GUIDE = "Kein RXP-Guide geladen",
    ST_SEARCHING = "Suche Dungeons im Guide-Verlauf ...",
    ST_SEARCHING_SHORT = "Suche ...",
    ST_NONE = "Keine Dungeons im weiteren Guide-Verlauf",
    ST_HIDDEN = "* in RXP-Settings deaktiviert",
    ST_PULLED = "Vorgezogen: %s",

    POPUP = "%s jetzt vorziehen?\n\nRXP wechselt zu:\n%s\n\nZurück zu \"%s\", Schritt %s geht jederzeit über den Button im Fenster oder /rxpd %s.",
    TARGET_STEP = "%s, Schritt %d",

    MSG_READ_ERROR = "Fehler beim Lesen der Guides: %s",
    MSG_MAIN_LOST = "Der gespeicherte Hauptguide wurde nicht gefunden, Vorzieh-Modus beendet.",
    MSG_COMBAT = "Im Kampf nicht möglich.",
    MSG_NO_GUIDE = "Kein RXP-Guide geladen.",
    MSG_NO_TARGET = "Kein passender RXP-Guide für %s gefunden.",
    MSG_LOAD_FAIL = "RXP konnte den Guide nicht laden: %s",
    MSG_PULLED = "%s vorgezogen. Zurück mit dem Button im Fenster oder /rxpd %s.",
    MSG_NOTHING_PULLED = "Kein Dungeon vorgezogen.",
    MSG_MAIN_NOT_FOUND = "Hauptguide nicht gefunden: %s",
    MSG_MAIN_LOAD_FAIL = "RXP konnte den Hauptguide nicht laden: %s",
    MSG_BACK = "Zurück in %s, Schritt %s.",
    MSG_RECALC = "Neu berechnet.",
    MSG_MM_NA = "Minimap-Button nicht verfügbar (LibDBIcon fehlt).",
    MSG_MM_HIDDEN = "Minimap-Button ausgeblendet. Mit /rxpd minimap wieder einblenden.",
    MSG_MM_SHOWN = "Minimap-Button eingeblendet.",
    MSG_SHOW_ALL = "Zeige alle kommenden Dungeons.",
    MSG_SHOW_N = "Zeige %d Dungeon(s).",
    MSG_COUNT_USAGE = "Bitte \"%s\" oder eine Zahl von 1 bis %d angeben, z. B. /rxpd %s 5",
    MSG_LOCKED = "Fenster fixiert.",
    MSG_UNLOCKED = "Fenster verschiebbar.",
    MSG_POS_RESET = "Position zurückgesetzt.",
    MSG_NEED_RXP = "RestedXP Guides wurde nicht gefunden - das Addon braucht RXPGuides.",
    MSG_LANG_SET = "Sprache: %s",
    MSG_LANG_USAGE = "Benutzung: /rxpd %s auto | en | de | es | fr | pt | zh",
    MSG_LANG_NO_FONT = "Chinesisch kann nur ein chinesischer Spielclient darstellen.",

    MM_LEFT = "|cffffffffLinksklick:|r Fenster ein/aus",
    MM_RIGHT = "|cffffffffRechtsklick:|r neu berechnen",
    MM_DRAG = "|cffffffffZiehen:|r Button verschieben",

    HELP_TITLE = "Befehle:",
    HELP_TOGGLE = "/rxpd  - Fenster ein/aus",
    HELP_COUNT = "/rxpd %s %s | 1-%d  - wie viele Dungeons angezeigt werden",
    HELP_BUTTON = "Knopf \"%s\"  - Dungeon jetzt machen (mit Rücksprung)",
    HELP_BACK = "/rxpd %s  - zurück zum gemerkten Schritt im Hauptguide",
    HELP_MINIMAP = "/rxpd minimap  - Minimap-Button ein/aus",
    HELP_LOCK = "/rxpd lock  - Fenster fixieren/lösen",
    HELP_RESET = "/rxpd reset  - Fensterposition zurücksetzen",
    HELP_REFRESH = "/rxpd refresh  - neu berechnen (z. B. nach Änderung der RXP-Dungeon-Settings)",
    HELP_LANG = "/rxpd %s auto | en | de | ...  - Sprache des Fensters",
    HELP_DEBUG = "/rxpd debug  - gelesene Guide-Abschnitte im Chat auflisten",

    MENU_TT = "Einstellungen",
    MENU_LANGUAGE = "Sprache",
    MENU_AUTO = "Automatisch (%s)",
    MENU_COUNT = "Angezeigte Dungeons",
    MENU_ALL = "Alle",
    MENU_OPTIONS = "Optionen",
    MENU_LOCK = "Fenster fixieren",
    MENU_ALERT = "Hinweis, wenn ein Dungeon dran ist",
    ALERT_ENTER = "Jetzt %s! Zeit, den Dungeon zu betreten.",
    MENU_MINIMAP = "Minimap-Button",
    MENU_REFRESH = "Neu berechnen",

    EXTRA_GUIDE = "Quest-Guide",
    TT_EXTRA = "Kommt in deiner Route nicht vor. „%s“ lädt den RestedXP-Quest-Guide dafür:",



    MENU_SHOW_ALL = "Alle anzeigen (auch überlevelte)",
    STEPS_PASSED = "vorbei",



    CMD_COUNT = "anzahl",
    CMD_ALL = "alle",
    CMD_BACK = "zurueck",
    CMD_LANG = "sprache",
}

STRINGS.es = {
    TITLE = "Mazmorras",
    LV = "Nv",
    COL_DUNGEON = "Mazmorra",
    COL_STEPS = "Pasos",
    COL_LEVEL = "Nivel",
    BTN_SHARE = "Compartir",
    TT_SHARE_TITLE = "Compartir misiones: %s",
    TT_SHARE_NONE = "No hay misiones compartibles de esta mazmorra en tu registro.",
    MSG_SHARE_NOGROUP = "No estás en un grupo.",
    MSG_SHARE_NONE = "No hay misiones compartibles de %s en tu registro.",
    MSG_SHARING = "Compartiendo %d misiones de %s: %s",
    BTN_PULL = "Adelantar",
    BTN_ACTIVE = "Activo",
    BTN_BACK = "Volver: %s (paso %s)",
    STEPS_NOW = "ahora",
    STEP_ONE = "1 paso",
    STEPS_N = "%d pasos",
    DUNGEON_GUIDE = "Guía mazmorras",

    TT_SECTION = "Sección:",
    TT_STEP = "Paso:",
    TT_STEP_THERE = "Paso allí:",
    TT_WOULD_BE_BEFORE = "Iría antes del paso:",
    TT_OF = "%d de %d",
    TT_REMAINING = "Faltan:",
    TT_NOT_IN_GUIDE = "No aparece en tu guía. La posición procede de:",
    TT_ALSO_DISABLED = "Allí también está desactivada en tus ajustes de RXP.",
    TT_HIDDEN = "Esta mazmorra está desactivada en tus ajustes de RXP. Sus pasos están en la guía, pero ocultos.",
    TT_PULL_HINT = "\"%s\": hacer esta mazmorra ahora (puedes volver)",

    ST_NO_RXP = "RestedXP no está cargado",
    ST_NO_GUIDE = "Ninguna guía de RXP cargada",
    ST_SEARCHING = "Buscando mazmorras en la guía...",
    ST_SEARCHING_SHORT = "Buscando...",
    ST_NONE = "No hay más mazmorras en esta guía",
    ST_HIDDEN = "* desactivada en los ajustes de RXP",
    ST_PULLED = "Adelantada: %s",

    POPUP = "¿Adelantar %s ahora?\n\nRXP cambia a:\n%s\n\nPuedes volver a \"%s\", paso %s en cualquier momento con el botón de la ventana o /rxpd %s.",
    TARGET_STEP = "%s, paso %d",

    MSG_READ_ERROR = "Error al leer las guías: %s",
    MSG_MAIN_LOST = "No se encontró la guía principal guardada; modo adelantar finalizado.",
    MSG_COMBAT = "No es posible en combate.",
    MSG_NO_GUIDE = "Ninguna guía de RXP cargada.",
    MSG_NO_TARGET = "No se encontró una guía de RXP para %s.",
    MSG_LOAD_FAIL = "RXP no pudo cargar la guía: %s",
    MSG_PULLED = "%s adelantada. Vuelve con el botón de la ventana o /rxpd %s.",
    MSG_NOTHING_PULLED = "No hay ninguna mazmorra adelantada.",
    MSG_MAIN_NOT_FOUND = "Guía principal no encontrada: %s",
    MSG_MAIN_LOAD_FAIL = "RXP no pudo cargar la guía principal: %s",
    MSG_BACK = "De vuelta en %s, paso %s.",
    MSG_RECALC = "Recalculado.",
    MSG_MM_NA = "Botón del minimapa no disponible (falta LibDBIcon).",
    MSG_MM_HIDDEN = "Botón del minimapa oculto. Muéstralo de nuevo con /rxpd minimap.",
    MSG_MM_SHOWN = "Botón del minimapa visible.",
    MSG_SHOW_ALL = "Mostrando todas las mazmorras siguientes.",
    MSG_SHOW_N = "Mostrando %d mazmorra(s).",
    MSG_COUNT_USAGE = "Indica \"%s\" o un número del 1 al %d, p. ej. /rxpd %s 5",
    MSG_LOCKED = "Ventana bloqueada.",
    MSG_UNLOCKED = "Ventana desbloqueada.",
    MSG_POS_RESET = "Posición restablecida.",
    MSG_NEED_RXP = "No se encontró RestedXP Guides; este addon necesita RXPGuides.",
    MSG_LANG_SET = "Idioma: %s",
    MSG_LANG_USAGE = "Uso: /rxpd %s auto | en | de | es | fr | pt | zh",
    MSG_LANG_NO_FONT = "El chino solo se puede mostrar en un cliente chino.",

    MM_LEFT = "|cffffffffClic izquierdo:|r mostrar/ocultar ventana",
    MM_RIGHT = "|cffffffffClic derecho:|r recalcular",
    MM_DRAG = "|cffffffffArrastrar:|r mover botón",

    HELP_TITLE = "Comandos:",
    HELP_TOGGLE = "/rxpd  - mostrar/ocultar ventana",
    HELP_COUNT = "/rxpd %s %s | 1-%d  - cuántas mazmorras mostrar",
    HELP_BUTTON = "Botón \"%s\"  - hacer una mazmorra ahora (con vuelta)",
    HELP_BACK = "/rxpd %s  - volver al paso guardado de tu guía principal",
    HELP_MINIMAP = "/rxpd minimap  - mostrar/ocultar botón del minimapa",
    HELP_LOCK = "/rxpd lock  - bloquear/desbloquear ventana",
    HELP_RESET = "/rxpd reset  - restablecer posición de la ventana",
    HELP_REFRESH = "/rxpd refresh  - recalcular (p. ej. tras cambiar los ajustes de mazmorras de RXP)",
    HELP_LANG = "/rxpd %s auto | en | de | ...  - idioma de la ventana",
    HELP_DEBUG = "/rxpd debug  - listar las secciones de guía leídas",

    MENU_TT = "Ajustes",
    MENU_LANGUAGE = "Idioma",
    MENU_AUTO = "Automático (%s)",
    MENU_COUNT = "Mazmorras mostradas",
    MENU_ALL = "Todas",
    MENU_OPTIONS = "Opciones",
    MENU_LOCK = "Bloquear ventana",
    MENU_ALERT = "Aviso cuando toca una mazmorra",
    ALERT_ENTER = "¡Hora de %s! Entra ahora en la mazmorra.",
    MENU_MINIMAP = "Botón del minimapa",
    MENU_REFRESH = "Recalcular",

    EXTRA_GUIDE = "Guía de misiones",
    TT_EXTRA = "No forma parte de tu ruta. \"%s\" carga la guía de misiones de RestedXP:",



    MENU_SHOW_ALL = "Mostrar todas (incl. superadas)",
    STEPS_PASSED = "pasada",



    CMD_COUNT = "count",
    CMD_ALL = "all",
    CMD_BACK = "back",
    CMD_LANG = "lang",
}

STRINGS.fr = {
    TITLE = "Donjons",
    LV = "Niv",
    COL_DUNGEON = "Donjon",
    COL_STEPS = "Étapes",
    COL_LEVEL = "Niveau",
    BTN_SHARE = "Partager",
    TT_SHARE_TITLE = "Partager les quêtes : %s",
    TT_SHARE_NONE = "Aucune quête partageable de ce donjon dans ton journal.",
    MSG_SHARE_NOGROUP = "Tu n'es pas dans un groupe.",
    MSG_SHARE_NONE = "Aucune quête partageable pour %s dans ton journal.",
    MSG_SHARING = "Partage de %d quêtes pour %s : %s",
    BTN_PULL = "Avancer",
    BTN_ACTIVE = "Actif",
    BTN_BACK = "Retour : %s (étape %s)",
    STEPS_NOW = "maintenant",
    STEP_ONE = "1 étape",
    STEPS_N = "%d étapes",
    DUNGEON_GUIDE = "Guide donjons",

    TT_SECTION = "Section :",
    TT_STEP = "Étape :",
    TT_STEP_THERE = "Étape là-bas :",
    TT_WOULD_BE_BEFORE = "Viendrait avant l'étape :",
    TT_OF = "%d sur %d",
    TT_REMAINING = "Restant :",
    TT_NOT_IN_GUIDE = "Absent de ton guide. Position tirée de :",
    TT_ALSO_DISABLED = "Il y est aussi désactivé dans tes paramètres RXP.",
    TT_HIDDEN = "Ce donjon est désactivé dans tes paramètres RXP. Ses étapes sont dans le guide, mais masquées.",
    TT_PULL_HINT = "« %s » : faire ce donjon maintenant (retour possible)",

    ST_NO_RXP = "RestedXP n'est pas chargé",
    ST_NO_GUIDE = "Aucun guide RXP chargé",
    ST_SEARCHING = "Recherche des donjons dans le guide...",
    ST_SEARCHING_SHORT = "Recherche...",
    ST_NONE = "Plus aucun donjon dans ce guide",
    ST_HIDDEN = "* désactivé dans les paramètres RXP",
    ST_PULLED = "Avancé : %s",

    POPUP = "Faire %s maintenant ?\n\nRXP passe à :\n%s\n\nTu peux revenir à « %s », étape %s à tout moment avec le bouton de la fenêtre ou /rxpd %s.",
    TARGET_STEP = "%s, étape %d",

    MSG_READ_ERROR = "Erreur lors de la lecture des guides : %s",
    MSG_MAIN_LOST = "Le guide principal enregistré est introuvable, mode avance terminé.",
    MSG_COMBAT = "Impossible en combat.",
    MSG_NO_GUIDE = "Aucun guide RXP chargé.",
    MSG_NO_TARGET = "Aucun guide RXP trouvé pour %s.",
    MSG_LOAD_FAIL = "RXP n'a pas pu charger le guide : %s",
    MSG_PULLED = "%s avancé. Retour avec le bouton de la fenêtre ou /rxpd %s.",
    MSG_NOTHING_PULLED = "Aucun donjon avancé.",
    MSG_MAIN_NOT_FOUND = "Guide principal introuvable : %s",
    MSG_MAIN_LOAD_FAIL = "RXP n'a pas pu charger le guide principal : %s",
    MSG_BACK = "De retour dans %s, étape %s.",
    MSG_RECALC = "Recalculé.",
    MSG_MM_NA = "Bouton de la minicarte indisponible (LibDBIcon manquant).",
    MSG_MM_HIDDEN = "Bouton de la minicarte masqué. Réaffiche-le avec /rxpd minimap.",
    MSG_MM_SHOWN = "Bouton de la minicarte affiché.",
    MSG_SHOW_ALL = "Affichage de tous les donjons à venir.",
    MSG_SHOW_N = "Affichage de %d donjon(s).",
    MSG_COUNT_USAGE = "Indique « %s » ou un nombre de 1 à %d, p. ex. /rxpd %s 5",
    MSG_LOCKED = "Fenêtre verrouillée.",
    MSG_UNLOCKED = "Fenêtre déverrouillée.",
    MSG_POS_RESET = "Position réinitialisée.",
    MSG_NEED_RXP = "RestedXP Guides introuvable - cet addon nécessite RXPGuides.",
    MSG_LANG_SET = "Langue : %s",
    MSG_LANG_USAGE = "Utilisation : /rxpd %s auto | en | de | es | fr | pt | zh",
    MSG_LANG_NO_FONT = "Le chinois ne peut s'afficher que sur un client chinois.",

    MM_LEFT = "|cffffffffClic gauche :|r afficher/masquer la fenêtre",
    MM_RIGHT = "|cffffffffClic droit :|r recalculer",
    MM_DRAG = "|cffffffffGlisser :|r déplacer le bouton",

    HELP_TITLE = "Commandes :",
    HELP_TOGGLE = "/rxpd  - afficher/masquer la fenêtre",
    HELP_COUNT = "/rxpd %s %s | 1-%d  - nombre de donjons affichés",
    HELP_BUTTON = "Bouton « %s »  - faire un donjon maintenant (avec retour)",
    HELP_BACK = "/rxpd %s  - revenir à l'étape enregistrée du guide principal",
    HELP_MINIMAP = "/rxpd minimap  - afficher/masquer le bouton de la minicarte",
    HELP_LOCK = "/rxpd lock  - verrouiller/déverrouiller la fenêtre",
    HELP_RESET = "/rxpd reset  - réinitialiser la position de la fenêtre",
    HELP_REFRESH = "/rxpd refresh  - recalculer (p. ex. après avoir modifié les paramètres de donjons RXP)",
    HELP_LANG = "/rxpd %s auto | en | de | ...  - langue de la fenêtre",
    HELP_DEBUG = "/rxpd debug  - lister les sections de guide lues",

    MENU_TT = "Paramètres",
    MENU_LANGUAGE = "Langue",
    MENU_AUTO = "Automatique (%s)",
    MENU_COUNT = "Donjons affichés",
    MENU_ALL = "Tous",
    MENU_OPTIONS = "Options",
    MENU_LOCK = "Verrouiller la fenêtre",
    MENU_ALERT = "Alerte quand un donjon est prévu",
    ALERT_ENTER = "C'est l'heure de %s ! Entre maintenant dans le donjon.",
    MENU_MINIMAP = "Bouton de la minicarte",
    MENU_REFRESH = "Recalculer",

    EXTRA_GUIDE = "Guide de quêtes",
    TT_EXTRA = "Ne fait pas partie de ton itinéraire. « %s » charge le guide de quêtes RestedXP :",



    MENU_SHOW_ALL = "Tout afficher (même dépassés)",
    STEPS_PASSED = "passé",



    CMD_COUNT = "count",
    CMD_ALL = "all",
    CMD_BACK = "back",
    CMD_LANG = "lang",
}

STRINGS.pt = {
    TITLE = "Masmorras",
    LV = "Nv",
    COL_DUNGEON = "Masmorra",
    COL_STEPS = "Passos",
    COL_LEVEL = "Nível",
    BTN_SHARE = "Partilhar",
    TT_SHARE_TITLE = "Partilhar missões: %s",
    TT_SHARE_NONE = "Nenhuma missão partilhável desta masmorra no registro.",
    MSG_SHARE_NOGROUP = "Você não está em um grupo.",
    MSG_SHARE_NONE = "Nenhuma missão partilhável de %s no registro.",
    MSG_SHARING = "Partilhando %d missões de %s: %s",
    BTN_PULL = "Antecipar",
    BTN_ACTIVE = "Ativo",
    BTN_BACK = "Voltar: %s (passo %s)",
    STEPS_NOW = "agora",
    STEP_ONE = "1 passo",
    STEPS_N = "%d passos",
    DUNGEON_GUIDE = "Guia masmorras",

    TT_SECTION = "Seção:",
    TT_STEP = "Passo:",
    TT_STEP_THERE = "Passo lá:",
    TT_WOULD_BE_BEFORE = "Viria antes do passo:",
    TT_OF = "%d de %d",
    TT_REMAINING = "Faltam:",
    TT_NOT_IN_GUIDE = "Não aparece no seu guia. Posição tirada de:",
    TT_ALSO_DISABLED = "Lá também está desativada nas suas configurações do RXP.",
    TT_HIDDEN = "Esta masmorra está desativada nas suas configurações do RXP. Os passos estão no guia, mas ocultos.",
    TT_PULL_HINT = "\"%s\": fazer esta masmorra agora (dá para voltar)",

    ST_NO_RXP = "RestedXP não carregado",
    ST_NO_GUIDE = "Nenhum guia do RXP carregado",
    ST_SEARCHING = "Procurando masmorras no guia...",
    ST_SEARCHING_SHORT = "Procurando...",
    ST_NONE = "Não há mais masmorras neste guia",
    ST_HIDDEN = "* desativada nas configurações do RXP",
    ST_PULLED = "Antecipada: %s",

    POPUP = "Antecipar %s agora?\n\nO RXP muda para:\n%s\n\nVocê pode voltar para \"%s\", passo %s a qualquer momento pelo botão da janela ou /rxpd %s.",
    TARGET_STEP = "%s, passo %d",

    MSG_READ_ERROR = "Erro ao ler os guias: %s",
    MSG_MAIN_LOST = "O guia principal salvo não foi encontrado; modo antecipar encerrado.",
    MSG_COMBAT = "Não é possível em combate.",
    MSG_NO_GUIDE = "Nenhum guia do RXP carregado.",
    MSG_NO_TARGET = "Nenhum guia do RXP encontrado para %s.",
    MSG_LOAD_FAIL = "O RXP não conseguiu carregar o guia: %s",
    MSG_PULLED = "%s antecipada. Volte pelo botão da janela ou /rxpd %s.",
    MSG_NOTHING_PULLED = "Nenhuma masmorra antecipada.",
    MSG_MAIN_NOT_FOUND = "Guia principal não encontrado: %s",
    MSG_MAIN_LOAD_FAIL = "O RXP não conseguiu carregar o guia principal: %s",
    MSG_BACK = "De volta em %s, passo %s.",
    MSG_RECALC = "Recalculado.",
    MSG_MM_NA = "Botão do minimapa indisponível (LibDBIcon ausente).",
    MSG_MM_HIDDEN = "Botão do minimapa oculto. Mostre de novo com /rxpd minimap.",
    MSG_MM_SHOWN = "Botão do minimapa visível.",
    MSG_SHOW_ALL = "Mostrando todas as próximas masmorras.",
    MSG_SHOW_N = "Mostrando %d masmorra(s).",
    MSG_COUNT_USAGE = "Informe \"%s\" ou um número de 1 a %d, ex.: /rxpd %s 5",
    MSG_LOCKED = "Janela travada.",
    MSG_UNLOCKED = "Janela destravada.",
    MSG_POS_RESET = "Posição redefinida.",
    MSG_NEED_RXP = "RestedXP Guides não encontrado - este addon precisa do RXPGuides.",
    MSG_LANG_SET = "Idioma: %s",
    MSG_LANG_USAGE = "Uso: /rxpd %s auto | en | de | es | fr | pt | zh",
    MSG_LANG_NO_FONT = "Chinês só pode ser exibido em um cliente chinês.",

    MM_LEFT = "|cffffffffClique esquerdo:|r mostrar/ocultar janela",
    MM_RIGHT = "|cffffffffClique direito:|r recalcular",
    MM_DRAG = "|cffffffffArrastar:|r mover botão",

    HELP_TITLE = "Comandos:",
    HELP_TOGGLE = "/rxpd  - mostrar/ocultar janela",
    HELP_COUNT = "/rxpd %s %s | 1-%d  - quantas masmorras mostrar",
    HELP_BUTTON = "Botão \"%s\"  - fazer uma masmorra agora (com retorno)",
    HELP_BACK = "/rxpd %s  - voltar ao passo salvo no guia principal",
    HELP_MINIMAP = "/rxpd minimap  - mostrar/ocultar botão do minimapa",
    HELP_LOCK = "/rxpd lock  - travar/destravar janela",
    HELP_RESET = "/rxpd reset  - redefinir posição da janela",
    HELP_REFRESH = "/rxpd refresh  - recalcular (ex.: após mudar as configurações de masmorras do RXP)",
    HELP_LANG = "/rxpd %s auto | en | de | ...  - idioma da janela",
    HELP_DEBUG = "/rxpd debug  - listar as seções de guia lidas",

    MENU_TT = "Configurações",
    MENU_LANGUAGE = "Idioma",
    MENU_AUTO = "Automático (%s)",
    MENU_COUNT = "Masmorras exibidas",
    MENU_ALL = "Todas",
    MENU_OPTIONS = "Opções",
    MENU_LOCK = "Travar janela",
    MENU_ALERT = "Aviso quando uma masmorra chega",
    ALERT_ENTER = "Hora de %s! Entre agora na masmorra.",
    MENU_MINIMAP = "Botão do minimapa",
    MENU_REFRESH = "Recalcular",

    EXTRA_GUIDE = "Guia de missões",
    TT_EXTRA = "Não faz parte da sua rota. \"%s\" carrega o guia de missões do RestedXP:",



    MENU_SHOW_ALL = "Mostrar todas (incl. ultrapassadas)",
    STEPS_PASSED = "passou",



    CMD_COUNT = "count",
    CMD_ALL = "all",
    CMD_BACK = "back",
    CMD_LANG = "lang",
}

STRINGS.zh = {
    TITLE = "地下城",
    LV = "Lv",
    COL_DUNGEON = "地下城",
    COL_STEPS = "步骤",
    COL_LEVEL = "等级",
    BTN_SHARE = "共享",
    TT_SHARE_TITLE = "共享任务：%s",
    TT_SHARE_NONE = "任务日志中没有此地下城可共享的任务。",
    MSG_SHARE_NOGROUP = "你不在队伍中。",
    MSG_SHARE_NONE = "任务日志中没有 %s 可共享的任务。",
    MSG_SHARING = "正在共享 %d 个 %s 任务：%s",
    BTN_PULL = "提前做",
    BTN_ACTIVE = "进行中",
    BTN_BACK = "返回：%s（第 %s 步）",
    STEPS_NOW = "现在",
    STEP_ONE = "1 步",
    STEPS_N = "%d 步",
    DUNGEON_GUIDE = "地下城指南",

    TT_SECTION = "章节：",
    TT_STEP = "步骤：",
    TT_STEP_THERE = "该处步骤：",
    TT_WOULD_BE_BEFORE = "将位于此步之前：",
    TT_OF = "%d / %d",
    TT_REMAINING = "剩余：",
    TT_NOT_IN_GUIDE = "你的指南中没有此地下城。位置来自：",
    TT_ALSO_DISABLED = "在那里它同样在你的 RXP 设置中被禁用。",
    TT_HIDDEN = "此地下城在你的 RXP 设置中被禁用。相关步骤在指南中，但被隐藏。",
    TT_PULL_HINT = "“%s”：现在就做这个地下城（可以返回）",

    ST_NO_RXP = "未加载 RestedXP",
    ST_NO_GUIDE = "未加载 RXP 指南",
    ST_SEARCHING = "正在指南中查找地下城……",
    ST_SEARCHING_SHORT = "查找中……",
    ST_NONE = "此指南后续没有地下城",
    ST_HIDDEN = "* 在 RXP 设置中已禁用",
    ST_PULLED = "提前进行：%s",

    POPUP = "现在提前做 %s？\n\nRXP 将切换到：\n%s\n\n你可以随时返回“%s”第 %s 步（使用窗口中的按钮或 /rxpd %s）。",
    TARGET_STEP = "%s，第 %d 步",

    MSG_READ_ERROR = "读取指南时出错：%s",
    MSG_MAIN_LOST = "未找到已保存的主指南，提前模式已结束。",
    MSG_COMBAT = "战斗中无法进行。",
    MSG_NO_GUIDE = "未加载 RXP 指南。",
    MSG_NO_TARGET = "未找到 %s 对应的 RXP 指南。",
    MSG_LOAD_FAIL = "RXP 无法加载指南：%s",
    MSG_PULLED = "已提前 %s。可通过窗口中的按钮或 /rxpd %s 返回。",
    MSG_NOTHING_PULLED = "当前没有提前进行的地下城。",
    MSG_MAIN_NOT_FOUND = "未找到主指南：%s",
    MSG_MAIN_LOAD_FAIL = "RXP 无法加载主指南：%s",
    MSG_BACK = "已返回 %s，第 %s 步。",
    MSG_RECALC = "已重新计算。",
    MSG_MM_NA = "小地图按钮不可用（缺少 LibDBIcon）。",
    MSG_MM_HIDDEN = "小地图按钮已隐藏。使用 /rxpd minimap 重新显示。",
    MSG_MM_SHOWN = "小地图按钮已显示。",
    MSG_SHOW_ALL = "显示所有后续地下城。",
    MSG_SHOW_N = "显示 %d 个地下城。",
    MSG_COUNT_USAGE = "请输入“%s”或 1 到 %d 之间的数字，例如 /rxpd %s 5",
    MSG_LOCKED = "窗口已锁定。",
    MSG_UNLOCKED = "窗口已解锁。",
    MSG_POS_RESET = "位置已重置。",
    MSG_NEED_RXP = "未找到 RestedXP Guides —— 此插件需要 RXPGuides。",
    MSG_LANG_SET = "语言：%s",
    MSG_LANG_USAGE = "用法：/rxpd %s auto | en | de | es | fr | pt | zh",
    MSG_LANG_NO_FONT = "中文只能在中文客户端上显示。",

    MM_LEFT = "|cffffffff左键：|r 显示/隐藏窗口",
    MM_RIGHT = "|cffffffff右键：|r 重新计算",
    MM_DRAG = "|cffffffff拖动：|r 移动按钮",

    HELP_TITLE = "命令：",
    HELP_TOGGLE = "/rxpd  - 显示/隐藏窗口",
    HELP_COUNT = "/rxpd %s %s | 1-%d  - 显示多少个地下城",
    HELP_BUTTON = "按钮“%s”  - 现在就做一个地下城（可返回）",
    HELP_BACK = "/rxpd %s  - 返回主指南中保存的步骤",
    HELP_MINIMAP = "/rxpd minimap  - 显示/隐藏小地图按钮",
    HELP_LOCK = "/rxpd lock  - 锁定/解锁窗口",
    HELP_RESET = "/rxpd reset  - 重置窗口位置",
    HELP_REFRESH = "/rxpd refresh  - 重新计算（例如更改 RXP 地下城设置后）",
    HELP_LANG = "/rxpd %s auto | en | de | ...  - 窗口语言",
    HELP_DEBUG = "/rxpd debug  - 列出已读取的指南章节",

    MENU_TT = "设置",
    MENU_LANGUAGE = "语言",
    MENU_AUTO = "自动（%s）",
    MENU_COUNT = "显示的地下城",
    MENU_ALL = "全部",
    MENU_OPTIONS = "选项",
    MENU_LOCK = "锁定窗口",
    MENU_ALERT = "轮到地下城时提醒",
    ALERT_ENTER = "该去%s了！现在进入地下城。",
    MENU_MINIMAP = "小地图按钮",
    MENU_REFRESH = "重新计算",

    EXTRA_GUIDE = "任务指南",
    TT_EXTRA = "不在你的路线中。“%s”会加载对应的 RestedXP 任务指南：",



    MENU_SHOW_ALL = "显示全部（包括等级已过的）",
    STEPS_PASSED = "已过",



    CMD_COUNT = "count",
    CMD_ALL = "all",
    CMD_BACK = "back",
    CMD_LANG = "lang",
}

-- Spielclient-Sprache -> Oberflaechensprache
local CLIENT_TO_LANG = {
    enUS = "en", enGB = "en", deDE = "de", esES = "es", esMX = "es",
    frFR = "fr", ptBR = "pt", ptPT = "pt", zhCN = "zh", zhTW = "zh",
}

ns.LANGUAGES = { "en", "de", "es", "fr", "pt", "zh" }

local current = STRINGS.en
ns.L = setmetatable({}, {
    __index = function(_, key)
        return current[key] or STRINGS.en[key] or key
    end,
})

function ns.ClientLanguage()
    return CLIENT_TO_LANG[GetLocale and GetLocale() or "enUS"] or "en"
end

-- "auto" oder nil = Sprache des Spielclients
function ns.SetLanguage(code)
    if not code or code == "auto" or not STRINGS[code] then
        code = ns.ClientLanguage()
    end
    current = STRINGS[code] or STRINGS.en
    ns.activeLanguage = code
    return code
end

function ns.CanDisplay(code)
    if code == "zh" then
        local loc = GetLocale and GetLocale() or ""
        return loc == "zhCN" or loc == "zhTW"
    end
    return true
end

ns.SetLanguage("auto")

---------------------------------------------------------------------------
-- Erkennung in uebersetzten Guides
-- Die Texte werden vor dem Vergleich mit string.lower() verglichen. Das senkt nur
-- A-Z ab; Umlaute/Akzente bleiben wie im Guide geschrieben (z. B. "Ígnea").
---------------------------------------------------------------------------
ns.DETECT = {
    deDE = {
        enter = { "betretet", "betrete", "betritt", "tretet ein", "instanzportal" },
        leave = { "verlasst", "verlass" },
        names = {
            RFC = { "flammenschlund" }, WC = { "höhlen des wehklagens", "hdw" },
            DM = { "todesminen" }, SFK = { "burg schattenfang" }, BFD = { "tiefschwarze grotte" },
            STOCKS = { "verlies" }, RFK = { "kral der klingenhauer" }, SM = { "scharlachrote kloster", "scharlachroten kloster" },
            RFD = { "hügel der klingenhauer" }, ST = { "versunkene tempel", "versunkenen tempel" },
            BRD = { "schwarzfelstiefen" }, LBRS = { "untere schwarzfelsspitze" }, UBRS = { "obere schwarzfelsspitze" },
            DME = { "düsterbruch" }, HOT = { "halle der thanen" }, ROL = { "ruinen von lordaeron" },
            COD = { "stadt dalaran" },
        },
    },
    esES = {
        enter = { "entra en", "entra a", "entra por", "entrar en" },
        leave = { "sal de" },
        names = {
            RFC = { "sima Ígnea", "sima ígnea" }, WC = { "cuevas de los lamentos" }, DM = { "minas de la muerte" },
            SFK = { "castillo de colmillo oscuro" }, BFD = { "cavernas de brazanegra" }, STOCKS = { "mazmorras de ventormenta" },
            RFK = { "horado rajacieno" }, SM = { "monasterio escarlata" }, RFD = { "zahúrda rajacieno" },
            ST = { "templo sumergido" }, BRD = { "profundidades de roca negra" }, DME = { "la masacre" },
            HOT = { "salón de señores feudales" }, ROL = { "ruinas de lordaeron" },
        },
    },
    frFR = {
        enter = { "entrez", "entrer" },
        leave = { "sortez", "quittez" },
        names = {
            RFC = { "gouffre de ragefeu" }, WC = { "cavernes des lamentations" }, DM = { "mortemines" },
            SFK = { "donjon d'ombrecroc" }, BFD = { "profondeurs de brassenoire" }, STOCKS = { "prison" },
            RFK = { "kraal de tranchebauge" }, SM = { "monastère écarlate" }, RFD = { "souilles de tranchebauge" },
            ST = { "temple englouti" }, BRD = { "profondeurs de rochenoire" }, DME = { "hache-tripes" },
            HOT = { "salle des thanes" }, ROL = { "ruines de lordaeron" },
        },
    },
    ptBR = {
        enter = { "entre", "entrar" },
        leave = { "saia" },
        names = {
            RFC = { "cavernas Ígneas", "cavernas ígneas" }, WC = { "caverna ululante" }, DM = { "minas mortas" },
            SFK = { "bastilha da presa negra" }, BFD = { "profundezas negras" }, STOCKS = { "cárcere" },
            RFK = { "urzal dos mortos" }, SM = { "monastério escarlate" }, RFD = { "urzal dos mortos" },
            ST = { "templo submerso" }, BRD = { "abismo rocha negra" }, DME = { "gládio cruel" },
            HOT = { "hall of thanes" }, ROL = { "ruínas de lordaeron", "ruins of lordaeron" },
        },
    },
    zhCN = {
        enter = { "进入" },
        leave = { "离开" },
        names = {
            RFC = { "怒焰裂谷" }, WC = { "哀嚎洞穴" }, DM = { "死亡矿井" }, SFK = { "影牙城堡" },
            BFD = { "黑暗深渊" }, STOCKS = { "监狱" }, GNOMER = { "诺莫瑞根" }, RFK = { "剃刀沼泽" },
            SM = { "血色修道院" }, RFD = { "剃刀高地" }, ULDA = { "奥达曼" }, ZF = { "祖尔法拉克" },
            MARA = { "玛拉顿" }, ST = { "沉没的神庙", "阿塔哈卡神庙" }, BRD = { "黑石深渊" },
            LBRS = { "黑石塔下层" }, UBRS = { "黑石塔上层" }, DME = { "厄运之槌" }, SCHOLO = { "通灵学院" },
            STRAT = { "斯坦索姆" }, HOT = { "领主大厅" }, ROL = { "洛丹伦废墟" },
        },
    },
}
ns.DETECT.esMX = ns.DETECT.esES
ns.DETECT.ptPT = ns.DETECT.ptBR
ns.DETECT.zhTW = ns.DETECT.zhCN

-- Normale Guide-Gruppe -> passende Dungeon-Gruppe (alle Sprachen, wie in RXP)
ns.PARALLEL_GROUPS = {
    ["RestedXP Forever Guide (H)"] = "RestedXP Forever Dungeon Guide (H)",
    ["RestedXP Forever Guide (A)"] = "RestedXP Forever Dungeon Guide (A)",
    ["RestedXP Forever Route (H)"] = "RestedXP Forever Dungeonführer (H)",
    ["RestedXP Forever Route (A)"] = "RestedXP Forever Dungeonführer (A)",
    ["RestedXP Guía Forever (H)"] = "RestedXP Forever Guía de Mazmorras (H)",
    ["RestedXP Guía Forever (A)"] = "RestedXP Forever Guía de Mazmorras (A)",
    ["RestedXP Guide Forever (H)"] = "Guide de donjon Forever RestedXP (H)",
    ["RestedXP Guide Forever (A)"] = "Guide de donjon Forever RestedXP (A)",
    ["Guia de Progressão Rápida do RestedXP Forever (H)"] = "Guia de Masmorras do RestedXP Forever (H)",
    ["Guia RestedXP Forever (A)"] = "Guia de Masmorras do RestedXP Forever (A)",
    ["RestedXP 无限指南 (部落)"] = "RestedXP 无限 地下城指南 (部落)",
    ["RestedXP 无限指南 (联盟)"] = "RestedXP 无限 地下城指南 (联盟)",
    ["RestedXP无限服指南（联盟）"] = "RestedXP 无限 地下城指南 (联盟)",
}
