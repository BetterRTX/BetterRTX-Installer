"use client";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { open as launch } from "@tauri-apps/api/shell";
import type { SetupState } from "@/store/setupStore";
import { ExclamationTriangleIcon } from "@radix-ui/react-icons";
import { useMinecraftProcess, useSideload } from "@/hooks";
import { Button } from "../button";

export default function SideloadAction({
  location,
}: {
  location: SetupState["sideloadInstances"][string]["location"];
}) {
  const [isSideloading, setIsSideloading] = useState(false);
  const [isLaunching, setIsLaunching] = useState(false);
  const [runningInstance, setRunningInstance] = useState<string | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const { getRunningInstance } = useMinecraftProcess();
  const { t } = useTranslation();
  const { errors, reset, sideload, stdout } = useSideload();

  const handleLaunchMinecraft = async (preview?: boolean) => {
    setErrorMessage(null);
    setIsLaunching(true);
    try {
      // Launch via minecraft: protocol
      await launch(preview ? "minecraft-preview:" : "minecraft:");
    } catch (err) {
      setErrorMessage((err as Error).toString());
    } finally {
      setIsLaunching(false);
    }
  };

  const handleSideloadProcess = async () => {
    reset();
    setErrorMessage(null);
    setIsSideloading(true);
    try {
      await sideload(location);
    } catch (err) {
      setErrorMessage((err as Error).toString());
    } finally {
      setIsSideloading(false);
    }
  };

  useEffect(() => {
    getRunningInstance()
      .then(setRunningInstance)
      .catch((err) => {
        setErrorMessage((err as Error).toString());
      });
  }, [
    getRunningInstance,
    setRunningInstance,
    setErrorMessage,
    runningInstance,
  ]);

  return (
    <div className="flex flex-col">
      {errorMessage && (
        <p className="flex items-center justify-center space-x-2 border border-red-600/50 bg-red-800/50 px-2 py-1 text-center text-xs font-medium leading-relaxed text-red-100 transition-colors duration-200 ease-out hover:bg-red-700">
          <ExclamationTriangleIcon className="inline-block h-4 w-4 translate-y-0.5 select-none opacity-60" />
          <span className="select-all selection:bg-red-700">
            {errorMessage}
          </span>
        </p>
      )}
      <div className="flex flex-col items-start justify-between rounded-b-lg border-t border-gray-600/50 bg-minecraft-slate-700/60 p-4">
        {runningInstance !== null ? (
          <Button
            className="btn mx-auto h-12 w-64 bg-minecraft-purple-800/80"
            onClick={handleSideloadProcess}
            disabled={isSideloading}
          >
            {t("setup.sideloading.processButton") + ` ${runningInstance}`}
          </Button>
        ) : (
          <>
            <div className="flex w-full flex-col space-y-0.5 pr-4">
              <h5 className="font-medium text-gray-200">
                {t("setup.sideloading.processTitle")}
              </h5>
              <p className="text-sm font-normal text-gray-300">
                {t("setup.sideloading.processDescription")}
              </p>
            </div>
            <div className="flex w-full flex-col items-stretch justify-start">
              {isLaunching && (
                <p className="text-sm font-medium leading-relaxed text-green-600">
                  {t("setup.sideloading.launchingMinecraft")}
                </p>
              )}
              <div className="mt-4 flex flex-col justify-start space-y-2 sm:flex-row sm:items-center sm:space-x-2 sm:space-y-0">
                <Button
                  className="btn--lg flex-1 bg-minecraft-green-700/90"
                  onClick={() => handleLaunchMinecraft()}
                >
                  {t("setup.sideloading.startMinecraft")}
                </Button>
                <Button
                  className="btn--lg flex-1 bg-yellow-600/80"
                  onClick={() => handleLaunchMinecraft(true)}
                >
                  {t("setup.sideloading.startMinecraftPreview")}
                </Button>
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
