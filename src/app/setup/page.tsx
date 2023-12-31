"use client";
import { Tab } from "@headlessui/react";
import UnlockerForm from "@/components/setup/UnlockerForm";
import SideloaderForm from "@/components/setup/SideloaderForm";
import { useTranslation } from "react-i18next";
import BetterRenderDragonForm from "@/components/setup/BetterRenderDragonForm";

export default function Page() {
  const { t } = useTranslation();

  return (
    <div className="container mx-auto flex flex-shrink flex-col items-center justify-center space-y-3 px-6 py-2">
      <header className="mb-4 mr-auto mt-6 text-left">
        <h1 className="text-4xl font-bold">{t("setup.title")}</h1>
        <p className="text-sm font-medium text-gray-100">
          {t("setup.description")}
        </p>
      </header>
      <div className="card rounded-t-md bg-minecraft-slate-700/80">
        <Tab.Group>
          <Tab.List className="tab-list w-full rounded-t">
            <Tab className="tab-list__tab rounded-tl">
              <div className="tab-list__btn rounded-tl">
                <span className="rounded-tl">{t("setup.tab.sideloading")}</span>
                <span />
              </div>
            </Tab>
            <Tab className="tab-list__tab">
              <div className="tab-list__btn">
                <span>{t("setup.tab.unlocking")}</span>
                <span />
              </div>
            </Tab>
            <Tab className="tab-list__tab rounded-tr">
              <div className="tab-list__btn rounded-tr">
                <span className="rounded-tr">
                  {t("setup.tab.betterRenderDragon")}
                </span>
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
                <BetterRenderDragonForm />
              </Tab.Panel>
            </Tab.Panels>
          </div>
        </Tab.Group>
      </div>
    </div>
  );
}
