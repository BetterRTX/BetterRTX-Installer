"use client";
import i18n from "i18next";
import { initReactI18next } from "react-i18next";

const resources = {
  en: {
    translation: {
      "navigation.setup": "Setup",
      "navigation.mod": "Mod",
      "setup.title": "Setup",
      "setup.description": "Setup modding options",
      "setup.tab.sideloading": "Sideloading",
      "setup.tab.unlocking": "Unlocking",
      "setup.tab.betterRenderDragon": "Better Render Dragon",
    },
  },
};

i18n
  .use(initReactI18next)
  .init({
    resources,
    lng: "en",
    fallbackLng: "en",

    interpolation: {
      escapeValue: false,
    },
  });

export default i18n;
