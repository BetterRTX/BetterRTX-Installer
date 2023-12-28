"use client";
import { withTranslation } from "react-i18next";

function SideloaderForm({ t }: { t: (key: string) => string }) {
  return (
    <form className="space-y-3">
      <header>
        <h3 className="card-title">{t("setup.sideloader.title")}</h3>
        <p className="pl-2 text-xs text-gray-200">
          {t("setup.sideloader.description")}
        </p>
      </header>
    </form>
  );
}

export default withTranslation()(SideloaderForm);
