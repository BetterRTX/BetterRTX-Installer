"use client";
import clsx from "clsx";
import { useState, useContext } from "react";
import { copyFile, removeFile, exists } from "@tauri-apps/api/fs";
import { useTranslation } from "react-i18next";
import { Menu, Transition } from "@headlessui/react";
import { useSetupStore } from "@/store/setupStore";
import { DownloadIcon, UpdateIcon } from "@radix-ui/react-icons";
import { useExtractPack } from "@/hooks";
import PackEntryError from "@/components/mod/PackEntryError";
import {
  ErrorButton,
  SuccessButton,
} from "@/components/mod/buttons/PackEntryButtons";
import { BRTX_PACK_NAME } from "@/lib/constants";
import { PackContext } from "@/context/PackContext";

export default function SideloadEntryMenu() {
  const pack = useContext(PackContext);
  const { t } = useTranslation();
  const { sideloadInstances } = useSetupStore();
  const [packFiles, setPackFiles] = useState<string[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const {
    files,
    getData,
    isExtracting,
    progress,
    error: extractionError,
    packDirectory,
  } = useExtractPack(pack);

  const handleInstall = async (instance: string) => {
    const { join, basename } = await import("@tauri-apps/api/path");
    setLoading(true);

    const dir = await join(
      sideloadInstances[instance].location,
      "data",
      "renderer",
      "materials",
    );

    setPackFiles(files ?? []);
    try {
      return await Promise.all(
        files?.map(async (file) => {
          const filename = await basename(file);
          const dest = await join(dir, filename);

          if (await exists(dest)) {
            await removeFile(dest);
          }

          await copyFile(file, dest, {
            append: false,
          });

          return dest;
        }),
      );
    } catch (err) {
      setError((err as Error).toString());
    } finally {
      setLoading(false);
    }
  };

  const instanceList = Object.keys(sideloadInstances).map((key) => ({
    key,
    ...sideloadInstances[key],
  }));

  const hasPackFiles = packFiles.length > 0;
  const inProgress = progress > 0 && isExtracting;

  return (
    <div className="relative">
      {inProgress && hasPackFiles && <SuccessButton />}
      <Transition
        show={
          progress > 0 && !isExtracting && (error !== null || !hasPackFiles)
        }
        as="div"
        enter="transition-opacity duration-150 ease-out"
        leave="transition-opacity duration-100 ease-in"
        enterFrom="opacity-0"
        enterTo="opacity-100"
        leaveFrom="opacity-100"
        leaveTo="-opacity-0"
      >
        <ErrorButton
          dismiss={() => setError(null)}
          error={error ?? (extractionError ?? "").toString()}
        />
      </Transition>
      <Transition
        show={inProgress && hasPackFiles && !error}
        as="div"
        enter="transition-all duration-200 ease-out transform"
        leave="transition-all duration-100 ease-in transform"
        enterFrom="translate-y-6 opacity-0"
        enterTo="translate-y-0 opacity-100"
        leaveFrom="translate-y-0 opacity-100"
        leaveTo="-translate-y-8 opacity-0"
      >
        <div className="absolute right-0 top-0 z-50 mt-0 w-96 -translate-x-1/2 divide-y divide-minecraft-slate-400/75 rounded-b-md rounded-tl-md border border-minecraft-slate-800/90 bg-minecraft-slate-700/80 shadow-xl backdrop-blur-sm">
          <div className="cursor-default overflow-hidden truncate whitespace-nowrap text-nowrap rounded-tl-md border border-minecraft-slate-300/50 border-b-minecraft-slate-700/50 bg-minecraft-slate-800/60 px-4 py-2 text-xs font-medium uppercase text-gray-200/80">
            {t("mod.copyingInstance")}
          </div>
          <div className="group inline-flex w-full items-stretch border border-minecraft-slate-400/50 border-x-minecraft-slate-300/50 text-left text-sm text-gray-50 backdrop-blur-md transition-colors duration-200 ease-out last:rounded-b-md last:border-b last:border-b-minecraft-slate-200/50 hover:bg-minecraft-slate-400/75 hover:text-gray-100">
            <span className="h-full flex-grow whitespace-nowrap text-nowrap border-b border-b-minecraft-slate-700/50 px-4 py-2 font-medium group-last:border-minecraft-slate-500/50 group-hover:text-gray-200/90 group-focus:text-gray-100">
              {((packFiles?.length ?? 0) % progress) * 100}%
            </span>
          </div>
        </div>
      </Transition>
      {packDirectory && (
        <Transition
          show={hasPackFiles && error !== null}
          as="div"
          enter="transition-all duration-200 ease-out transform"
          leave="transition-all duration-100 ease-in transform"
          enterFrom="translate-y-6 opacity-0"
          enterTo="translate-y-0 opacity-100"
          leaveFrom="translate-y-0 opacity-100"
          leaveTo="-translate-y-8 opacity-0"
        >
          <PackEntryError
            {...{ packFiles, packDirectory }}
            dismiss={() => {
              setError(null);
            }}
          />
        </Transition>
      )}
      <div className="relative">
        <Menu>
          {({ open }) => (
            <>
              <Menu.Button
                className={clsx(
                  open
                    ? "rounded-b-none border-minecraft-blue-400 border-b-minecraft-blue-900 bg-minecraft-blue-700/60"
                    : "bg-minecraft-blue-700/25",
                  loading ? "animate-pulse cursor-default" : "cursor-pointer",
                  "btn z-10 inline-flex h-12 w-12 justify-center rounded-lg py-0 shadow-md outline-none hover:bg-minecraft-blue-700 focus:bg-minecraft-blue-500/80 focus:outline-none active:bg-minecraft-blue-800/75 active:outline-none",
                )}
              >
                {isExtracting || inProgress ? (
                  <UpdateIcon className="h-6 w-6 animate-spin text-blue-400/75" />
                ) : (
                  <DownloadIcon className="h-6 w-6 -translate-x-1 -rotate-90 transform text-gray-100" />
                )}
              </Menu.Button>
              <Transition
                enter="transition duration-300 ease-out"
                enterFrom="opacity-0"
                enterTo="opacity-100"
                leave="duration-100 ease-out"
                leaveFrom="opacity-100"
                leaveTo="opacity-0"
              >
                <Menu.Items className="absolute right-0 top-12 z-20 mt-0 min-w-24 divide-y divide-minecraft-slate-400/75 rounded-b-md rounded-tl-md border border-minecraft-slate-800/90 bg-minecraft-slate-700/80 shadow-xl backdrop-blur-sm">
                  <div className="cursor-default overflow-hidden truncate whitespace-nowrap text-nowrap rounded-tl-md border border-minecraft-slate-300/50 border-b-minecraft-slate-700/50 bg-minecraft-slate-800/60 px-4 py-2 text-xs font-medium uppercase text-gray-200/80">
                    {t("mod.installSideloadInstance")}
                  </div>
                  {instanceList.map((instance) => (
                    <Menu.Item key={instance.key}>
                      <button
                        className="group inline-flex w-full items-stretch border border-minecraft-slate-400/50 border-x-minecraft-slate-300/50 text-left text-sm text-gray-50 backdrop-blur-md transition-colors duration-200 ease-out last:rounded-b-md last:border-b last:border-b-minecraft-slate-200/50 hover:bg-minecraft-slate-400/75 hover:text-gray-100"
                        onClick={() => handleInstall(instance.key)}
                      >
                        <span className="h-full flex-grow whitespace-nowrap text-nowrap border-b border-b-minecraft-slate-700/50 px-4 py-2 font-medium group-last:border-minecraft-slate-500/50 group-hover:text-gray-200/90 group-focus:text-gray-100">
                          {instance.key}
                        </span>
                      </button>
                    </Menu.Item>
                  ))}
                </Menu.Items>
              </Transition>
            </>
          )}
        </Menu>
      </div>
    </div>
  );
}
