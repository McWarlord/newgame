--loginScene = nil
--gameConfig = nil
--lobbyData = nil
singleGame = false
isDebug = false
isMutilLobby=false
isMutilGame=false
localnet = true
language = "En"
--[[local lan = cc.LocalStorage:localStorageGetItem("Language")
if lan == "" or lan == nil then
    local currentLanguageType = cc.Application:getInstance():getCurrentLanguage()

    if currentLanguageType == cc.LANGUAGE_ENGLISH then
        language = "En"
    elseif currentLanguageType == cc.LANGUAGE_CHINESE then
        language = "En"
    elseif currentLanguageType == cc.LANGUAGE_FRENCH then
        language = "En"
    elseif currentLanguageType == cc.LANGUAGE_GERMAN then
        language = "En"
    elseif currentLanguageType == cc.LANGUAGE_ITALIAN then
        language = "En"
    elseif currentLanguageType == cc.LANGUAGE_RUSSIAN then
        language = "En"
    elseif currentLanguageType == cc.LANGUAGE_SPANISH then
        language = "En"
    elseif currentLanguageType == cc.LANGUAGE_KOREAN then
        language = "En"
    elseif currentLanguageType == cc.LANGUAGE_JAPANESE then
        language = "En"
    elseif currentLanguageType == cc.LANGUAGE_HUNGARIAN then
        language = "En"
    elseif currentLanguageType == cc.LANGUAGE_PORTUGUESE then
        language = "En"
    elseif currentLanguageType == cc.LANGUAGE_ARABIC then
        language = "En"
    else
        language = "En"
    end
    cc.LocalStorage:localStorageSetItem("Language", language)
    --language = "En"
    --language = "Thai"
    --language = "CN"
else
    language = lan
    --language = "En"
    --language = "Thai"
    --language = "CN"
end
]]