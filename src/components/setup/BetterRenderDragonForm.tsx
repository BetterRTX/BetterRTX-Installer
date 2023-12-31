"use client";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { ExclamationTriangleIcon } from "@radix-ui/react-icons";
import { MINECRAFT_NAME, MINECRAFT_PREVIEW_NAME } from "@/lib/constants";

import { useMinecraftProcess, useSideload } from "@/hooks";
import { Button } from "../button";

export default function BetterRenderDragonForm() {
  const { t } = useTranslation();
  const [isLaunching, setIsLaunching] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const { launchBetterRenderDragon } = useMinecraftProcess();

  const handleLaunchMinecraft = async (preview?: boolean) => {
    setErrorMessage(null);
    setIsLaunching(true);
    try {
      await launchBetterRenderDragon(
        preview ? MINECRAFT_PREVIEW_NAME : MINECRAFT_NAME,
      );
    } catch (err) {
      setErrorMessage((err as Error).toString());
    } finally {
      setIsLaunching(false);
    }
  };
  return (
    <div className="container">
      <div className="flex w-full flex-col space-y-0.5 pr-4">
        <h5 className="font-medium text-gray-200">
          {t("setup.brd.betterRenderDragonTitle")}
        </h5>
        <p className="text-sm font-normal text-gray-300">
          {t("setup.brd.betterRenderDragonDescription")}
        </p>
      </div>
      {errorMessage && (
        <p className="flex items-center justify-center space-x-2 border border-red-600/50 bg-red-800/50 px-2 py-1 text-center text-xs font-medium leading-relaxed text-red-100 transition-colors duration-200 ease-out hover:bg-red-700">
          <ExclamationTriangleIcon className="inline-block h-4 w-4 translate-y-0.5 select-none opacity-60" />
          <span className="select-all selection:bg-red-700">
            {errorMessage}
          </span>
        </p>
      )}
      <div className="flex w-full flex-col items-stretch justify-start">
        {isLaunching && (
          <p className="text-sm font-medium leading-relaxed text-green-600">
            {t("setup.sideloading.launchingMinecraft")}
          </p>
        )}
        <div className="mt-4 flex flex-col justify-start space-y-2 sm:flex-row sm:items-center sm:space-x-2 sm:space-y-0">
          <Button
            className="btn--lg flex-1 bg-minecraft-green-700/90 hover:bg-minecraft-green-200/80"
            onClick={() => handleLaunchMinecraft()}
          >
            {t("setup.sideloading.startMinecraft")}
          </Button>
          <Button
            className="btn--lg flex-1 bg-yellow-600/80 hover:bg-yellow-500/80"
            onClick={() => handleLaunchMinecraft(true)}
          >
            {t("setup.sideloading.startMinecraftPreview")}
          </Button>
        </div>
      </div>
    </div>
  );
}
