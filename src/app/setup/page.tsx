"use client";
import { Tab } from "@headlessui/react";
import UnlockerForm from "@/components/setup/UnlockerForm";
import SideloaderForm from "@/components/setup/SideloaderForm";
import { useTranslation } from "react-i18next";

export default function Page() {
  const { t } = useTranslation();

  return (
    <div className="flex w-full min-w-80 flex-shrink flex-col items-center justify-center space-y-3 px-4">
      <header className="mb-4 mr-auto mt-6 text-left">
        <h1 className="text-4xl font-bold">{t("setup.title")}</h1>
        <p className="text-sm font-medium text-gray-100">
          {t("setup.description")}
        </p>
      </header>
      <div className="card rounded-t-none bg-minecraft-slate-700/80">
        <Tab.Group>
          <Tab.List className="tab-list w-full">
            <Tab className="tab-list__tab">
              <div className="tab-list__btn">
                <span>{t("setup.tab.sideloading")}</span>
                <span />
              </div>
            </Tab>
            <Tab className="tab-list__tab">
              <div className="tab-list__btn">
                <span>{t("setup.tab.unlocking")}</span>
                <span />
              </div>
            </Tab>
            <Tab className="tab-list__tab">
              <div className="tab-list__btn">
                <span>{t("setup.tab.betterRenderDragon")}</span>
                <span />
              </div>
            </Tab>
          </Tab.List>
          <div className="card__body -mt-2 border-t-2 border-minecraft-slate-900 pt-2">
            <Tab.Panels className="flex w-full flex-col items-stretch justify-center">
              <Tab.Panel>
                <SideloaderForm />
              </Tab.Panel>
              <Tab.Panel>
                <UnlockerForm />
              </Tab.Panel>
              <Tab.Panel>
                <p>Better RenderDragon</p>
                <button type="button">Launch Minecraft</button>
              </Tab.Panel>
            </Tab.Panels>
          </div>
        </Tab.Group>
      </div>
    </div>
  );
}
