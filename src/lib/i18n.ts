"use client";
import i18n from "i18next";
import { initReactI18next } from "react-i18next";

const resources = {
  en: {
    translation: {
      "button.select": "Select",
      "button.save": "Save",
      "navigation.setup": "Setup",
      "navigation.mod": "Mod",
      "setup.title": "Setup",
      "setup.description": "Setup modding options",
      "setup.tab.sideloading": "Sideloading",
      "setup.tab.unlocking": "Unlocking",
      "setup.tab.betterRenderDragon": "Better Render Dragon",
      "setup.sideloading.title": "Sideload Minecraft",
      "setup.sideloading.sideloaderPathLabel": "Sideload Location",
      "setup.sideloading.description": "Enable sideloading",
      "setup.sideloading.pathPlaceholder":
        "C:\\NotWindowsApps\\[Minecraft.exe]",
      "setup.sideloading.pathDescription":
        "Select the sideloaded Minecraft installation directory.",
      "setup.sideloading.minecraftNotFound":
        "Can not find Windows.Minecraft.exe in the selected directory.",
      "setup.sideloading.instanceNameLabel": "Add a sideloaded instance",
      "setup.sideloading.instanceNamePlaceholder": "Unique instance name",
      "setup.sideloading.addInstance": "Create new instance",
    },
  },
};

i18n.use(initReactI18next).init({
  resources,
  lng: "en",
  fallbackLng: "en",

  interpolation: {
    escapeValue: false,
  },
});

export default i18n;
