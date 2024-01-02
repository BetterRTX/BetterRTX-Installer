"use client";
import clsx from "clsx";
import { join, basename } from "@tauri-apps/api/path";
import { copyFile, removeFile, exists } from "@tauri-apps/api/fs";
import { Fragment, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { Menu, Transition } from "@headlessui/react";
import { Pack } from "@/types";
import { useSetupStore } from "@/store/setupStore";
import {
  DownloadIcon,
  LockOpen1Icon,
  CheckIcon,
  UpdateIcon,
} from "@radix-ui/react-icons";
import { useMinecraftProcess, useExtractPack } from "@/hooks";
import PackEntryError from "@/components/mod/PackEntryError";
import { ErrorButton, SuccessButton } from "@/components/mod/PackEntryButtons";

function SideloadEntryMenu({ pack }: { pack: Pack }) {
  const { t } = useTranslation();
  const { sideloadInstances } = useSetupStore();
  const [packFiles, setPackFiles] = useState<string[]>([]);
  const [error, setError] = useState<string | null>(null);
  const {
    getData,
    isExtracting,
    progress,
    error: extractionError,
    packDirectory,
  } = useExtractPack(pack);
  const handleInstall = async (instance: string) => {
    setPackFiles([]);
    const dir = await join(
      sideloadInstances[instance].location,
      "data",
      "renderer",
      "materials",
    );

    const files = await getData();
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
      {progress > 0 && !isExtracting && (error || !hasPackFiles) && (
        <ErrorButton
          dismiss={() => setError(null)}
          error={error ?? (extractionError ?? "").toString()}
        />
      )}
      {inProgress && (
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
      )}
      {hasPackFiles && error && (
        <PackEntryError
          {...{ packFiles, packDirectory }}
          dismiss={() => {
            setError(null);
          }}
        />
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
                  "btn inline-flex h-12 w-12 justify-center  rounded-lg py-0 shadow-md outline-none hover:bg-minecraft-blue-700 focus:bg-minecraft-blue-500/80 focus:outline-none active:bg-minecraft-blue-800/75 active:outline-none",
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

function UnlockerEntryMenu({ pack }: { pack: Pack }) {
  const { t } = useTranslation();
  const { getLocations, getInstanceName } = useMinecraftProcess();
  const handleInstall = () => {
    // TODO
  };

  const [locations, setLocations] = useState<Record<string, string>>({});

  useEffect(() => {
    getLocations().then(setLocations);
  }, [getLocations]);

  return (
    <div className="relative">
      <Menu>
        {({ open }) => (
          <>
            <Menu.Button
              className={clsx(
                open
                  ? "rounded-b-none border-minecraft-purple-400 border-b-minecraft-purple-900 bg-minecraft-purple-700/60"
                  : "bg-minecraft-purple-700/25",
                "btn inline-flex h-12 w-12 justify-center rounded-lg py-0 shadow-md outline-none hover:bg-minecraft-purple-700 focus:bg-minecraft-purple-500/80 focus:outline-none active:bg-minecraft-purple-800/75 active:outline-none",
              )}
            >
              <LockOpen1Icon className="block h-5 w-5 flex-shrink fill-gray-100" />
            </Menu.Button>
            <Transition
              enter="transition duration-100 ease-out"
              enterFrom="opacity-0"
              enterTo=" opacity-100"
              leave="transition duration-75 ease-out"
              leaveFrom=" opacity-100"
              leaveTo="opacity-0"
              as={Fragment}
            >
              <Menu.Items className="absolute right-0 top-12 z-20 mt-0 min-w-24 divide-y divide-minecraft-slate-400/75 rounded-b-md rounded-tl-md border border-minecraft-slate-800/90 bg-minecraft-slate-700/80 shadow-xl backdrop-blur-sm">
                <div className="cursor-default overflow-hidden truncate whitespace-nowrap text-nowrap rounded-tl-md border border-minecraft-slate-300/50 border-b-minecraft-slate-700/50 bg-minecraft-slate-800/60 px-4 py-2 text-xs font-medium uppercase text-gray-200/80">
                  {t("mod.installUnlockerInstance")}
                </div>
                {Object.entries(locations).map(([instance, location]) => (
                  <Menu.Item key={location}>
                    <button
                      className="group inline-flex w-full items-stretch border border-minecraft-slate-400/50 border-x-minecraft-slate-300/50 text-left text-sm text-gray-50 backdrop-blur-md transition-colors duration-200 ease-out last:rounded-b-md last:border-b last:border-b-minecraft-slate-200/50 hover:bg-minecraft-slate-400/75 hover:text-gray-100"
                      onClick={() => handleInstall()}
                    >
                      <span className="h-full flex-grow whitespace-nowrap text-nowrap border-b border-b-minecraft-slate-700/50 px-4 py-2 font-medium group-last:border-minecraft-slate-500/50 group-hover:text-gray-200/90 group-focus:text-gray-100">
                        {getInstanceName(instance)}
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
  );
}

export default function PackEntry({ pack }: { pack: Pack }) {
  const { t } = useTranslation();
  return (
    <div className="flex justify-start space-x-2 p-4">
      <div className="mb-auto flex-shrink-0 overflow-hidden rounded-md border border-gray-400/50 shadow-sm">
        <img
          src={
            new URL(`https://bedrock.graphics/api/pack/${pack.uuid}/icon`).href
          }
          alt={pack.title}
          width={96}
          height={96}
          className="aspect-square cursor-pointer object-cover shadow-sm"
        />
      </div>
      <div className="flex flex-grow flex-col pl-4 pr-0 sm:flex-row sm:space-x-2 sm:space-y-0.5 sm:py-2.5">
        <div className="flex flex-shrink flex-col overflow-hidden">
          <h5 className="flex-shrink cursor-pointer select-none overflow-hidden text-clip font-medium text-gray-200 ui-checked:text-minecraft-blue-400 sm:text-lg">
            {pack.title}
          </h5>
          <h6 className="hidden flex-grow select-none text-sm font-normal text-gray-400/75 sm:block">
            {t("mod.installLabel")}
          </h6>
        </div>
        <div className="mt-4 flex flex-1 space-x-4 pr-4 sm:mt-0 sm:flex-row sm:justify-end">
          <UnlockerEntryMenu {...{ pack }} />
          <SideloadEntryMenu {...{ pack }} />
        </div>
      </div>
    </div>
  );
}
