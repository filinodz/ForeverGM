local _, FGM = ...
local translations = {
    enUS = {
        DASH_CATALOG = "Your game data, at a glance",
        DASH_CATALOG_HINT = "Bundled catalog entries · click a card to browse the collection",
        DASH_OPEN_COLLECTION = "Open this collection. These are bundled catalog counts, not live realm statistics.",
        DASH_TOOLS_HINT = "Explicit GM commands and guided workflows — no assumed on/off status",
        DASH_CONFIRM_HINT = "Review and confirm this command before dispatch. Server permissions still apply.",
        DASH_WORKFLOW_HINT = "Open settings or a guided preview. No bulk operation is sent without confirmation.",
        DASH_COMMAND = "Confirm command", DASH_PREVIEW = "Preview / confirm", DASH_OPEN = "Open settings",
        DASH_SAFETY = "Catalog counts are not online-player or live-world statistics. GM shortcuts request explicit actions; they do not report server state. Check server chat for outcomes.",
    },
    frFR = {
        DASH_CATALOG = "Vos données de jeu en un coup d’œil",
        DASH_CATALOG_HINT = "Entrées du catalogue fourni · cliquez pour ouvrir une collection",
        DASH_OPEN_COLLECTION = "Ouvrir cette collection. Ces chiffres proviennent du catalogue fourni, pas de statistiques du royaume en direct.",
        DASH_TOOLS_HINT = "Commandes MJ explicites et aperçus guidés — aucun état actif supposé",
        DASH_CONFIRM_HINT = "Vérifiez et confirmez cette commande avant l’envoi. Les permissions du serveur restent applicables.",
        DASH_WORKFLOW_HINT = "Ouvrir les réglages ou un aperçu guidé. Aucun envoi groupé sans confirmation.",
        DASH_COMMAND = "Confirmer la commande", DASH_PREVIEW = "Aperçu / confirmation", DASH_OPEN = "Ouvrir les réglages",
        DASH_SAFETY = "Les chiffres du catalogue ne représentent ni les joueurs connectés ni le monde en direct. Les raccourcis demandent une action explicite, sans afficher l’état du serveur. Vérifiez le résultat dans le chat.",
    },
    esES = {
        DASH_CATALOG = "Tus datos de juego de un vistazo",
        DASH_CATALOG_HINT = "Entradas del catálogo incluido · pulsa una tarjeta para explorar",
        DASH_OPEN_COLLECTION = "Abrir esta colección. Los números corresponden al catálogo incluido, no a estadísticas en vivo del reino.",
        DASH_TOOLS_HINT = "Comandos MJ explícitos y vistas guiadas — sin asumir estados activos",
        DASH_CONFIRM_HINT = "Revisa y confirma este comando antes de enviarlo. Se aplican los permisos del servidor.",
        DASH_WORKFLOW_HINT = "Abrir ajustes o una vista guiada. No se envían operaciones masivas sin confirmación.",
        DASH_COMMAND = "Confirmar comando", DASH_PREVIEW = "Vista / confirmación", DASH_OPEN = "Abrir ajustes",
        DASH_SAFETY = "Los números del catálogo no representan jugadores conectados ni el mundo en vivo. Los accesos solicitan acciones explícitas, no muestran el estado del servidor. Comprueba el resultado en el chat.",
    },
}
for locale, values in pairs(translations) do
    for key, value in pairs(values) do FGM.Locales[locale][key] = value end
end
