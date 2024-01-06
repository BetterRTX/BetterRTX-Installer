"use client";
import type { IPack } from "@/types";
import { useTranslation } from "react-i18next";
import UnlockerEntryMenu from "@/components/mod/buttons/UnlockButton";
import SideloadEntryMenu from "@/components/mod/buttons/SideloadButton";
import { PackContext } from "@/context";

export default function PackEntry({ pack }: { pack: IPack }) {
  const { t } = useTranslation();
  return (
    <PackContext.Provider value={pack}>
      <div className="flex justify-start space-x-2 p-4">
        <div className="mb-auto flex-shrink-0 overflow-hidden rounded-md border border-gray-400/50 shadow-sm">
          <img
            src={
              new URL(`https://bedrock.graphics/api/pack/${pack.uuid}/icon`)
                .href
            }
            alt={pack.title}
            width={96}
            height={96}
            className="aspect-square cursor-pointer object-cover shadow-sm"
          />
        </div>
        <div className="flex flex-grow flex-col pl-4 pr-0 sm:flex-row sm:space-x-2 sm:space-y-0.5 sm:py-2.5">
          <div className="flex flex-shrink flex-col items-start justify-stretch overflow-hidden">
            <h5
              className="flex-shrink cursor-pointer select-none overflow-hidden text-clip font-medium text-gray-200 ui-checked:text-minecraft-blue-400 sm:text-lg"
              title={pack.path}
            >
              {pack.title}
            </h5>
            <h6 className="hidden flex-grow select-none text-sm font-normal text-gray-400/75 sm:block">
              {t("mod.installLabel")}
            </h6>
          </div>
          <div className="mt-4 flex flex-1 space-x-4 pr-4 sm:mt-0 sm:flex-row sm:justify-end">
            <UnlockerEntryMenu />
            <SideloadEntryMenu />
          </div>
        </div>
      </div>
    </PackContext.Provider>
  );
}
